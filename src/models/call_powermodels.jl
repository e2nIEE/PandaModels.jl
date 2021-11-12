# function run_powermodels_pf_nativ(json_path)
#
#     active_powermodels_silence!(pm)
#
#     pm = load_pm_from_json(json_path)
#     model = pm["pm_model"]
#
#     # add result to net data
#     _PM.update_data!(pm, result["solution"])
#
#     # calculate branch power flows
#     if pm["pm_model"] == "ACNativ"
#         _PM.compute_ac_pf(pm)
#         # add result to net data
#         _PM.update_data!(pm, result["solution"])
#         flows = _PM.calc_branch_flow_ac(pm)
#     elseif pm["pm_model"] == "DCNativ":
#         _PM.compute_dc_pf(pm)
#         # add result to net data
#         _PM.update_data!(pm, result["solution"])
#         flows = _PM.calc_branch_flow_dc(pm)
#     end
#
#     # add flow to net and result
#     _PM.update_data!(result["solution"], flows)
#     _PM.update_data!(pm, flows)
#
#     return result
# end

function run_powermodels_pf(json_path)
    pm = load_pm_from_json(json_path)
    active_powermodels_silence!(pm)
    pm = check_powermodels_data!(pm)
    model = get_model(pm["pm_model"])
    solver = get_solver(pm)

    result = _PM.run_pf(
        pm,
        model,
        solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
    )

    # add result to net data
    _PM.update_data!(pm, result["solution"])
    # calculate branch power flows
    if string(model) == "PowerModels.ACPPowerModel"
        flows = _PM.calc_branch_flow_ac(pm)
    else
        flows = _PM.calc_branch_flow_dc(pm)
    end
    # add flow to net and result
    _PM.update_data!(result["solution"], flows)
    _PM.update_data!(pm, flows)

    return result
end

function run_powermodels_opf(json_path)
    pm = load_pm_from_json(json_path)
    active_powermodels_silence!(pm)
    pm = check_powermodels_data!(pm)
    model = get_model(pm["pm_model"])
    solver = get_solver(pm)

        result = _PM.run_opf(
            pm,
            model,
            solver,
            setting = Dict("output" => Dict("branch_flows" => true)),
        )

    return result
end

# function run_powermodels_opf_current_limit(json_path)
#
#     active_powermodels_silence!(pm)
#
#     pm = load_pm_from_json(json_path)
#     model = get_model(pm["pm_model"])
#
#     solver = get_solver(pm)
#
#     if haskey(pm["branch"]["1"], "c_rating_a")
#         for (key, value) in pm["gen"]
#             # value["pmin"] = 0
#             value["pmax"] *= 0.01
#             value["qmax"] *= 0.01
#             value["qmin"] *= 0.01
#             value["pg"] *= 0.01
#             value["qg"] *= 0.01
#             value["cost"] *= 100
#         end
#
#         for (key, value) in pm["branch"]
#             value["c_rating_a"] *= 0.01
#         end
#
#         for (key, value) in pm["load"]
#             value["pd"] *= 0.01
#             value["qd"] *= 0.01
#         end
#
#         result = _PM._run_opf_cl(
#             pm,
#             model,
#             solver,
#             setting = Dict("output" => Dict("branch_flows" => true)),
#         )
#
#     return result
# end

# function run_powermodels_custom(json_path)
#
#     pm = load_pm_from_json(json_path)
#
#     active_powermodels_silence!(pm)
#     pm = check_powermodels_data!(pm)
#
#     model = get_model(pm["pm_model"])
#     solver = get_solver(pm)
#
#     result = _PM.run_pf(pm, model, solver)
#     # add branch flows
#     _PM.update_data!(pm, result["solution"])
#     flows = _PM.calc_branch_flow_ac(pm)
#     _PM.update_data!(result["solution"], flows)
#     return result
# end

function run_powermodels_tnep(json_path)
    pm = load_pm_from_json(json_path)
    active_powermodels_silence!(pm)
    pm = check_powermodels_data!(pm)
    model = get_model(pm["pm_model"])
    solver = get_solver(pm)

    result = _PM.run_tnep(
        pm,
        model,
        solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
    )
    return result
end

function run_powermodels_ots(json_path)
    pm = load_pm_from_json(json_path)
    active_powermodels_silence!(pm)
    pm = check_powermodels_data!(pm)
    model = get_model(pm["pm_model"])
    solver = get_solver(pm)

    result = _PM.run_ots(
        pm,
        model,
        solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
    )
    return result
end
