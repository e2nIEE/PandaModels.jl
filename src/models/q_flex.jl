export _run_q_flex

# mutable struct q_flexPowerModel <: _PM.AbstractACModel _PM.@pm_fields end

"""
run model for Q flexibility objective with AC Power Flow equations
"""

function _run_q_flex(file, model_type::_PM.Type, optimizer; kwargs...)
    return _PM.run_model(file, model_type, optimizer, _build_q_flex; kwargs...)
end

"""
given a JuMP model and a PowerModels network data structure,
builds an Voltge-Deviation formulation of the given data and returns the JuMP model
"""

function _build_q_flex(pm::_PM.AbstractPowerModel)

    _PM.variable_bus_voltage(pm)
    _PM.variable_gen_power(pm)
    _PM.variable_branch_power(pm)
    _PM.variable_dcline_power(pm, bounded = false) # TODO: why false?

    objective_q_flex(pm)

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

function objective_q_flex(pm::_PM.AbstractPowerModel)

    return JuMP.@objective(pm.model, Min,
    sum((var(pm, :q, (content["element_index"], content["f_bus"], content["t_bus"])) - content["value"])^2
        for (i, content) in pm.ext[:setpoint_q]))
end
