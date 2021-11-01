using Test
using PandaModels; const _PdM = PandaModels
import PowerModels; const _PM = PowerModels

_PM.silence()

pdm_path = joinpath(dirname(pathof(PandaModels)), "..")
data_path = joinpath(pdm_path, "test", "data")

case_pm = joinpath(data_path, "test_pm.json")
case_pf = joinpath(data_path, "test_pf.json")
case_opf = joinpath(data_path, "test_opf.json")
case_custom = joinpath(data_path, "test_custom.json")
case_ots = joinpath(data_path, "test_ots.json")
case_tnep = joinpath(data_path, "test_tnep.json")
case_vd = joinpath(data_path, "test_vd.json")

@testset "PandaModels.jl" begin

        include("input.jl")
        include("call_powermodels.jl")
        include("vd.jl")
        
end
