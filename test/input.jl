@testset "test internal functions" begin
        @testset "test for pandapower to powermodels format convertion" begin
                pm = _PdM.load_pm_from_json(case_pm)

                @test length(pm["bus"]) == 6
                @test length(pm["gen"]) == 3
                @test length(pm["branch"]) == 7
                @test length(pm["load"]) == 3

                model = _PdM.get_model(pm["pm_model"])
                @test string(model) == "PowerModels.DCPPowerModel"

                solver = _PdM.get_solver(pm)

                @test string(solver.optimizer_constructor) == "Ipopt.Optimizer"
        end

        @testset "test for pandapower parameters" begin
                pm = _PdM.load_pm_from_json(case_vd)
                params = _PdM.extract_params!(pm)

                @test haskey(params, :setpoint_v)
                @test length(params[:setpoint_v]) >= 9

        end

        @testset "test for current limit" begin
                pm = _PdM.load_pm_from_json(case_opf_cl)
                cl = _PdM.check_current_limit!(pm)
                @test cl == length(pm["branch"])
                @test cl == 7

                pm = _PdM.load_pm_from_json(case_opf_ac)
                cl = _PdM.check_current_limit!(pm)
                @test cl == 0
        end

end
