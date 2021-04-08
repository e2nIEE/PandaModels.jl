using Pkg
Pkg.activate(".")

using Test
using PyCall
using PandaModels

const _PdM = PandaModels

py"""
import pandapower.test
pandapower.test.run_all_tests()
"""

# TODO: change test file to pass all executive tests
# test_path=joinpath(pwd(), "data")
#
# # test_net = joinpath(test_path, "pm_test.json")
# # test_ipopt = joinpath(test_path, "test_ipopt.json")
# # test_Gurobi = joinpath(test_path, "test_Gurobi.json") #use gurobi to solve
# # test_ots = joinpath(test_path, "test_ots.json")
# # test_tnep = joinpath(test_path, "test_tnep.json")
# #
# @testset "PandaModels.jl" begin
#         @testset "test internal functions" begin
#                 # simbench grid 1-HV-urban--0-sw with ipopt solver
#                 json_path = joinpath(test_path, "test_ipopt.json")
#                 pm = _PdM.load_pm_from_json(json_path)
#
#                 @test length(pm["bus"]) == 82
#                 @test length(pm["gen"]) == 1
#                 @test length(pm["branch"]) == 116
#                 @test length(pm["load"]) == 177
#
#                 model =_PdM.get_model(pm["pm_model"])
#                 @test string(model) == "PowerModels.DCPPowerModel"
#
#                 solver = _PdM.get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
#                 pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"], pm["pm_mip_time_limit"])
#
#                 @test string(solver.optimizer_constructor) == "Ipopt.Optimizer"
#
#         end
#
#         @testset "test exported executive functions" begin
#                 @testset "test for Ipopt" begin
#                         json_path = joinpath(test_path, "test_ipopt.json")
#                         result=run_powermodels(json_path)
#                         @test isa(result, Dict{String,Any})
#                         @test string(result["termination_status"]) == "LOCALLY_SOLVED"
#                         @test isapprox(result["objective"], -96.1; atol = 1e0)
#                         @test result["solve_time"] >= 0
#                 end
#                 @testset "test for Gurobi" begin
#                         json_path = joinpath(test_path, "test_Gurobi.json")
#                         result=run_powermodels_powerflow(json_path)
#                         @test isa(result, Dict{String,Any})
#                         @test string(result["termination_status"]) == "OPTIMAL"
#                         @test isapprox(result["objective"], 0; atol = 1e0)
#                         @test result["solve_time"]>=0
#                 end
#         end
# end
#
# # result=run_powermodels_mn_storage(test_Gurobi)
# # @test isa(result, Dict{String,Any})
# # @test result["solve_time"]>=0
# # result=run_powermodels_ots(test_ots)
# # @test isa(result, Dict{String,Any})
# # string(result["termination_status"]) == "LOCALLY_SOLVED"
# # @test result["solve_time"]>=0
# # result=run_powermodels_tnep(test_tnep)
# # @test isa(result, Dict{String,Any})
# # string(result["termination_status"]) == "LOCALLY_SOLVED"
# # @test result["solve_time"]>=0
