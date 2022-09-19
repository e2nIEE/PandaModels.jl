export _run_qflex, _run_multi_qflex

"""
run model for Q flexibility objective with AC Power Flow equations
"""

function _run_qflex(file, model_type::_PM.Type, optimizer; kwargs...)
    return _PM.solve_model(file, model_type, optimizer, _build_qflex; kwargs...)
end

"""
given a JuMP model and a PowerModels network data structure,
builds an "reactive power flexibility" formulation of the given data and returns the JuMP model
"""

function _build_qflex(pm::_PM.AbstractPowerModel)

    _PM.variable_bus_voltage(pm)
    _PM.variable_gen_power(pm)
    _PM.variable_branch_power(pm)
    _PM.variable_dcline_power(pm, bounded = false) # TODO: why false?

    objective_qflex(pm)
    # println("qflex objective function:", JuMP.objective_function(pm.model))
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

function objective_qflex(pm::_PM.AbstractPowerModel)

    if haskey(pm.ext, :obj_factors)
        if length(pm.ext[:obj_factors]) == 2
            fac1 = pm.ext[:obj_factors]["fac_1"]
            fac2 = pm.ext[:obj_factors]["fac_2"]
        end
    else
        fac1 = 1.0
        fac2 = 0
    end

    return JuMP.@objective(pm.model, Min,
    fac1 * sum((var(pm, :q, (content["element_index"], content["f_bus"], content["t_bus"])) - content["value"])^2
        for (i, content) in pm.ext[:setpoint_q])
    +
    fac2 * sum((var(pm, :qg, content)-0)^2 for (i, content) in pm.ext[:gen_and_controllable_sgen]))
end


function _run_multi_qflex(file, model_type::_PM.Type, optimizer; kwargs...)
    return _PM.solve_model(file, model_type, optimizer, _build_multi_qflex; multinetwork=true, kwargs...)
end

"""
given a JuMP model and a PowerModels network data structure,
builds an "reactive power flexibility" formulation of the given data and returns the JuMP model
"""

function _build_multi_qflex(pm::_PM.AbstractPowerModel)
    for (n, network) in _PM.nws(pm)
            _PM.variable_bus_voltage(pm, nw=n)
            _PM.variable_gen_power(pm, nw=n)
            _PM.variable_branch_power(pm, nw=n)
            _PM.variable_dcline_power(pm, nw=n)

            _PM.constraint_model_voltage(pm, nw=n)

            for i in ids(pm, :ref_buses, nw=n)
                _PM.constraint_theta_ref(pm, i, nw=n)
            end

            for i in ids(pm, :bus, nw=n)
                _PM.constraint_power_balance(pm, i, nw=n)
            end

            for i in ids(pm, :branch, nw=n)
                _PM.constraint_ohms_yt_from(pm, i, nw=n)
                _PM.constraint_ohms_yt_to(pm, i, nw=n)

                _PM.constraint_voltage_angle_difference(pm, i, nw=n)

                _PM.constraint_thermal_limit_from(pm, i, nw=n)
                _PM.constraint_thermal_limit_to(pm, i, nw=n)
            end

            for i in ids(pm, :dcline, nw=n)
                _PM.constraint_dcline_power_losses(pm, i, nw=n)
            end
    end

    objective_multi_qflex(pm)
    # println("multi_qflex objective function:", JuMP.objective_function(pm.model))

end


function objective_multi_qflex(pm::_PM.AbstractPowerModel)
    timestep_ids = [id for id in _PM.nw_ids(pm) if id != 0]
    return JuMP.@objective(pm.model, Min,
        sum(
        sum((var(pm, nw, :q, (content["element_index"], content["f_bus"], content["t_bus"])) - content["value"])^2 for (i, content) in pm.ext[:setpoint_q])
        for nw in timestep_ids)
            )
end
