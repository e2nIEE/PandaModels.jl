function get_model(model_type)
    s = Symbol(model_type)
    return getfield(_PM, s)
end

function get_solver(pm)

    optimizer = pm["pm_solver"]
    nl = pm["pm_nl_solver"]
    mip = pm["pm_mip_solver"]
    log_level = pm["pm_log_level"]
    time_limit = pm["pm_time_limit"]
    nl_time_limit = pm["pm_nl_time_limit"]
    mip_time_limit = pm["pm_mip_time_limit"]
    tol = pm["pm_tol"]

    if optimizer == "gurobi"
        solver = JuMP.optimizer_with_attributes(
            Gurobi.Optimizer,
            "TimeLimit" => time_limit,
            "OutputFlag" => log_level,
            "FeasibilityTol" => tol,
            "OptimalityTol" => tol,
        )
    end

    if optimizer == "ipopt"
        solver = JuMP.optimizer_with_attributes(
            Ipopt.Optimizer,
            "print_level" => log_level,
            "max_cpu_time" => time_limit,
            "tol" => tol,
        )
    end

    if optimizer == "juniper" && nl == "ipopt" && mip == "cbc"
        mip_solver = JuMP.optimizer_with_attributes(
            Cbc.Optimizer,
            "logLevel" => log_level,
            "seconds" => mip_time_limit,
        )
        nl_solver = JuMP.optimizer_with_attributes(
            Ipopt.Optimizer,
            "print_level" => log_level,
            "max_cpu_time" => nl_time_limit,
            "tol" => 1e-4,
        )
        solver = JuMP.optimizer_with_attributes(
            Juniper.Optimizer,
            "nl_solver" => nl_solver,
            "mip_solver" => mip_solver,
            "log_levels" => [],
            "time_limit" => time_limit,
        )
    end

    if optimizer == "juniper" && nl == "gurobi" && mip == "cbc"
        mip_solver = JuMP.optimizer_with_attributes(
            Cbc.Optimizer,
            "logLevel" => log_level,
            "seconds" => mip_time_limit,
        )
        nl_solver = JuMP.optimizer_with_attributes(
            Gurobi.Optimizer,
            "TimeLimit" => nl_time_limit,
            "FeasibilityTol" => tol,
            "OptimalityTol" => tol,
        )
        solver = JuMP.optimizer_with_attributes(
            Juniper.Optimizer,
            "nl_solver" => nl_solver,
            "mip_solver" => mip_solver,
            "log_levels" => [],
            "time_limit" => time_limit,
        )
    end

    if optimizer == "juniper" && nl == "gurobi" && mip == "gurobi"
        mip_solver = JuMP.optimizer_with_attributes(
            Gurobi.Optimizer,
            "TimeLimit" => mip_time_limit,
            "FeasibilityTol" => tol,
            "OptimalityTol" => tol,
        )
        nl_solver = JuMP.optimizer_with_attributes(
            Gurobi.Optimizer,
            "TimeLimit" => nl_time_limit,
            "FeasibilityTol" => tol,
            "OptimalityTol" => tol,
        )
        solver = JuMP.optimizer_with_attributes(
            Juniper.Optimizer,
            "nl_solver" => nl_solver,
            "mip_solver" => mip_solver,
            "log_levels" => [],
            "time_limit" => time_limit,
        )
    end

    if optimizer == "knitro"
        solver = JuMP.optimizer_with_attributes(KNITRO.Optimizer, "tol" => tol)
    end

    if optimizer == "cbc"
        solver = JuMP.optimizer_with_attributes(
            Cbc.Optimizer,
            "seconds" => time_limit,
            "tol" => tol,
        )
    end

    if optimizer == "scip"
        solver = JuMP.optimizer_with_attributes(SCIP.Optimizer, "tol" => tol)
    end

    return solver

end

function load_pm_from_json(json_path)
    pm = Dict()
    open(json_path, "r") do f
        pm = JSON.parse(f)
    end
    for (idx, gen) in pm["gen"]
        if gen["model"] == 1
            pm["gen"][idx]["cost"] = convert(Array{Float64,1}, gen["cost"])
        end
    end
    return pm
end
