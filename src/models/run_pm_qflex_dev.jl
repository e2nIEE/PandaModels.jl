function run_pandamodels_qflex_test(json_path)   # before run_poweramodels
    time_start = time()
    ###############################################################################
    # 0. Initialization
    ###############################################################################
    pm = load_pm_from_json(json_path)
    solver = get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
    pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"], pm["pm_mip_time_limit"])
    if haskey(pm, "user_defined_params")
        user_defined_params = pm["user_defined_params"]
        data = delete!(pm, "user_defined_params")
    else
        data = pm
    end

    # additional modification
    for (i, branch) in pm["branch"]
        pm["branch"][i]["angmin"] = -6.28
        pm["branch"][i]["angmax"] = 6.28
    end

    # use build_ref to filter out inactive components
    ref = PowerModels.build_ref(data)[:it][:pm][:nw][0]

    ###############################################################################
    # 1. Building the Optimal Power Flow Model
    ###############################################################################
    # Initialize a JuMP Optimization Model
    #-------------------------------------
    model = JuMP.Model(solver)

    # Add voltage angles va for each bus
    JuMP.@variable(model, va[i in keys(ref[:bus])])
    # note: [i in keys(ref[:bus])] adds one `va` variable for each bus in the network

    # Add voltage angles vm for each bus
    JuMP.@variable(model, ref[:bus][i]["vmin"] <= vm[i in keys(ref[:bus])] <= ref[:bus][i]["vmax"], start=1.0)
    # note: this vairable also includes the voltage magnitude limits and a starting value

    # Add active power generation variable pg for each generator (including limits)
    JuMP.@variable(model, ref[:gen][i]["pmin"] <= pg[i in keys(ref[:gen])] <= ref[:gen][i]["pmax"], start=ref[:gen][i]["pg"])
    # Add reactive power generation variable qg for each generator (including limits)
    JuMP.@variable(model, ref[:gen][i]["qmin"] <= qg[i in keys(ref[:gen])] <= ref[:gen][i]["qmax"], start=ref[:gen][i]["qg"])

    # Add power flow variables p to represent the active power flow for each branch
    JuMP.@variable(model, -ref[:branch][l]["rate_a"] <= p[(l,i,j) in ref[:arcs]] <= ref[:branch][l]["rate_a"])
    # Add power flow variables q to represent the reactive power flow for each branch
    JuMP.@variable(model, -ref[:branch][l]["rate_a"] <= q[(l,i,j) in ref[:arcs]] <= ref[:branch][l]["rate_a"])
    # note: ref[:arcs] includes both the from (i,j) and the to (j,i) sides of a branch

    # Add Objective Function
    # ----------------------

    JuMP.@objective(model, Min, sum((q[(content["element_index"],
                                content["f_bus"],
                                content["t_bus"])] - content["value"])^2
                            for (i, content) in user_defined_params["setpoint_q"]))

    # Add Constraints
    for (i,bus) in ref[:ref_buses]
        JuMP.@constraint(model, va[i] == 0)
    end

    # Nodal power balance constraints
    for (i,bus) in ref[:bus]
        # Build a list of the loads and shunt elements connected to the bus i
        bus_loads = [ref[:load][l] for l in ref[:bus_loads][i]]
        bus_shunts = [ref[:shunt][s] for s in ref[:bus_shunts][i]]

        # Active power balance at node i
        JuMP.@constraint(model,
            sum(p[a] for a in ref[:bus_arcs][i]) +                  # sum of active power flow on lines from bus i +
            sum(p_dc[a_dc] for a_dc in ref[:bus_arcs_dc][i]) ==     # sum of active power flow on HVDC lines from bus i =
            sum(pg[g] for g in ref[:bus_gens][i]) -                 # sum of active power generation at bus i -
            sum(load["pd"] for load in bus_loads) -                 # sum of active load consumption at bus i -
            sum(shunt["gs"] for shunt in bus_shunts)*vm[i]^2        # sum of active shunt element injections at bus i
        )

        # Reactive power balance at node i
        JuMP.@constraint(model,
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
        JuMP.@NLconstraint(model, p_fr ==  (g+g_fr)/tm*vm_fr^2 + (-g*tr+b*ti)/tm*(vm_fr*vm_to*cos(va_fr-va_to)) + (-b*tr-g*ti)/tm*(vm_fr*vm_to*sin(va_fr-va_to)) )
        JuMP.@NLconstraint(model, q_fr == -(b+b_fr)/tm*vm_fr^2 - (-b*tr-g*ti)/tm*(vm_fr*vm_to*cos(va_fr-va_to)) + (-g*tr+b*ti)/tm*(vm_fr*vm_to*sin(va_fr-va_to)) )

        # To side of the branch flow
        JuMP.@NLconstraint(model, p_to ==  (g+g_to)*vm_to^2 + (-g*tr-b*ti)/tm*(vm_to*vm_fr*cos(va_to-va_fr)) + (-b*tr+g*ti)/tm*(vm_to*vm_fr*sin(va_to-va_fr)) )
        JuMP.@NLconstraint(model, q_to == -(b+b_to)*vm_to^2 - (-b*tr+g*ti)/tm*(vm_to*vm_fr*cos(va_fr-va_to)) + (-g*tr-b*ti)/tm*(vm_to*vm_fr*sin(va_to-va_fr)) )

        # Voltage angle difference limit
        JuMP.@constraint(model, va_fr - va_to <= branch["angmax"])
        JuMP.@constraint(model, va_fr - va_to >= branch["angmin"])

        # Apparent power limit, from side and to side
        JuMP.@constraint(model, p_fr^2 + q_fr^2 <= branch["rate_a"]^2)
        JuMP.@constraint(model, p_to^2 + q_to^2 <= branch["rate_a"]^2)
    end


    ###############################################################################
    # 3. Solve the Optimal Power Flow Model and Review the Results
    ###############################################################################
    JuMP.optimize!(model)

    ###############################################################################
    # 4. Create Result Dictionary such that the PowerModels Results can be used by pandapower
    ###############################################################################
    solution =  Dict{String,Any}()
    push!(solution, "baseMVA" => data["baseMVA"])
    push!(solution, "per_unit" => data["per_unit"])
    push!(solution, "gen" => data["gen"])
    push!(solution, "bus" => data["bus"])
    push!(solution, "branch" => data["branch"])
    push!(solution, "multinetwork" => false)
    push!(solution, "multiinfrastructrue" => false)

    for (i, gen) in solution["gen"]
        index = gen["index"]
        gen["qg"] = value(model[:qg][index])
        gen["pg"] = value(model[:pg][index])
    end

    for (i, bus) in solution["bus"]
        index = bus["index"]
        bus["vm"] = value(model[:vm][index])
        bus["va"] = value(model[:va][index])
    end

    for (i, branch) in solution["branch"]
        index = branch["index"]
        push!(branch, "qf" => value(model[:q][(index, branch["f_bus"], branch["t_bus"])]))
        push!(branch, "qt" => value(model[:q][(index, branch["t_bus"], branch["f_bus"])]))
        push!(branch, "pf" => value(model[:p][(index, branch["f_bus"], branch["t_bus"])]))
        push!(branch, "pt" => value(model[:p][(index, branch["t_bus"], branch["f_bus"])]))
    end
    println("The solver termination status is")

    result = Dict{String,Any}(
            "optimizer" => JuMP.solver_name(model),
            "termination_status" => JuMP.termination_status(model),   # "LOCALLY_SOLVED",
            "primal_status" => JuMP.primal_status(model),
            "dual_status" => JuMP.dual_status(model),
            "objective" => InfrastructureModels._guard_objective_value(model),
            "objective_lb" => InfrastructureModels._guard_objective_bound(model),
            "solve_time" => solve_time,
            "solution" => solution)

    return result
end


# json_path = "C:/Users/fmeier/pandapower/pandapower/test/opf/case5_clm_matfile_va.json"
# # #@enter run_powermodels(json_path)
# #
# result = run_powermodels(json_path)
# println(result["termination_status"] == LOCALLY_SOLVED)
# println(isapprox(result["objective"], 17015.5; atol = 1e0))
# mit eingeschränkter slack spannung: 17082.819507648066
