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
