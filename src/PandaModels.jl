module PandaModels

import JuMP
# import JuMP: @variable, @constraint, @NLexpression, @NLconstraint, @objective, @NLobjective, @expression, optimize!, Model

import InfrastructureModels; const _IM = InfrastructureModels

import PowerModels; const _PM = PowerModels
import PowerModels: ids, ref, var, con, sol, nw_id_default

# import PowerModelsAnnex; const _PMAx = PowerModelsAnnex
# import PowerModelsDistribution; const _PMD = PowerModelsDistribution
# import GasModels; const _GM = GasModels
# import PetroleumModels; const _PtM = PetroleumModels
# import WaterModels; const _WM = WaterModels

import Memento
const LOGGER = Memento.getlogger(PowerModels)

import JSON

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

# if !(@isdefined GRB_ENV)
#     const GRB_ENV = Gurobi.Env()
# end

export run_powermodels_opf,
    run_powermodels_ots,
    run_powermodels_tnep,
    run_powermodels_powerflow,
    run_powermodels_mn_storage,
    run_powermodels_custom,
    run_powermodels_vd # FIXME: fix the model

include("input/pp_to_pm.jl")
include("input/time_series.jl")
include("input/tools.jl")

include("models/vd.jl") # FIXME

include("models/call_powermodels.jl")

end
