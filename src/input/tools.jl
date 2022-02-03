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

# function read_time_series(ts_path)
#     time_series = Dict()
#     open(ts_path, "r") do f
#         time_series = JSON.parse(f)  # parse and transform data
#     end
#     return time_series
# end

function set_pq_values_from_timeseries(mn, time_series)
    # This function iterates over multinetwork entries and sets p, q values
    # of loads and "sgens" (which are loads with negative P and Q values)

    # iterate over networks (which represent the time steps)
    for (t, network) in mn["nw"]
        t_j = string(parse(Int64,t) - 1)
        # iterate over all loads for this network
        for (i, load) in network["load"]
            # update variables from time series here
#             print("\nload before: ")
#             print(load["pd"])
            load["pd"] = time_series[t_j][parse(Int64,i)] / mn["baseMVA"]
#             print("\nload after: ")
#             print(load["pd"])
        end
    end

    return mn
end
#
function read_ts_from_json(ts_path)
    if isfile(ts_path)
        time_series = Dict()
        open(ts_path, "r") do f
            time_series = JSON.parse(f)
        end
    else
        @error "no time series data is available at $(ts_path)"
    end
    return time_series
end
#
#
#
# function set_pq_from_timeseries!(mn, ts_data, variable)
#     for step = 1:steps
#         network = mn["nw"]["$(step)"]
#         for idx in keys(ts_data)
#             network["load"][idx][variable] =
#                 ts_data[idx]["$(step-1)"] / network["baseMVA"]
#         end
#     end
#     return mn
# end

# function calculate_current!(flows)
# # calculate branch current
# for (i, l) in flows["branch"]
#     flows["branch"][i]["if"] = abs(flows["branch"][i]["pt"] / 1 / sqrt(3))
#     flows["branch"][i]["it"] = abs(flows["branch"][i]["pf"] / 1 / sqrt(3))
#     flows["branch"][i]["i_ka"] = max.(flows["branch"][i]["if"], flows["branch"][i]["it"])
# end
