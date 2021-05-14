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
    #
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
