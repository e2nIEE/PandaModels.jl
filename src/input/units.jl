# Unit handling for data in MATPOWER units ("per_unit" => false), as sent by pandapower >= 3.6.
#
# Network data follows the PowerModels/MATPOWER convention (MW, MVAr, MWh, degrees, impedances in
# per unit on baseMVA). Besides the network, pandapower sends values PowerModels' make_per_unit!
# does not know about: generator start values, storage set points, time series and power-valued
# user_defined_params. All of them are converted here, and the solution is converted back to MW,
# MVAr and degrees before it is returned.
#
# Data with "per_unit" => true (older pandapower versions) is passed through unchanged.

# user_defined_params given in MW / MVAr
const _POWER_PARAMS = ("setpoint_p", "setpoint_q", "base_pg", "fixed_pg")
# user_defined_params given per MW
const _COST_PARAMS = ("redispatch_cost_up", "redispatch_cost_down")

is_mixed_units(pm::Dict{String,<:Any}) = get(pm, "per_unit", true) == false

converted_from_mixed_units(pm::Dict{String,<:Any}) = get(pm, "source_units", "") == "mixed"

function _rescale_values!(d::Dict{String,<:Any}, keys, func)
    for key in keys
        if haskey(d, key) && d[key] isa Number
            d[key] = func(d[key])
        end
    end
end

function _rescale_param!(param::Dict{String,<:Any}, func)
    for (k, v) in param
        if v isa Dict
            _rescale_values!(v, ("value",), func)
        elseif v isa Number
            param[k] = func(v)
        end
    end
end

"""
converts pandapower data in MATPOWER units to per unit (incl. time series and user_defined_params)
"""
function mixed_units_to_per_unit!(pm::Dict{String,<:Any})
    is_mixed_units(pm) || return pm
    base = pm["baseMVA"]
    to_pu = x -> x / base

    _PM.make_per_unit!(pm)

    for (_, gen) in pm["gen"]
        _rescale_values!(gen, ("pg_start", "qg_start"), to_pu)
    end
    for (_, strg) in get(pm, "storage", Dict{String,Any}())
        _rescale_values!(strg, ("ps", "qs"), to_pu)
    end

    if haskey(pm, "user_defined_params")
        params = pm["user_defined_params"]
        for key in _POWER_PARAMS
            haskey(params, key) && _rescale_param!(params[key], to_pu)
        end
        for key in _COST_PARAMS
            haskey(params, key) && _rescale_param!(params[key], x -> x * base)
        end
    end

    if haskey(pm, "time_series")
        for elm in ("load", "gen")
            for (_, variables) in get(pm["time_series"], elm, Dict{String,Any}())
                for (_, steps) in variables
                    for (step, value) in steps
                        steps[step] = to_pu(value)
                    end
                end
            end
        end
    end

    pm["source_units"] = "mixed"
    return pm
end

"""
converts a solution to MW, MVAr, MWh and degrees
"""
function solution_to_mixed_units!(result::Dict{String,<:Any})
    sol = result["solution"]
    _PM.make_mixed_units!(sol)
    networks = haskey(sol, "nw") ? collect(values(sol["nw"])) : [sol]
    for nw in networks
        base = nw["baseMVA"]
        for (_, strg) in get(nw, "storage", Dict{String,Any}())
            _rescale_values!(strg, ("ps", "qs", "qsc", "se", "sc", "sd"), x -> x * base)
        end
    end
    return result
end

"""
returns the result in the units the data was sent in
"""
function finalize_result!(result::Dict{String,<:Any}, pm::Dict{String,<:Any})
    converted_from_mixed_units(pm) && solution_to_mixed_units!(result)
    return result
end
