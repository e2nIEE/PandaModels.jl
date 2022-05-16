# import Pkg  #only for local test
# Pkg.activate(".")  #only for local test
# Pkg.update()  # only for local test
# Pkg.resolve()  #only for local test
using Test
using PandaModels; const _PdM = PandaModels
import PowerModels; const _PM = PowerModels

_PM.silence()

pdm_path = joinpath(dirname(pathof(PandaModels)), "..")
data_path = joinpath(pdm_path, "test", "data")
ts_path = joinpath(data_path, "cigre_timeseries_15min.json")
case_pm = joinpath(data_path, "test_pm.json")
case_pf_ac = joinpath(data_path, "test_pf_ac.json")
case_pf_ac_native = joinpath(data_path, "test_pf_ac_native.json")
case_pf_dc_native = joinpath(data_path, "test_pf_dc_native.json")
case_opf_ac = joinpath(data_path, "test_opf_ac.json")
case_opf_cl = joinpath(data_path, "test_opf_cl.json")
case_tnep_ac = joinpath(data_path, "test_tnep_ac.json")
case_ots_dc = joinpath(data_path, "test_ots_dc.json")
case_vstab = joinpath(data_path, "test_vstab.json")
case_qflex = joinpath(data_path, "test_qflex.json")
case_multi_vstab = joinpath(data_path, "cigre_with_timeseries.json")

@testset "PandaModels.jl" begin

        include("input.jl")
        include("call_powermodels.jl")
        include("call_pandamodels.jl")

end
