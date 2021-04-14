# Call run_powermodels functions:
# run_powermodels_powerflow
# run_powermodels #TODO: change the name: run_powermodels_opf
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

    result = _PM.run_pf(pm, model, solver)
    
    # add line flow to result
    _PM.update_data!(pm, result["solution"])
    line_flow = _PM.calc_branch_flow_ac(pm)
    _PM.update_data!(result["solution"], line_flow)

    return result
end

function run_powermodels(json_path)
    pm = load_pm_from_json(json_path)
    model = get_model(pm["pm_model"])

    solver = get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
    pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"], pm["pm_mip_time_limit"])

    if haskey(pm["branch"]["1"],"c_rating_a")
        for (key, value) in pm["gen"]
           # value["pmin"] = 0
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

        # pm["bus"]["4"]["vmax"] = 1.1
        # pm["bus"]["4"]["vmin"] = 0.9

        result = _PM._run_opf_cl(pm, model, solver,
                                        setting = Dict("output" => Dict("branch_flows" => true)))
    else
        result = _PM.run_opf(pm, model, solver,
                                        setting = Dict("output" => Dict("branch_flows" => true)))
    end

    return result
end


function run_powermodels_custom(json_path)
    pm = load_pm_from_json(json_path)

    _PM.correct_network_data!(pm)

    ipopt_solver = JuMP.with_optimizer(Ipopt.Optimizer, print_level=0)

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


function read_time_series(json_path)
    time_series = Dict()
    open(json_path, "r") do f
        time_series = JSON.parse(f)
    end
    return time_series
end

function set_pq_values_from_timeseries(mn, time_series)
    # This function iterates over multinetwork entries and sets p, q values
    # of loads and "sgens" (which are loads with negative P and Q values)

    # iterate over networks (which represent the time steps)
    for (t, network) in mn["nw"]
        t_j = string(parse(Int64,t) - 1)
        # iterate over all loads for this network
        for (i, load) in network["load"]

            load["pd"] = time_series[t_j][parse(Int64,i)] / mn["baseMVA"]

        end
    end

    return mn
end

function run_powermodels_mn_storage(json_path)
    # load converted pandapower network
    pm = load_pm_from_json(json_path)
    # copy network n_time_steps time step times
    n_time_steps = pm["n_time_steps"]
    mn = _PM.replicate(pm, pm["n_time_steps"])
    mn["time_elapsed"] = pm["time_elapsed"]
    # set P, Q values of loads and generators from time series
    if isfile("/tmp/timeseries.json")
        time_series = read_time_series("/tmp/timeseries.json")
        mn = set_pq_values_from_timeseries(mn, time_series)
    else
        print("Running storage without time series")
    end

    ipopt_solver = JuMP.with_optimizer(Ipopt.Optimizer, print_level = 0)

    # run multinetwork storage opf
    result = _PM._run_mn_strg_opf(mn, _PM.ACPPowerModel, ipopt_solver)
    print_summary(result)
    return result
end
