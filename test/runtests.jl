using PandaModels
using Test

# TODO: change test file to pass all executive tests

test_path=joinpath(pwd(), "data")

test_net=joinpath(test_path, "pm_test.json")
test_ipopt = joinpath(test_path, "test_ipopt.json")
test_Gurobi = joinpath(test_path, "test_Gurobi.json") #use gurobi to solve
test_ots = joinpath(test_path, "test_ots.json")
test_tnep = joinpath(test_path, "test_tnep.json")

@testset "PandaModels.jl" begin
        @testset "test internal functions" begin
                # simbench grid 1-HV-urban--0-sw with ipopt solver
                pm = PandaModels.load_pm_from_json(test_ipopt)

                @test length(pm["bus"]) == 82
                @test length(pm["gen"]) == 1
                @test length(pm["branch"]) == 116
                @test length(pm["load"]) == 177

                model = PandaModels.get_model(pm["pm_model"])
                @test string(model) == "PowerModels.DCPPowerModel"

                solver = PandaModels.get_solver(pm["pm_solver"], pm["pm_nl_solver"], pm["pm_mip_solver"],
                pm["pm_log_level"], pm["pm_time_limit"], pm["pm_nl_time_limit"], pm["pm_mip_time_limit"])

                @test string(solver.optimizer_constructor) == "Ipopt.Optimizer"

        end

        @testset "test exported executive functions" begin

                result=run_powermodels(test_ipopt)
                @test isa(result, Dict{String,Any})
                @test string(result["termination_status"]) == "LOCALLY_SOLVED"
                @test isapprox(result["objective"], -96.1; atol = 1e0)
                @test result["solve_time"] >= 0
                # result=run_powermodels_mn_storage(test_Gurobi)
                # @test isa(result, Dict{String,Any})
                # @test result["solve_time"]>=0
                # result=run_powermodels_ots(test_ots)
                # @test isa(result, Dict{String,Any})
                # string(result["termination_status"]) == "LOCALLY_SOLVED"
                # @test result["solve_time"]>=0
                result=run_powermodels_powerflow(test_Gurobi)
                @test isa(result, Dict{String,Any})
                string(result["termination_status"]) == "OPTIMAL"
                @test isapprox(result["objective"], 0; atol = 1e0)
                @test result["solve_time"]>=0
                # result=run_powermodels_tnep(test_tnep)
                # @test isa(result, Dict{String,Any})
                # string(result["termination_status"]) == "LOCALLY_SOLVED"
                # @test result["solve_time"]>=0
        end
end
