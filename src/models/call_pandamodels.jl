function run_pandamodels_vstab(json_path)
    pm = load_pm_from_json(json_path)
    active_powermodels_silence!(pm)
    pm = check_powermodels_data!(pm)
    model = get_model(pm["pm_model"])
    solver = get_solver(pm)

    result = _run_vstab(
        pm,
        model,
        solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
        ext = extract_params!(pm),
    )
    return result
end

function run_pandamodels_multi_vstab(json_path)
    pm = load_pm_from_json(json_path)
    active_powermodels_silence!(pm)
    pm = check_powermodels_data!(pm)
    model = get_model(pm["pm_model"])
    solver = get_solver(pm)
    mn = set_pq_values_from_timeseries(pm)

    result = _run_multi_vstab(
        mn,
        model,
        solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
        ext = extract_params!(pm),
    )
    return result
end

function run_pandamodels_qflex(json_path)
    pm = load_pm_from_json(json_path)
    active_powermodels_silence!(pm)
    pm = check_powermodels_data!(pm)
    model = get_model(pm["pm_model"])
    solver = get_solver(pm)

    result = _run_qflex(
        pm,
        model,
        solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
        ext = extract_params!(pm),
    )
    return result
end

function run_pandamodels_multi_qflex(json_path)
    pm = load_pm_from_json(json_path)
    active_powermodels_silence!(pm)
    pm = check_powermodels_data!(pm)
    model = get_model(pm["pm_model"])
    solver = get_solver(pm)
    mn = set_pq_values_from_timeseries(pm)

    result = _run_multi_qflex(
        mn,
        model,
        solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
        ext = extract_params!(pm),
    )
    return result
end
