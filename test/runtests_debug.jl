# import Pkg
# Pkg.activate(".")
using Test
using PandaModels; const _PdM = PandaModels
import PowerModels; const _PM = PowerModels

_PM.silence()

pdm_path = joinpath(dirname(pathof(PandaModels)), "..")
data_path = joinpath(pdm_path, "test", "data")
case_ts = joinpath(data_path, "cigre_with_timeseries.json")
case_ts = joinpath(data_path, "test_mn_qflex.json")


##
pm = _PdM.load_pm_from_json(case_ts)
_PdM.active_powermodels_silence!(pm)
pm = _PdM.check_powermodels_data!(pm)
model = _PdM.get_model(pm["pm_model"])
solver = _PdM.get_solver(pm)
mn = _PdM.set_pq_values_from_timeseries(pm)

# for (n, network) in _PM.nws(model)
#         _PM.variable_bus_voltage(pm, nw=n)
#         _PM.variable_gen_power(pm, nw=n)
#         _PM.variable_branch_power(pm, nw=n)
#         _PM.variable_dcline_power(pm, nw=n)
#
#         _PM.constraint_model_voltage(pm, nw=n)
#
#         for i in ids(pm, :ref_buses, nw=n)
#             _PM.constraint_theta_ref(pm, i, nw=n)
#         end
#
#         for i in ids(pm, :bus, nw=n)
#             _PM.constraint_power_balance(pm, i, nw=n)
#         end
#
#         for i in ids(pm, :branch, nw=n)
#             _PM.constraint_ohms_yt_from(pm, i, nw=n)
#             _PM.constraint_ohms_yt_to(pm, i, nw=n)
#
#             _PM.constraint_voltage_angle_difference(pm, i, nw=n)
#
#             _PM.constraint_thermal_limit_from(pm, i, nw=n)
#             _PM.constraint_thermal_limit_to(pm, i, nw=n)
#         end
#
#         for i in ids(pm, :dcline, nw=n)
#             _PM.constraint_dcline_power_losses(pm, i, nw=n)
#         end
# end
#
#
# timestep_ids = [id for id in _PM.nw_ids(pm) if id != 0]
# JuMP.@objective(mn.model, Min,
#     sum(
#     sum((var(mn, nw, :q, (content["element_index"], content["f_bus"], content["t_bus"])) - content["value"])^2 for (i, content) in pm.ext[:setpoint_q])
#     for nw in timestep_ids)
#         )
# println(JuMP.objective_function(pm.model))

result_mn = _PdM._run_multi_qflex(
    mn,
    model,
    solver,
    setting = Dict("output" => Dict("branch_flows" => true)),
    ext = _PdM.extract_params!(pm),
)


pm = _PdM.load_pm_from_json(case_ts)
_PdM.active_powermodels_silence!(pm)
pm = _PdM.check_powermodels_data!(pm)
# params = _PdM.extract_params!(pm)
# pm = delete!(pm, "user_defined_params")
model = _PdM.get_model(pm["pm_model"])
solver = _PdM.get_solver(pm)

result = _PdM._run_qflex(
    pm,
    model,
    solver,
    setting = Dict("output" => Dict("branch_flows" => true)),
    ext = _PdM.extract_params!(pm),
)
printf("mn_objective: %0.20f", result_mn["objective"])
printf("objective: %0.20f", result["objective"])

# using InfrastructureModels; const _IM = InfrastructureModels
#
# for (n, network) in _IM.nws(mn)
#         variable_bus_voltage(pm, nw=n)
#         variable_gen_power(pm, nw=n)
#         variable_branch_power(pm, nw=n)
#         variable_dcline_power(pm, nw=n)
#
#         constraint_model_voltage(pm, nw=n)
#
#         for i in ids(pm, :ref_buses, nw=n)
#             constraint_theta_ref(pm, i, nw=n)
#         end
#
#         for i in ids(pm, :bus, nw=n)
#             constraint_power_balance(pm, i, nw=n)
#         end
#
#         for i in ids(pm, :branch, nw=n)
#             constraint_ohms_yt_from(pm, i, nw=n)
#             constraint_ohms_yt_to(pm, i, nw=n)
#
#             constraint_voltage_angle_difference(pm, i, nw=n)
#
#             constraint_thermal_limit_from(pm, i, nw=n)
#             constraint_thermal_limit_to(pm, i, nw=n)
#         end
#
#         for i in ids(pm, :dcline, nw=n)
#             constraint_dcline_power_losses(pm, i, nw=n)
#         end
#     end














