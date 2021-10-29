@testset "test exported executive functions" begin

        @testset "test for run_powermodels" begin
                result = run_powermodels_opf(case_opf)
                @test isa(result, Dict{String,Any})
                @test string(result["termination_status"]) ==
                      "LOCALLY_SOLVED"
                @test isapprox(result["objective"], 144.85; atol = 1e0)
                @test result["solve_time"] > 0.0
        end

        @testset "test for run_powermodels_powerflow" begin
                result = run_powermodels_powerflow(case_pf)
                @test isa(result, Dict{String,Any})
                @test string(result["termination_status"]) ==
                      "LOCALLY_SOLVED"
                @test isapprox(result["objective"], 0.0; atol = 1e0)
                @test result["solve_time"] > 0.0
        end

        @testset "test for powermodels_custom" begin
                result = run_powermodels_custom(case_custom)
                @test isa(result, Dict{String,Any})
                @test string(result["termination_status"]) ==
                      "LOCALLY_SOLVED"
                @test isapprox(result["objective"], 144.85; atol = 1e0)
                @test result["solve_time"] > 0.0
        end

        @testset "test for powermodels_tnep" begin
                result = run_powermodels_tnep(case_tnep)
                @test isa(result, Dict{String,Any})
                @test string(result["termination_status"]) ==
                      "LOCALLY_SOLVED"
                @test isapprox(result["objective"], 0.0; atol = 1e0)
                @test result["solve_time"] > 0.0
        end

        @testset "test for powermodels_ots" begin
                result = run_powermodels_ots(case_ots)
                @test isa(result, Dict{String,Any})
                @test string(result["termination_status"]) ==
                      "LOCALLY_SOLVED"
                @test isapprox(
                        result["objective"],
                        14810.0;
                        atol = 100.0,
                )
                @test result["solve_time"] > 0.0
        end

end
