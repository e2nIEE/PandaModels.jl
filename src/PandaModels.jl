module PandaModels

import JuMP
import JSON

import PowerModels
const _PM = PowerModels

import Cbc
import Ipopt
import Juniper

try
    import Gurobi
catch e
    if isa(e, ArgumentError)
        println("Cannot import Gurobi. That's fine if you do not plan to use it")
    end
end

export run_powermodels,
    run_powermodels_ots,
    run_powermodels_tnep,
    run_powermodels_powerflow,
    run_powermodels_mn_storage,
    run_powermodels_custom

include("input/pp_to_pm.jl")
include("models/call_powermodels.jl")

end
