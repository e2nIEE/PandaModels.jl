const _PM = PowerModels
export _run_vd, _run_v_stab_ts

# mutable struct VDPowerModel <: _PM.AbstractACModel _PM.@pm_fields end

"""
run model for Voltge-Deviation objective with AC Power Flow equations
"""

function _run_vd(file, model_type::_PM.Type, optimizer; kwargs...)
    return _PM.run_model(file, model_type, optimizer, _build_vd; kwargs...)
    # _PM.solve_model
end

"""
given a JuMP model and a PowerModels network data structure,
builds an Voltge-Deviation formulation of the given data and returns the JuMP model
"""

function _build_vd(pm::_PM.AbstractPowerModel)

    _PM.variable_bus_voltage(pm)
    _PM.variable_gen_power(pm)
    _PM.variable_branch_power(pm)
    _PM.variable_dcline_power(pm, bounded = false) # TODO: why false?


    objective_vd(pm)

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

function objective_vd(pm::_PM.AbstractPowerModel)
    return JuMP.@objective(pm.model, Min,
        sum((var(pm, :vm, content["element_index"]) - content["value"])^2 for (i, content) in pm.ext[:setpoint_v]))
end


"""
run model for Voltge-Deviation objective with AC Power Flow equations
"""

function _run_v_stab_ts(file, model_type::_PM.Type, optimizer; kwargs...)
    return _PM.run_model(file, model_type, optimizer, _build_v_stab_st; multinetwork=true, kwargs...)
end

"""
given a JuMP model and a PowerModels network data structure,
builds an Voltge-Deviation formulation of the given data and returns the JuMP model
"""

function _build_v_stab_st(pm::_PM.AbstractPowerModel)
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
        objective_v_stab_st(pm)
end

function objective_v_stab_st(pm::_PM.AbstractPowerModel)
    timestep_ids = [id for id in _PM.nw_ids(pm) if id != 0]
    println(timestep_ids)
    return JuMP.@objective(pm.model, Min,
        sum(
        sum((var(pm, nw, :vm, content["element_index"]) - content["value"])^2 for (i, content) in pm.ext[:setpoint_v])
        for nw in timestep_ids)
            )
end
