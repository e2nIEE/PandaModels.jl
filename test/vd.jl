function check_vd_status(sol, params)
    for (idx,val) in sol["bus"]
        if idx in keys(params[:thereshold_v])
            println(idx)
        end
    end
end

@testset "test for voltage deviation" begin
    @testset "case_vd: cigre mv" begin
        result = run_vd(case_vd)

        pm = _PdM.load_pm_from_json(case_vd)
        params = _PdM.extract_params!(pm)

        check_vd_status(result["solution"], params)

        @test string(result["termination_status"]) ==
              "LOCALLY_SOLVED"
        # @test isapprox(result["objective"], 2; atol = 1e-2)
    end

end
