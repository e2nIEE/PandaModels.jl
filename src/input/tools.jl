function extract_params!(pm)
    if haskey(pm, "user_defined_params")
        user_defined_params = pm["user_defined_params"]
        pm = delete!(pm, "user_defined_params")
    # else
    #     user_defined_param = NaN
    end
    return pm, user_defined_param
end
