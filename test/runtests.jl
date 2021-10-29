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
case_vd2 = joinpath(data_path, "test_vd_2.json")

# pm = _PdM.load_pm_from_json(case_vd2)
# model = _PdM.get_model(pm["pm_model"])
#
# solver = _PdM.get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
# pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"], pm["pm_mip_time_limit"])
#
# result = _PdM._run_vd(pm, model, solver,
#                     setting = Dict("output" => Dict("branch_flows" => true)),
#                     ext = _PdM.extract_params!(pm))

@testset "PandaModels.jl" begin

        include("input.jl")
        include("call_powermodels.jl")
        include("vd.jl")

end