# _PdM.active_powermodels_silence!(pm)
# pm = _PdM.check_powermodels_data!(pm)
# model = _PdM.get_model(pm["pm_model"])
# solver = _PdM.get_solver(pm)
# result = _PdM._run_q_flex(
#     pm,
#     model,
#     solver,
#     setting = Dict("output" => Dict("branch_flows" => true)),
#     ext = _PdM.extract_params!(pm),
# )
# mn = set_pq_values_from_timeseries(pm)



# result = _run_mn_vd(
#     pm,
#     model,
#     solver,
#     setting = Dict("output" => Dict("branch_flows" => true)),
#     ext = extract_params!(pm),
# )



# result = run_pandamodels_q_flex(case_q_flex)
# import InfrastructureModels
# using JuMP
# pm = _PdM.load_pm_from_json(case_q_flex)
# # active_powermodels_silence!(pm)
# pm =  _PdM.check_powermodels_data!(pm)
# model =  _PdM.get_model(pm["pm_model"])
# solver =  _PdM.get_solver(pm)
# #
# # # ext = _PdM.extract_params!(pm)
# #
# # result = _run_q_flex(
# # pm,
# # model,
# # solver,
# # setting = Dict("output" => Dict("branch_flows" => true)),
# # ext = _PdM.extract_params!(pm),
# # )
#
#
# # pm = load_pm_from_json(json_path)
# # active_powermodels_silence!(pm)
# # pm = check_powermodels_data!(pm)
# # model = get_model(pm["pm_model"])
# # solver = get_solver(pm)
# ##  Load System Data
# # pm = load_pm_from_json(json_path)
# # solver = get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
# # pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"], pm["pm_mip_time_limit"])
#
# # if haskey(pm, "user_defined_params")
#     # params = Dict{Symbol,Dict{String,Any}}()
#     # for key in keys(pm["user_defined_params"])
#     #     params[Symbol(key)] = pm["user_defined_params"][key]
#     # end
#     # data = delete!(pm, "user_defined_params")
# # end
# #
# if haskey(pm, "user_defined_params")
#     user_defined_params = pm["user_defined_params"]
#     data = delete!(pm, "user_defined_params")
# else
#     data = pm
# end
#
# # additional modification
# for (i, branch) in pm["branch"]
#     pm["branch"][i]["angmin"] = -6.28
#     pm["branch"][i]["angmax"] = 6.28
# end
#
# # use build_ref to filter out inactive components
# ref = PowerModels.build_ref(data)[:it][:pm][:nw][0]
#
# ###############################################################################
# # 1. Building the Optimal Power Flow Model
# ###############################################################################
# # Initialize a JuMP Optimization Model
# #-------------------------------------
# model = Model(solver)
# #nlp_optimizer = optimizer_with_attributes(Ipopt.Optimizer)
# #model = Model(nlp_optimizer)
# # Add Optimization and State Variables
# # ------------------------------------
#
# # Add voltage angles va for each bus
# @variable(model, va[i in keys(ref[:bus])])
# # note: [i in keys(ref[:bus])] adds one `va` variable for each bus in the network
#
# # Add voltage angles vm for each bus
# @variable(model, ref[:bus][i]["vmin"] <= vm[i in keys(ref[:bus])] <= ref[:bus][i]["vmax"], start=1.0)
# # note: this vairable also includes the voltage magnitude limits and a starting value
#
# # Add active power generation variable pg for each generator (including limits)
# @variable(model, ref[:gen][i]["pmin"] <= pg[i in keys(ref[:gen])] <= ref[:gen][i]["pmax"])
# # Add reactive power generation variable qg for each generator (including limits)
# @variable(model, ref[:gen][i]["qmin"] <= qg[i in keys(ref[:gen])] <= ref[:gen][i]["qmax"])
#
# # Add power flow variables p to represent the active power flow for each branch
# @variable(model, -ref[:branch][l]["rate_a"] <= p[(l,i,j) in ref[:arcs]] <= ref[:branch][l]["rate_a"])
# # Add power flow variables q to represent the reactive power flow for each branch
# @variable(model, -ref[:branch][l]["rate_a"] <= q[(l,i,j) in ref[:arcs]] <= ref[:branch][l]["rate_a"])
# # note: ref[:arcs] includes both the from (i,j) and the to (j,i) sides of a branch
#
# # Add Objective Function
# # ----------------------
#
# @objective(model, Min, sum((q[(content["element_index"],
#                             content["f_bus"],
#                             content["t_bus"])] - content["value"])^2
#                         for (i, content) in user_defined_params["setpoint_q"]))
#
# # Add Constraints
# # ---------------
#
# # Fix the voltage angle to zero at the reference bus ## why?
# for (i,bus) in ref[:ref_buses]
#     @constraint(model, va[i] == 0)
# end
#
# # Nodal power balance constraints
# for (i,bus) in ref[:bus]
#     # Build a list of the loads and shunt elements connected to the bus i
#     bus_loads = [ref[:load][l] for l in ref[:bus_loads][i]]
#     bus_shunts = [ref[:shunt][s] for s in ref[:bus_shunts][i]]
#
#     # Active power balance at node i
#     @constraint(model,
#         sum(p[a] for a in ref[:bus_arcs][i]) +                  # sum of active power flow on lines from bus i +
#         sum(p_dc[a_dc] for a_dc in ref[:bus_arcs_dc][i]) ==     # sum of active power flow on HVDC lines from bus i =
#         sum(pg[g] for g in ref[:bus_gens][i]) -                 # sum of active power generation at bus i -
#         sum(load["pd"] for load in bus_loads) -                 # sum of active load consumption at bus i -
#         sum(shunt["gs"] for shunt in bus_shunts)*vm[i]^2        # sum of active shunt element injections at bus i
#     )
#
#     # Reactive power balance at node i
#     @constraint(model,
#         sum(q[a] for a in ref[:bus_arcs][i]) +                  # sum of reactive power flow on lines from bus i +
#         sum(q_dc[a_dc] for a_dc in ref[:bus_arcs_dc][i]) ==     # sum of reactive power flow on HVDC lines from bus i =
#         sum(qg[g] for g in ref[:bus_gens][i]) -                 # sum of reactive power generation at bus i -
#         sum(load["qd"] for load in bus_loads) +                 # sum of reactive load consumption at bus i -
#         sum(shunt["bs"] for shunt in bus_shunts)*vm[i]^2        # sum of reactive shunt element injections at bus i
#     )
# end
#
# # Branch power flow physics and limit constraints
# for (i,branch) in ref[:branch]
#     # Build the from variable id of the i-th branch, which is a tuple given by (branch id, from bus, to bus)
#     f_idx = (i, branch["f_bus"], branch["t_bus"])
#     # Build the to variable id of the i-th branch, which is a tuple given by (branch id, to bus, from bus)
#     t_idx = (i, branch["t_bus"], branch["f_bus"])
#     # note: it is necessary to distinguish between the from and to sides of a branch due to power losses
#
#     p_fr = p[f_idx]                     # p_fr is a reference to the optimization variable p[f_idx]
#     q_fr = q[f_idx]                     # q_fr is a reference to the optimization variable q[f_idx]
#     p_to = p[t_idx]                     # p_to is a reference to the optimization variable p[t_idx]
#     q_to = q[t_idx]                     # q_to is a reference to the optimization variable q[t_idx]
#     # note: adding constraints to p_fr is equivalent to adding constraints to p[f_idx], and so on
#
#     vm_fr = vm[branch["f_bus"]]         # vm_fr is a reference to the optimization variable vm on the from side of the branch
#     vm_to = vm[branch["t_bus"]]         # vm_to is a reference to the optimization variable vm on the to side of the branch
#     va_fr = va[branch["f_bus"]]         # va_fr is a reference to the optimization variable va on the from side of the branch
#     va_to = va[branch["t_bus"]]         # va_fr is a reference to the optimization variable va on the to side of the branch
#
#     # Compute the branch parameters and transformer ratios from the data
#     g, b = PowerModels.calc_branch_y(branch)
#     tr, ti = PowerModels.calc_branch_t(branch)
#     g_fr = branch["g_fr"]
#     b_fr = branch["b_fr"]
#     g_to = branch["g_to"]
#     b_to = branch["b_to"]
#     tm = branch["tap"]^2
#     # note: tap is assumed to be 1.0 on non-transformer branches
#
#
#     # AC Power Flow Constraints
#
#     # From side of the branch flow
#     @NLconstraint(model, p_fr ==  (g+g_fr)/tm*vm_fr^2 + (-g*tr+b*ti)/tm*(vm_fr*vm_to*cos(va_fr-va_to)) + (-b*tr-g*ti)/tm*(vm_fr*vm_to*sin(va_fr-va_to)) )
#     @NLconstraint(model, q_fr == -(b+b_fr)/tm*vm_fr^2 - (-b*tr-g*ti)/tm*(vm_fr*vm_to*cos(va_fr-va_to)) + (-g*tr+b*ti)/tm*(vm_fr*vm_to*sin(va_fr-va_to)) )
#
#     # To side of the branch flow
#     @NLconstraint(model, p_to ==  (g+g_to)*vm_to^2 + (-g*tr-b*ti)/tm*(vm_to*vm_fr*cos(va_to-va_fr)) + (-b*tr+g*ti)/tm*(vm_to*vm_fr*sin(va_to-va_fr)) )
#     @NLconstraint(model, q_to == -(b+b_to)*vm_to^2 - (-b*tr+g*ti)/tm*(vm_to*vm_fr*cos(va_fr-va_to)) + (-g*tr-b*ti)/tm*(vm_to*vm_fr*sin(va_to-va_fr)) )
#
#     # Voltage angle difference limit
#     @constraint(model, va_fr - va_to <= branch["angmax"])
#     @constraint(model, va_fr - va_to >= branch["angmin"])
#
#     # Apparent power limit, from side and to side
#     @constraint(model, p_fr^2 + q_fr^2 <= branch["rate_a"]^2)
#     @constraint(model, p_to^2 + q_to^2 <= branch["rate_a"]^2)
# end
#
#
# ###############################################################################
# # 3. Solve the Optimal Power Flow Model and Review the Results
# ###############################################################################
#
# # Solve the optimization problem
# optimize!(model)
# ###############################################################################
# # 4. Create Result Dictionary such that the PowerModels Results can be used by pandapower
# ###############################################################################
# solution =  Dict{String,Any}()
# push!(solution, "baseMVA" => data["baseMVA"])
# push!(solution, "per_unit" => data["per_unit"])
# push!(solution, "gen" => data["gen"])
# push!(solution, "bus" => data["bus"])
# push!(solution, "branch" => data["branch"])
# push!(solution, "multinetwork" => false)
# push!(solution, "multiinfrastructrue" => false)
#
# for (i, gen) in solution["gen"]
#     index = gen["index"]
#     gen["qg"] = value(model[:qg][index])
#     gen["pg"] = value(model[:pg][index])
# end
#
# for (i, bus) in solution["bus"]
#     index = bus["index"]
#     bus["vm"] = value(model[:vm][index])
#     bus["va"] = value(model[:va][index])
# end
#
# for (i, branch) in solution["branch"]
#     index = branch["index"]
#     push!(branch, "qf" => value(model[:q][(index, branch["f_bus"], branch["t_bus"])]))
#     push!(branch, "qt" => value(model[:q][(index, branch["t_bus"], branch["f_bus"])]))
#     push!(branch, "pf" => value(model[:p][(index, branch["f_bus"], branch["t_bus"])]))
#     push!(branch, "pt" => value(model[:p][(index, branch["t_bus"], branch["f_bus"])]))
# end
# println("The solver termination status is")
#
# result = Dict{String,Any}(
#         "optimizer" => JuMP.solver_name(model),
#         "termination_status" => JuMP.termination_status(model),   # "LOCALLY_SOLVED",
#         "primal_status" => JuMP.primal_status(model),
#         "dual_status" => JuMP.dual_status(model),
#         "objective" => InfrastructureModels._guard_objective_value(model),
#         "objective_lb" => InfrastructureModels._guard_objective_bound(model),
#         "solve_time" => solve_time,
#         "solution" => solution)
#
# return result
