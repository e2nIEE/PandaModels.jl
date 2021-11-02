function run_powermodels_powerflow(json_path)
    _PM.silence()
    pm = load_pm_from_json(json_path)
    model = get_model(pm["pm_model"])

    solver = get_solver(
        pm["pm_solver"],
        pm["pm_nl_solver"],
        pm["pm_mip_solver"],
        pm["pm_log_level"],
        pm["pm_time_limit"],
        pm["pm_nl_time_limit"],
        pm["pm_mip_time_limit"],
    )

    result = _PM.run_pf(
        pm,
        model,
        solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
    )
    return result
end

function run_powermodels_opf(json_path)
    _PM.silence()
    pm = load_pm_from_json(json_path)
    model = get_model(pm["pm_model"])

    solver = get_solver(
        pm["pm_solver"],
        pm["pm_nl_solver"],
        pm["pm_mip_solver"],
        pm["pm_log_level"],
        pm["pm_time_limit"],
        pm["pm_nl_time_limit"],
        pm["pm_mip_time_limit"],
    )

    if haskey(pm["branch"]["1"], "c_rating_a")
        for (key, value) in pm["gen"]
            value["pmax"] = value["pmax"] * 0.01
            value["qmax"] = value["qmax"] * 0.01
            value["qmin"] = value["qmin"] * 0.01
            value["pg"] = value["pg"] * 0.01
            value["qg"] = value["qg"] * 0.01
            value["cost"] = value["pmax"] * 100
        end

        for (key, value) in pm["branch"]
            value["c_rating_a"] = value["c_rating_a"] * 0.01
        end

        for (key, value) in pm["load"]
            value["pd"] = value["pd"] * 0.01
            value["qd"] = value["qd"] * 0.01
        end

        result = _PM._run_opf_cl(
            pm,
            model,
            solver,
            setting = Dict("output" => Dict("branch_flows" => true)),
        )
    else
        result = _PM.run_opf(
            pm,
            model,
            solver,
            setting = Dict("output" => Dict("branch_flows" => true)),
        )
    end
    return result
end

function run_powermodels_custom(json_path)
    _PM.silence()
    pm = load_pm_from_json(json_path)

    _PM.correct_network_data!(pm)

    ipopt_solver = JuMP.optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0)

    result = _PM.run_ac_opf(
        pm,
        ipopt_solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
    )
    return result
end

function run_powermodels_tnep(json_path)
    _PM.silence()
    pm = load_pm_from_json(json_path)
    model = get_model(pm["pm_model"])

    solver = get_solver(
        pm["pm_solver"],
        pm["pm_nl_solver"],
        pm["pm_mip_solver"],
        pm["pm_log_level"],
        pm["pm_time_limit"],
        pm["pm_nl_time_limit"],
        pm["pm_mip_time_limit"],
    )

    result = _PM.run_tnep(
        pm,
        model,
        solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
    )
    return result
end

function run_powermodels_ots(json_path)
    _PM.silence()
    pm = load_pm_from_json(json_path)
    model = get_model(pm["pm_model"])

    solver = get_solver(
        pm["pm_solver"],
        pm["pm_nl_solver"],
        pm["pm_mip_solver"],
        pm["pm_log_level"],
        pm["pm_time_limit"],
        pm["pm_nl_time_limit"],
        pm["pm_mip_time_limit"],
    )

    result = _PM.run_ots(
        pm,
        model,
        solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
    )
    return result
end

function run_vd(json_path)
    _PM.silence()
    pm = load_pm_from_json(json_path)
    model = get_model(pm["pm_model"])

    solver = get_solver(
        pm["pm_solver"],
        pm["pm_nl_solver"],
        pm["pm_mip_solver"],
        pm["pm_log_level"],
        pm["pm_time_limit"],
        pm["pm_nl_time_limit"],
        pm["pm_mip_time_limit"],
    )

    result = _run_vd(
        pm,
        model,
        solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
        ext = extract_params!(pm),
    )
    return result
end
