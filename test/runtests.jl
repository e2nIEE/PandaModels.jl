using Test
using PandaModels; const _PdM = PandaModels
import PowerModels; const _PM = PowerModels

_PM.silence()

test_path = joinpath(pwd(), "test")
json_path = joinpath(pwd(), "test", "data")

case_pm = joinpath(json_path, "test_pm.json")
case_pf = joinpath(json_path, "test_pf.json")
case_opf = joinpath(json_path, "test_opf.json")
case_custom = joinpath(json_path, "test_custom.json")
case_ots = joinpath(json_path, "test_ots.json")
case_tnep = joinpath(json_path, "test_tnep.json")

@testset "PandaModels.jl" begin
        @testset "test internal functions" begin
                pm = _PdM.load_pm_from_json(case_pm)

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
                        result=run_powermodels_opf(case_opf)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
                        @test isapprox(result["objective"], 144.85; atol = 1e0)
                        @test result["solve_time"] > 0.0
                end
                @testset "test for run_powermodels_powerflow" begin
                        result=run_powermodels_powerflow(case_pf)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
                        @test isapprox(result["objective"], 0.0; atol = 1e0)
                        @test result["solve_time"] > 0.0
                end
                @testset "test for powermodels_custom" begin
                        result=run_powermodels_custom(case_custom)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
                        @test isapprox(result["objective"], 144.85; atol = 1e0)
                        @test result["solve_time"] > 0.0
                end
                @testset "test for powermodels_tnep" begin
                        result=run_powermodels_tnep(case_tnep)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
                        @test isapprox(result["objective"], 0.0; atol = 1e0)
                        @test result["solve_time"] > 0.0
                end

                @testset "test for powermodels_ots" begin
                        result=run_powermodels_ots(case_ots)
                        @test isa(result, Dict{String,Any})
                        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
                        @test isapprox(result["objective"], 14810.0; atol = 100.0)
                        @test result["solve_time"] > 0.0
                end
        end
end
