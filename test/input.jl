@testset "test internal functions" begin
        @testset "test for pandapower to powermodels format convertion" begin
                pm = _PdM.load_pm_from_json(case_pm)

                @test length(pm["bus"]) == 6
                @test length(pm["gen"]) == 3
                @test length(pm["branch"]) == 7
                @test length(pm["load"]) == 3

                model = _PdM.get_model(pm["pm_model"])
                @test string(model) == "PowerModels.DCPPowerModel"

                solver = _PdM.get_solver(
                        pm["pm_solver"],
                        pm["pm_nl_solver"],
                        pm["pm_mip_solver"],
                        pm["pm_log_level"],
                        pm["pm_time_limit"],
                        pm["pm_nl_time_limit"],
                        pm["pm_mip_time_limit"],
                )

                @test string(solver.optimizer_constructor) == "Ipopt.Optimizer"
        end

        @testset "test for pandapower parameters" begin
                pm = _PdM.load_pm_from_json(case_vd)
                params = _PdM.extract_params!(pm)

                # @test haskey(params, "thereshold_v")
                # @test keys(params[:thereshold_v])
        end

end
