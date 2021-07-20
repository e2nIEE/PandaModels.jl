function read_ts_from_json(ts_path)
    if isfile(ts_path)
        time_series  = Dict()
        open(ts_path, "r") do f
            time_series  = JSON.parse(f)
        end
    else
        @error "no time series data is available at $(ts_path)"
    end
    return time_series
end

function set_pq_from_timeseries!(mn, ts_data, variable)
    for step in 1:steps
        network = mn["nw"]["$(step)"]
        for idx in keys(ts_data)
            network["load"][idx][variable] = ts_data [idx]["$(step-1)"] / network["baseMVA"]
        end
    end
    return mn
end
