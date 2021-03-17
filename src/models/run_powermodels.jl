
function run_powermodels(json_path)
    pm = load_pm_from_json(json_path)
    model = get_model(pm["pm_model"])

    solver = get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
                        pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"],
                        pm["pm_mip_time_limit"])

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

        result = _PM._run_opf_cl(pm, model, solver,
                                        setting = Dict("output" => Dict("branch_flows" => true)))
    else
        result = _PM.run_opf(pm, model, solver,
                                        setting = Dict("output" => Dict("branch_flows" => true)))
    end

    return result
end
