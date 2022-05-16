# import Pkg
# Pkg.activate(".")
using Test
using PandaModels; const _PdM = PandaModels
import PowerModels; const _PM = PowerModels

_PM.silence()

pdm_path = joinpath(dirname(pathof(PandaModels)), "..")
data_path = joinpath(pdm_path, "test", "data")
case_ts = joinpath(data_path, "cigre_with_timeseries.json")
case_ts = joinpath(data_path, "test_mn_qflex.json")


##
###### --------------- call multi (time-series) optimization
pm = _PdM.load_pm_from_json(case_ts)
_PdM.active_powermodels_silence!(pm)
pm = _PdM.check_powermodels_data!(pm)
model = _PdM.get_model(pm["pm_model"])
solver = _PdM.get_solver(pm)
# add time series to mn
mn = _PdM.set_pq_values_from_timeseries(pm)

result_mn = _PdM._run_multi_qflex(
    mn,
    model,
    solver,
    setting = Dict("output" => Dict("branch_flows" => true)),
    ext = _PdM.extract_params!(pm))

###### ------------------ call normal optimization
pm = _PdM.load_pm_from_json(case_ts)
_PdM.active_powermodels_silence!(pm)
pm = _PdM.check_powermodels_data!(pm)
model = _PdM.get_model(pm["pm_model"])
solver = _PdM.get_solver(pm)

result = _PdM._run_qflex(
    pm,
    model,
    solver,
    setting = Dict("output" => Dict("branch_flows" => true)),
    ext = _PdM.extract_params!(pm))

###### ------------------ comparison
println("--------------------")
println("objective:", result["objective"])
println("mn_objective:", result_mn["objective"])
