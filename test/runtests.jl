using Pkg
Pkg.activate(".")
# Pkg.instantiate()
# Pkg.add("InfrastructureModels")
# Pkg.add("Memento")
# Pkg.build()
# Pkg.resolve

using Test
using PyCall
using PandaModels; const _PdM = PandaModels
import PowerModels; const _PM = PowerModels
_PM.silence()

data_path = joinpath(pwd(), "test", "data")
test_path = joinpath(pwd(), "test")

push!(pyimport("sys")."path", test_path)
pyimport("create_test_json")

if ! occursin(joinpath(homedir(), ".julia", "dev", "PandaModels"), pathof(_PdM))
        json_path = tempdir()
else
        json_path = data_path
end

test_pm = joinpath(json_path, "test_pm.json") # 1gen, 82bus, 116branch, 177load, DCPPowerModel, solver:Ipopt
test_powerflow = joinpath(json_path, "test_powerflow.json")
test_powermodels_opf = joinpath(json_path, "test_powermodels_opf.json")
test_custom = joinpath(json_path, "test_powermodels_custom.json")
test_ots = joinpath(json_path, "test_ots.json")
test_tnep = joinpath(json_path, "test_tnep.json")
test_gurobi = joinpath(json_path, "test_gurobi.json")
test_mn_storage = joinpath(json_path, "test_mn_storage.json")
ts_path = joinpath(json_path, "timeseries.json")

# test_vd = joinpath(json_path, "pp_to_pm_user_params.json") # TODO: add this to create_test_json
# pm = _PdM.load_pm_from_json(test_vd)
# pm , user_defined_param = PdM.extract_params!(pm)
# result=run_powermodels_vd(test_vd)

# FIXME:
# py"""
# from pandapower import pp_dir
# import os
# import pytest
# test_dir=os.path.join(pp_dir, "test")
# sta = pytest.main([test_dir])
# """
# @testset "PandaModels.jl" begin
#     status = py"sta.value"
#     @test status == 0
# end

@testset "PandaModels.jl" begin
        @testset "test internal functions" begin
                pm = _PdM.load_pm_from_json(test_pm)

                @test length(pm["bus"]) == 6
                @test length(pm["gen"]) == 3
                @test length(pm["branch"]) == 7
                @test length(pm["load"]) == 3

                model =_PdM.get_model(pm["pm_model"])
                @test string(model) == "PowerModels.DCPPowerModel"

                solver = _PdM.get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
                pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"], pm["pm_mip_time_limit"])

                @test string(solver.optimizer_constructor) == "Ipopt.Optimizer"

        end

        @testset "test exported executive functions" begin
                @testset "test for run_powermodels" begin
                        result=run_powermodels_opf(test_powermodels_opf)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
                        @test isapprox(result["objective"], 144.85; atol = 1e0)
                        @test result["solve_time"] > 0.0
                end
                @testset "test for run_powermodels_powerflow" begin
                        result=run_powermodels_powerflow(test_powerflow)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
                        @test isapprox(result["objective"], 0.0; atol = 1e0)
                        @test result["solve_time"] > 0.0
                end
                @testset "test for powermodels_custom" begin
                        result=run_powermodels_custom(test_custom)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
                        @test isapprox(result["objective"], 144.85; atol = 1e0)
                        @test result["solve_time"] > 0.0
                end
                @testset "test for powermodels_tnep" begin
                        result=run_powermodels_tnep(test_tnep)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
                        @test isapprox(result["objective"], 0.0; atol = 1e0)
                        @test result["solve_time"] > 0.0
                end
                if Base.find_package("Gurobi") != nothing
                        @testset "test for Gurobi" begin
                                result=run_powermodels_tnep(test_gurobi)
                                @test isa(result, Dict{String,Any})
                                @test string(result["termination_status"]) == "OPTIMAL"
                                @test isapprox(result["objective"], 0.0; atol = 1e0)
                                @test result["solve_time"] > 0.0
                        end
                end
                @testset "test for powermodels_ots" begin
                        result=run_powermodels_ots(test_ots)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
                        @test isapprox(result["objective"], 14810.0; atol = 100.0)
                        @test result["solve_time"] > 0.0
                end
                # TODO: complete the model
                # @testset "test for powermodels_vt" begin
                #         @result=run_powermodels_vt(test_vt)
                #         @test string(result["termination_status"]) == "LOCALLY_SOLVED"
                #         @test isapprox(result["objective"], 0; atol = 1e0)
                #         @test result["solve_time"] > 0
                # end
                # FIXME: fix mn storage test
                # @testset "test for powermodels_mn_storage" begin
                #         result=run_powermodels_mn_storage(test_mn_storage, ts_path)
                #         @test isa(result, Dict{String,Any})
                #         @test string(result["termination_status"]) == "OPTIMAL"
                #         # @test isapprox(result["objective"], 0; atol = 1e0)
                #         @test result["solve_time"]>=0
                # end
        end
        if ! occursin(".julia/dev/PandaModels", pathof(_PdM))
                files = [test_pm, test_powerflow, test_powermodels_opf, test_custom, test_ots, test_tnep]
                @testset "remove temp files" begin
                        for fl in files
                                rm(fl, force=true)
                                @test !isfile(fl)
                        end
                end
        end

end
