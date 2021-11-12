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
