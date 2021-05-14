function extract_params!(pm)
    if haskey(pm, "user_defined_params")
        user_defined_params = pm["user_defined_params"]
        pm = delete!(pm, "user_defined_params")
    # else
    #     user_defined_param = NaN
    end
    return pm, user_defined_param
end

# function get_path(;grid_code::String="1-HV-urban--0-sw")
#     simbench_path = joinpath(pwd(), "casedata", "simbench")
#     json_path = joinpath(simbench_path, grid_code, "$(grid_code).json");
#     ts_path = joinpath(simbench_path, grid_code, "load_p_ts.json");
#     return json_path, ts_path
# end
