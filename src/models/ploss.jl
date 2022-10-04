export _run_ploss

"""
run optimization for (active) loss reuduction
"""

function _run_ploss(file, model_type::_PM.Type, optimizer; kwargs...)
    return _PM.solve_model(file, model_type, optimizer, _build_ploss; kwargs...)
end

"""
give a JuMP model with PowerModels network data structur and build opitmization model
"""

function _build_ploss(pm::_PM.AbstractPowerModel)

    _PM.variable_bus_voltage(pm)
    _PM.variable_gen_power(pm)
    _PM.variable_branch_power(pm)
    _PM.variable_dcline_power(pm, bounded = false) # TODO: why false?

    objective_ploss(pm)

    _PM.constraint_model_voltage(pm)

    for i in _PM.ids(pm, :ref_buses)
        _PM.constraint_theta_ref(pm, i)
    end

    for i in _PM.ids(pm, :bus)
        _PM.constraint_power_balance(pm, i)
    end

    for (i, branch) in _PM.ref(pm, :branch)
        _PM.constraint_ohms_yt_from(pm, i)
        _PM.constraint_ohms_yt_to(pm, i)

        _PM.constraint_thermal_limit_from(pm, i)
        _PM.constraint_thermal_limit_to(pm, i)
    end

    for i in _PM.ids(pm, :dcline)
        _PM.constraint_dcline_power_losses(pm, i)
    end
end

function objective_ploss(pm::_PM.AbstractPowerModel)

    if haskey(pm.ext, :obj_factors)
        if length(pm.ext[:obj_factors]) == 2
            fac1 = pm.ext[:obj_factors]["fac_1"]
            fac2 = pm.ext[:obj_factors]["fac_2"]
        end
    else
        fac1 = 1.0
        fac2 = 1-fac1
    end

    return JuMP.@objective(pm.model, Min,
        fac1 * sum((var(pm, :p, (content["element_index"], content["f_bus"], content["t_bus"])) +
                    var(pm, :p, (content["element_index"], content["t_bus"], content["f_bus"])))^2 for (i, content) in pm.ext[:target_branch])
        +
        fac2 * sum((var(pm, :qg, content)-0)^2 for (i, content) in pm.ext[:gen_and_controllable_sgen]))
end
