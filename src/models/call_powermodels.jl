# Call run_powermodels functions:
# run_powermodels_powerflow
# run_powermodels
# run_powermodels_custom
# run_powermodels_tnep
# run_powermodels_ots
# run_powermodels_mn_storage
#

function run_powermodels_powerflow(json_path)
    pm = load_pm_from_json(json_path)
    model = get_model(pm["pm_model"])

    solver = get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
    pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"], pm["pm_mip_time_limit"])

    # result = _PM.run_pf(pm, model, solver)
    # _PM.update_data!(pm, result["solution"])
    # line_flow = _PM.calc_branch_flow_ac(pm)
    # _PM.update_data!(result["solution"], line_flow)
    result = _PM.run_pf(pm, model, solver,
                                setting = Dict("output" => Dict("branch_flows" => true)))
    return result
end


function run_powermodels_opf(json_path)
    pm = load_pm_from_json(json_path)
    model = get_model(pm["pm_model"])

    solver = get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
    pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"], pm["pm_mip_time_limit"])

    if haskey(pm["branch"]["1"],"c_rating_a")
        for (key, value) in pm["gen"]
           value["pmax"] *= 0.01
           value["qmax"] *= 0.01
           value["qmin"] *= 0.01
           value["pg"] *= 0.01
           value["qg"] *= 0.01
           value["cost"] *= 100
        end

        for (key, value) in pm["branch"]
           value["c_rating_a"] *= 0.01
        end

        for (key, value) in pm["load"]
           value["pd"] *= 0.01
           value["qd"] *= 0.01
        end

        result = PowerModels._run_opf_cl(pm, model, solver,
                                        setting = Dict("output" => Dict("branch_flows" => true)))
    else
        result = PowerModels.run_opf(pm, model, solver,
                                        setting = Dict("output" => Dict("branch_flows" => true)))
    end
    return result
end

# TODO: usage?
function run_powermodels_custom(json_path)
    pm = load_pm_from_json(json_path)

    _PM.correct_network_data!(pm)

    ipopt_solver = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0)

    result = _PM.run_ac_opf(pm, ipopt_solver,
                            setting = Dict("output" => Dict("branch_flows" => true)))
    return result
end

function run_powermodels_tnep(json_path)
    pm = load_pm_from_json(json_path)
    model = get_model(pm["pm_model"])

    solver = get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
    pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"], pm["pm_mip_time_limit"])

    result = _PM.run_tnep(pm, model, solver,
                        setting = Dict("output" => Dict("branch_flows" => true)))
    return result
end

function run_powermodels_ots(json_path)
    pm = load_pm_from_json(json_path)
    model = get_model(pm["pm_model"])

    solver = get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
    pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"], pm["pm_mip_time_limit"])

    result = _PM.run_ots(pm, model, solver,
                        setting = Dict("output" => Dict("branch_flows" => true)))
    return result
end

# # TODO: complete the model
# function run_powermodels_vd(json_path)
#     pm = load_pm_from_json(json_path)
#     model = get_model(pm["pm_model"])
#
#     solver = get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
#     pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"], pm["pm_mip_time_limit"])
#
#     result = run_vd(pm, model, solver,
#                         setting = Dict("output" => Dict("branch_flows" => true)))
#     return result
# end

# FIXME: the test doesnt pass!
# function run_powermodels_mn_storage(files)
#
#     pm = load_pm_from_json(files["net"])
#     model = get_model(pm["pm_model"])
#
#     solver = get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
#     pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"], pm["pm_mip_time_limit"])
#
#     steps = pm["n_time_steps"]
#
#     mn = _PM.replicate(pm, steps)
#
#     for key in keys(files)
#         if key != "net"
#             ts_data = read_time_series(files[key])
#             if key == "load_p"
#                 mn = set_pq_from_timeseries!(mn, ts_data, "pd")
#             elseif key == "load_q"
#                 mn = set_pq_from_timeseries!(mn, ts_data, "qd")
#             end
#         end
#     end
#
#     result = _PM.run_mn_opf_strg(mn, model, solver, setting = Dict("output" => Dict("branch_flows" => true)))
#
#     # pm_res = get_result_for_pandapower(result)
#     return result
# end
