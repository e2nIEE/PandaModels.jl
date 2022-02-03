export _run_q_flex

# mutable struct q_flexPowerModel <: _PM.AbstractACModel _PM.@pm_fields end

"""
run model for Voltge-Deviation objective with AC Power Flow equations
"""

function _run_q_flex(file, model_type::_PM.Type, optimizer; kwargs...)
    return _PM.run_model(file, model_type, optimizer, _build_q_flex; kwargs...)
end

"""
given a JuMP model and a PowerModels network data structure,
builds an Voltge-Deviation formulation of the given data and returns the JuMP model
"""

function _build_q_flex(pm::_PM.AbstractPowerModel)

    model = Model(solver)
    #nlp_optimizer = optimizer_with_attributes(Ipopt.Optimizer)
    #model = Model(nlp_optimizer)
    # Add Optimization and State Variables
    # ------------------------------------

    # Add voltage angles va for each bus
    @variable(model, va[i in keys(ref[:bus])])
    # note: [i in keys(ref[:bus])] adds one `va` variable for each bus in the network

    # Add voltage angles vm for each bus
    @variable(model, ref[:bus][i]["vmin"] <= vm[i in keys(ref[:bus])] <= ref[:bus][i]["vmax"], start=1.0)
    # note: this vairable also includes the voltage magnitude limits and a starting value

    # Add active power generation variable pg for each generator (including limits)
    @variable(model, ref[:gen][i]["pmin"] <= pg[i in keys(ref[:gen])] <= ref[:gen][i]["pmax"])
    # Add reactive power generation variable qg for each generator (including limits)
    @variable(model, ref[:gen][i]["qmin"] <= qg[i in keys(ref[:gen])] <= ref[:gen][i]["qmax"])

    # Add power flow variables p to represent the active power flow for each branch
    @variable(model, -ref[:branch][l]["rate_a"] <= p[(l,i,j) in ref[:arcs]] <= ref[:branch][l]["rate_a"])
    # Add power flow variables q to represent the reactive power flow for each branch
    @variable(model, -ref[:branch][l]["rate_a"] <= q[(l,i,j) in ref[:arcs]] <= ref[:branch][l]["rate_a"])
    # note: ref[:arcs] includes both the from (i,j) and the to (j,i) sides of a branch

    # Add Objective Function
    # ----------------------

    @objective(model, Min, sum((q[(content["element_index"],
                                content["f_bus"],
                                content["t_bus"])] - content["value"])^2
                            for (i, content) in user_defined_params["setpoint_q"]))

    # Add Constraints
    # ---------------

    # Fix the voltage angle to zero at the reference bus ## why?
    for (i,bus) in ref[:ref_buses]
        @constraint(model, va[i] == 0)
    end

    # Nodal power balance constraints
    for (i,bus) in ref[:bus]
        # Build a list of the loads and shunt elements connected to the bus i
        bus_loads = [ref[:load][l] for l in ref[:bus_loads][i]]
        bus_shunts = [ref[:shunt][s] for s in ref[:bus_shunts][i]]

        # Active power balance at node i
        @constraint(model,
            sum(p[a] for a in ref[:bus_arcs][i]) +                  # sum of active power flow on lines from bus i +
            sum(p_dc[a_dc] for a_dc in ref[:bus_arcs_dc][i]) ==     # sum of active power flow on HVDC lines from bus i =
            sum(pg[g] for g in ref[:bus_gens][i]) -                 # sum of active power generation at bus i -
            sum(load["pd"] for load in bus_loads) -                 # sum of active load consumption at bus i -
            sum(shunt["gs"] for shunt in bus_shunts)*vm[i]^2        # sum of active shunt element injections at bus i
        )

        # Reactive power balance at node i
        @constraint(model,
            sum(q[a] for a in ref[:bus_arcs][i]) +                  # sum of reactive power flow on lines from bus i +
            sum(q_dc[a_dc] for a_dc in ref[:bus_arcs_dc][i]) ==     # sum of reactive power flow on HVDC lines from bus i =
            sum(qg[g] for g in ref[:bus_gens][i]) -                 # sum of reactive power generation at bus i -
            sum(load["qd"] for load in bus_loads) +                 # sum of reactive load consumption at bus i -
            sum(shunt["bs"] for shunt in bus_shunts)*vm[i]^2        # sum of reactive shunt element injections at bus i
        )
    end

    # Branch power flow physics and limit constraints
    for (i,branch) in ref[:branch]
        # Build the from variable id of the i-th branch, which is a tuple given by (branch id, from bus, to bus)
        f_idx = (i, branch["f_bus"], branch["t_bus"])
        # Build the to variable id of the i-th branch, which is a tuple given by (branch id, to bus, from bus)
        t_idx = (i, branch["t_bus"], branch["f_bus"])
        # note: it is necessary to distinguish between the from and to sides of a branch due to power losses

        p_fr = p[f_idx]                     # p_fr is a reference to the optimization variable p[f_idx]
        q_fr = q[f_idx]                     # q_fr is a reference to the optimization variable q[f_idx]
        p_to = p[t_idx]                     # p_to is a reference to the optimization variable p[t_idx]
        q_to = q[t_idx]                     # q_to is a reference to the optimization variable q[t_idx]
        # note: adding constraints to p_fr is equivalent to adding constraints to p[f_idx], and so on

        vm_fr = vm[branch["f_bus"]]         # vm_fr is a reference to the optimization variable vm on the from side of the branch
        vm_to = vm[branch["t_bus"]]         # vm_to is a reference to the optimization variable vm on the to side of the branch
        va_fr = va[branch["f_bus"]]         # va_fr is a reference to the optimization variable va on the from side of the branch
        va_to = va[branch["t_bus"]]         # va_fr is a reference to the optimization variable va on the to side of the branch

        # Compute the branch parameters and transformer ratios from the data
        g, b = PowerModels.calc_branch_y(branch)
        tr, ti = PowerModels.calc_branch_t(branch)
        g_fr = branch["g_fr"]
        b_fr = branch["b_fr"]
        g_to = branch["g_to"]
        b_to = branch["b_to"]
        tm = branch["tap"]^2
        # note: tap is assumed to be 1.0 on non-transformer branches


        # AC Power Flow Constraints

        # From side of the branch flow
        @NLconstraint(model, p_fr ==  (g+g_fr)/tm*vm_fr^2 + (-g*tr+b*ti)/tm*(vm_fr*vm_to*cos(va_fr-va_to)) + (-b*tr-g*ti)/tm*(vm_fr*vm_to*sin(va_fr-va_to)) )
        @NLconstraint(model, q_fr == -(b+b_fr)/tm*vm_fr^2 - (-b*tr-g*ti)/tm*(vm_fr*vm_to*cos(va_fr-va_to)) + (-g*tr+b*ti)/tm*(vm_fr*vm_to*sin(va_fr-va_to)) )

        # To side of the branch flow
        @NLconstraint(model, p_to ==  (g+g_to)*vm_to^2 + (-g*tr-b*ti)/tm*(vm_to*vm_fr*cos(va_to-va_fr)) + (-b*tr+g*ti)/tm*(vm_to*vm_fr*sin(va_to-va_fr)) )
        @NLconstraint(model, q_to == -(b+b_to)*vm_to^2 - (-b*tr+g*ti)/tm*(vm_to*vm_fr*cos(va_fr-va_to)) + (-g*tr-b*ti)/tm*(vm_to*vm_fr*sin(va_to-va_fr)) )

        # Voltage angle difference limit
        @constraint(model, va_fr - va_to <= branch["angmax"])
        @constraint(model, va_fr - va_to >= branch["angmin"])

        # Apparent power limit, from side and to side
        @constraint(model, p_fr^2 + q_fr^2 <= branch["rate_a"]^2)
        @constraint(model, p_to^2 + q_to^2 <= branch["rate_a"]^2)
    end


    ###############################################################################
    # 3. Solve the Optimal Power Flow Model and Review the Results
    ###############################################################################

    # Solve the optimization problem
    # optimize!(model)
    #
    #
    #
    # _PM.variable_bus_voltage(pm)
    # _PM.variable_gen_power(pm)
    # _PM.variable_branch_power(pm)
    # _PM.variable_dcline_power(pm, bounded = false) # TODO: why false?
    #
    # objective_q_flex(pm)
    #
    # _PM.constraint_model_voltage(pm)
    #
    # for i in _PM.ids(pm, :ref_buses)
    #     _PM.constraint_theta_ref(pm, i)
    # end
    #
    # for i in _PM.ids(pm, :bus)
    #     _PM.constraint_power_balance(pm, i)
    # end
    #
    # for (i, branch) in _PM.ref(pm, :branch)
    #     _PM.constraint_ohms_yt_from(pm, i)
    #     _PM.constraint_ohms_yt_to(pm, i)
    #
    #     _PM.constraint_thermal_limit_from(pm, i)
    #     _PM.constraint_thermal_limit_to(pm, i)
    # end
    #
    # for i in _PM.ids(pm, :dcline)
    #     _PM.constraint_dcline_power_losses(pm, i)
    # end
end

# function objective_q_flex(pm::_PM.AbstractPowerModel)
#     return JuMP.@objective(pm.model, Min, sum((q[(content["element_index"],
#                         content["f_bus"],
#                         content["t_bus"])] - content["value"])^2
#                         for (i, content) in in pm.ext[:setpoint_q]))
# end
#
#
# function objective_q_flex(pm::_PM.AbstractPowerModel)
#     return JuMP.@objective(pm.model, Min,
#         sum((var(pm, :vm, content["element_index"]) - content["value"])^2 for (i, content) in pm.ext[:setpoint_q]))
# end
