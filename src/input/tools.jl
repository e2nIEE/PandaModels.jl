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
    for (i,branch) in pm["branch"]
        if "c_rating_a" in keys(branch)
            cl += 1
        end
    end
    return cl
end

# function calculate_current!(flows)
# # calculate branch current
# for (i, l) in flows["branch"]
#     flows["branch"][i]["if"] = abs(flows["branch"][i]["pt"] / 1 / sqrt(3))
#     flows["branch"][i]["it"] = abs(flows["branch"][i]["pf"] / 1 / sqrt(3))
#     flows["branch"][i]["i_ka"] = max.(flows["branch"][i]["if"], flows["branch"][i]["it"])
# end
