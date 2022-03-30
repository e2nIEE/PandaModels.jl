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

function run_pandamodels_v_stab_ts(json_path)
    pm = load_pm_from_json(json_path)
    active_powermodels_silence!(pm)
    pm = check_powermodels_data!(pm)
    model = get_model(pm["pm_model"])
    solver = get_solver(pm)
    # check time series
    # if haskey(pm, "time_series")
    #     n_time_steps = pm["time_series"]["to_time_step"]-pm["time_series"]["from_time_step"]
    #     if n_time_steps <=1
    #         println("Only one time step is given. please use optimiztion without time series")
    #     end
    # else:
    #     println("No time series are given. please use optimization without time series")
    # end
    mn = set_pq_values_from_timeseries(pm)

    result = _run_v_stab_ts(
        mn,
        model,
        solver,
        setting = Dict("output" => Dict("branch_flows" => true)),
        ext = extract_params!(pm),
    )
    return result
end

function run_pandamodels_q_flex(json_path)
    # json_path="D:\\PROJECTS\\RPC2\\char_curve_calc\\char_curve_calc\\development\\sb_pp_to_pm_wiyny9nw.json"
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

function run_pandamodels_q_flex_ts(json_path)
    # json_path="D:\\PROJECTS\\RPC2\\char_curve_calc\\char_curve_calc\\development\\sb_pp_to_pm_wiyny9nw.json"
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
