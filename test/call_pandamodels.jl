@testset "test for voltage deviation" begin
    @testset "case_vd: cigre mv" begin
        result = run_pandamodels_vd(case_vd)

        pm = _PdM.load_pm_from_json(case_vd)
        params = _PdM.extract_params!(pm)

        @test string(result["termination_status"]) == "LOCALLY_SOLVED"
        @test string(result["dual_status"]) == "FEASIBLE_POINT"
        @test string(result["primal_status"]) == "FEASIBLE_POINT"

        bus = result["solution"]["bus"]
        for (idx, bus) in result["solution"]["bus"]
            if idx in keys(params[:setpoint_v])
                @test isapprox(bus["vm"], params[:setpoint_v][idx]["value"], atol=1e-1)
            end
        end

        @test isapprox(result["objective_lb"], -Inf)
        @test isapprox(result["objective"], 0.000453688; atol = 1e-8)

        @test result["solve_time"] > 0.0
    end

end
