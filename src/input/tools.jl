function extract_params!(pm)
    if haskey(pm, "user_defined_params")
        params = Dict{Symbol,Dict{String,Any}}()
        for key in keys(pm["user_defined_params"])
            params[Symbol(key)] = pm["user_defined_params"][key]
        end
        delete!(pm, "user_defined_params")
    end
    return params
end

function check_powermodels_data!(pm)
    if pm["correct_pm_network_data"]
        _PM.correct_network_data!(pm)
    end
    if haskey(pm, "simplify_net")
        if pm["simplify_net"]
            _PM.simplify_network!(pm)
            _PM.deactivate_isolated_components!(pm)
            _PM.propagate_topology_status!(pm)
        end
    end
    return pm
end

function active_powermodels_silence!(pm)
    if pm["silence"]
        _PM.silence()
    end
end

function check_current_limit!(pm)
    cl = 0
    for (i, branch) in pm["branch"]
        if "c_rating_a" in keys(branch)
            cl += 1
        end
    end
    return cl
end

function set_pq_values_from_timeseries(pm)
    # This function iterates over multinetwork entries and sets p, q values
    # of loads and "sgens" (which are loads with negative P and Q values)
    steps = pm["time_series"]["to_time_step"]-pm["time_series"]["from_time_step"]
    baseMVA = pm["baseMVA"]
    mn = _PM.replicate(pm, steps)

    for (step, network) in mn["nw"]
        step_1=string(parse(Int64,step) - 1)
        load_ts = pm["time_series"]["load"]
        network = delete!(network, "user_defined_params")
        for (idx, load) in network["load"]
            if haskey(load_ts, idx)
                load["pd"] = load_ts[idx]["p_mw"][step_1] / baseMVA
                if haskey(load_ts[idx], "q_mvar")
                    load["qd"] = load_ts[idx]["q_mvar"][step_1] / baseMVA
                end
            end
        end

        gen_ts = pm["time_series"]["gen"]
        for (idx, gen) in network["gen"]
            if haskey(gen_ts, idx)
                gen["pg"] = gen_ts[idx]["p_mw"][step_1] / baseMVA
                if haskey(gen_ts[idx], "max_p_mw")
                    gen["pmax"] = gen_ts[idx]["max_p_mw"][step_1] / baseMVA
                else
                    gen["pmax"] = gen_ts[idx]["p_mw"][step_1] / baseMVA
                end
                if haskey(gen_ts[idx], "min_p_mw")
                    gen["pmin"] = gen_ts[idx]["min_p_mw"][step_1] / baseMVA
                else
                    gen["pmin"] = gen_ts[idx]["p_mw"][step_1] / baseMVA
                end

                if haskey(gen_ts[idx], "max_q_mvar")
                    gen["qmax"] = gen_ts[idx]["max_q_mvar"][step_1]
                end
                if haskey(gen_ts[idx], "min_q_mvar")
                    gen["qmin"] = gen_ts[idx]["min_q_mvar"][step_1]
                end
                if haskey(gen_ts[idx], "q_mvar")
                    gen["qg"] = gen_ts[idx]["q_mvar"][step_1]
                end
            end
        end
    end
    return mn
end
