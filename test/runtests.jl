using Pkg
Pkg.activate(".")

using Test
using PyCall
using PandaModels

const _PdM = PandaModels


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

test_path = abspath(joinpath(pathof(_PdM),"..","..","test"))

if ! occursin(".julia/dev/PandaModels", pathof(_PdM))
        include(joinpath(test_path, "create_test_json.jl")) #TODO:should produce following files
else
        test_path = joinpath(test_path, "data")
end

test_pm = joinpath(test_path, "test_pm.json") # 1gen, 82bus, 116branch, 177load, DCPPowerModel, solver:Ipopt
test_powerflow = joinpath(test_path, "test_powerflow.json")
test_powermodels = joinpath(test_path, "test_powermodels.json")
test_custom = joinpath(test_path, "test_powermodels_custom.json")
test_ots = joinpath(test_path, "test_ots.json")
test_tnep = joinpath(test_path, "test_tnep.json")
test_mn_storage = joinpath(test_path, "test_mn_storage.json")
# #
@testset "PandaModels.jl" begin
        @testset "test internal functions" begin
                # simbench grid 1-HV-urban--0-sw with ipopt solver
                json_path = test_powermodels
                pm = _PdM.load_pm_from_json(json_path)

                @test length(pm["bus"]) == 82
                @test length(pm["gen"]) == 1
                @test length(pm["branch"]) == 116
                @test length(pm["load"]) == 177

                model =_PdM.get_model(pm["pm_model"])
                @test string(model) == "PowerModels.DCPPowerModel"

                solver = _PdM.get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
                pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"], pm["pm_mip_time_limit"])

                @test string(solver.optimizer_constructor) == "Ipopt.Optimizer"

        end

        @testset "test exported executive functions" begin
                @testset "test for run_powermodels" begin
                        json_path = test_powermodels
                        result=run_powermodels(json_path)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
                        @test isapprox(result["objective"], -96.1; atol = 1e0)
                        @test result["solve_time"] >= 0
                end
                @testset "test for run_powermodels_powerflow" begin
                        json_path = test_powerflow
                        result=run_powermodels_powerflow(json_path)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "OPTIMAL"
                        @test isapprox(result["objective"], 0; atol = 1e0)
                        @test result["solve_time"]>=0
                end
                @testset "test for powermodels_custom" begin
                        json_path = test_custom
                        result=run_powermodels_custom(json_path)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "OPTIMAL"
                        # @test isapprox(result["objective"], 0; atol = 1e0)
                        @test result["solve_time"]>=0
                end
                @testset "test for powermodels_tnep" begin
                        json_path = test_tnep
                        result=run_powermodels_custom(json_path)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "OPTIMAL"
                        # @test isapprox(result["objective"], 0; atol = 1e0)
                        @test result["solve_time"]>=0
                end
                @testset "test for powermodels_ots" begin
                        json_path = test_ots
                        result=run_powermodels_custom(json_path)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "OPTIMAL"
                        # @test isapprox(result["objective"], 0; atol = 1e0)
                        @test result["solve_time"]>=0
                end
                @testset "test for powermodels_mn_storage" begin
                        json_path = test_mn_storage
                        result=run_powermodels_custom(json_path)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "OPTIMAL"
                        # @test isapprox(result["objective"], 0; atol = 1e0)
                        @test result["solve_time"]>=0
                end
        end
        if ! occursin(".julia/dev/PandaModels", pathof(_PdM))
                files =[test_pm, test_powerflow, test_powermodels, test_custom, test_ots, test_tnep test_mn_storage]
                @testset "remove temp files" begin
                for fl in files
                        rm(fl, force=true)
                        @test !isfile(fl)
                end
                end
        end

end
