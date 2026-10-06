"""
serializes a result to a JSON string, so pandapower receives it in one transfer.
NaN and Inf are written as null, solver status codes as strings.
"""
json_result(result::Dict{String,<:Any}) = JSON.json(result)
