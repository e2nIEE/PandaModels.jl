function run_pandamodels_vd(json_path)
    pm = load_pm_from_json(json_path)
    active_powermodels_silence!(pm)
    pm = check_powermodels_data!(pm)
    model = get_model(pm["pm_model"])
    solver = get_solver(pm)

    result = _run_vd(
        pm,
        model,
        solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
        ext = extract_params!(pm),
    )
    return result
end

function run_pandamodels_mn_vd(json_path)
    pm = load_pm_from_json(json_path)
    active_powermodels_silence!(pm)
    pm = check_powermodels_data!(pm)
    model = get_model(pm["pm_model"])
    solver = get_solver(pm)
    n_time_steps = pm["n_time_steps"]
    mn = _PM.replicate(pm, pm["n_time_steps"])

    if isfile("/tmp/timeseries.json")
        time_series = read_time_series("/tmp/timeseries.json")
        mn = set_pq_values_from_timeseries(mn, time_series)
    else
        print("Running storage without time series")
    end
    
    result = _run_mn_vd(
        pm,
        model,
        solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
        ext = extract_params!(pm),
    )
    return result
end

function run_pandamodels_q_flex(json_path)
    pm = load_pm_from_json(json_path)
    active_powermodels_silence!(pm)
    pm = check_powermodels_data!(pm)
    model = get_model(pm["pm_model"])
    solver = get_solver(pm)

    result = _run_q_flex(
        pm,
        model,
        solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
        ext = extract_params!(pm),
    )
    return result
end
