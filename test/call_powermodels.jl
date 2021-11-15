@testset "test exported executive functions" begin

    @testset "test for run_powermodels_pf: ac" begin
        result = run_powermodels_pf(case_pf_ac)

        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
        @test isapprox(result["objective"], 0.0; atol = 1e0)
        @test result["solve_time"] > 0.0
    end

    @testset "test for run_powermodels_opf: ac" begin
        result = run_powermodels_opf(case_opf_ac)

        @test isa(result, Dict{String,Any})
        @test string(result["termination_status"]) == "LOCALLY_SOLVED"

        @test isapprox(result["objective"], 8.0298; atol = 0.1)
        @test result["solve_time"] > 0.0
    end


    @testset "test for run_powermodels_opf: cl" begin
        result = run_powermodels_opf(case_opf_cl)

        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
        @test isapprox(result["objective"], 17015.5; atol = 1e0)
        @test result["solve_time"] > 0.0
    end

    @testset "test for powermodels_tnep: ac" begin
        result = run_powermodels_tnep(case_tnep_ac)

        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
        @test string(result["dual_status"]) == "FEASIBLE_POINT"
        @test string(result["primal_status"]) == "FEASIBLE_POINT"

        new_branch = result["solution"]["ne_branch"]
        for idx in keys(new_branch)
            @test isapprox(new_branch[idx]["built"], 0.0, atol=1e-6, rtol=1e-6) ||
                  isapprox(new_branch[idx]["built"], 1.0, atol=1e-6, rtol=1e-6)
        end

        @test isapprox(new_branch["1"]["pt"], -14.2539, atol = 1e-1, rtol = 1e-1)
        @test isapprox(new_branch["2"]["pf"], 17.7384, atol = 1e-1, rtol = 1e-1)

        @test isapprox(result["objective_lb"], 60.0; atol = 1e-1)
        @test isapprox(result["objective"], 60.0; atol = 1e-1)

        @test result["solve_time"] > 0.0
    end

    @testset "test for powermodels_ots: dc" begin
            result = run_powermodels_ots(case_ots_dc)

            @test string(result["termination_status"]) == "LOCALLY_SOLVED"
            @test string(result["dual_status"]) == "FEASIBLE_POINT"
            @test string(result["primal_status"]) == "FEASIBLE_POINT"

            branch = result["solution"]["branch"]
            for idx in keys(branch)
                @test isapprox(branch[idx]["br_status"], 0.0, atol=1e-6, rtol=1e-6) ||
                      isapprox(branch[idx]["br_status"], 1.0, atol=1e-6, rtol=1e-6)
            end
            @test isapprox(result["objective_lb"], 14810.0; atol = 1e0)
            @test isapprox(result["objective"], 14810.0; atol = 1e0)

            @test result["solve_time"] > 0.0
    end

end
