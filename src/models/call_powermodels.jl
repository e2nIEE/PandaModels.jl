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

    result = _PM.run_opf(pm, model, solver,
                                   setting = Dict("output" => Dict("branch_flows" => true)))

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

function run_powermodels_mn_storage(json_path, ts_file=nothing)
    pm = load_pm_from_json(json_path)
    model = get_model(pm["pm_model"])

    solver = get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
    pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"], pm["pm_mip_time_limit"])

    # copy network n_time_steps time step times
    n_time_steps = pm["n_time_steps"]
    mn = _PM.replicate(pm, pm["n_time_steps"])
    mn["time_elapsed"] = pm["time_elapsed"]
    mn["baseMVA"] = pm["baseMVA"]

    # set P, Q values of loads and generators from time series
    if !isnothing(ts_file)
        ts_data = read_time_series(ts_file)
        mn = set_pq_values_from_timeseries(mn, ts_data)
    elseif isfile(joinpath(tempdir(), "timeseries.json"))
        ts_data = read_time_series(joinpath(tempdir(), "timeseries.json"))
        mn = set_pq_values_from_timeseries(mn, ts_data)
    else
        print("Running storage without time series") # TODO: raise error
    end

    # TODO:why only ipopt and ac?
    ipopt_solver = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0)

    # run multinetwork storage opf
    # result = _PM.run_mn_opf_strg(mn, _PM.ACPPowerModel, ipopt_solver)
    result = _PM.run_mn_opf_strg(mn, model, solver)
    # TODO: set this as an option
    # print_summary(result)
    return result
end
