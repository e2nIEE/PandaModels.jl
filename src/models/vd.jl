export run_vd

# file, user_defined_param = extract_params!(file)

function run_vd(file, model_type::_PM.Type, optimizer; kwargs...)
    # file, _ = extract_params!(file)
    return _PM.run_model(file, model_type, optimizer, build_vd; kwargs...)
end

# function run_tnep(file, model_type::_PM.Type, optimizer; kwargs...)
#     return run_model(file, model_type, optimizer, build_tnep; ref_extensions=[ref_add_on_off_va_bounds!,ref_add_ne_branch!], kwargs...)
# end

function build_vd(pm::_PM.AbstractPowerModel)

    # _ , user_defined_param = extract_params!(pm)

    _PM.variable_bus_voltage(pm)
    _PM.variable_gen_power(pm)
    _PM.variable_branch_power(pm)
    _PM.variable_dcline_power(pm, bounded = false)

    objective_vd(pm)

    _PM.constraint_model_voltage(pm)

    for i in _PM.ids(pm, :ref_buses)
        _PM.constraint_theta_ref(pm, i)
    end

    for i in _PM.ids(pm, :bus)
        _PM.constraint_power_balance(pm, i)
    end

    for (i, branch) in ref(pm, :branch)
        _PM.constraint_ohms_yt_from(pm, i)
        _PM.constraint_ohms_yt_to(pm, i)

        _PM.constraint_thermal_limit_from(pm, i)
        _PM.constraint_thermal_limit_to(pm, i)
    end

    for i in _PM.ids(pm, :dcline)
        _PM.constraint_dcline_power_losses(pm, i)
    end
end

# TODO: find better names for content and user...
function objective_vd(pm::_PM.AbstractPowerModel, user_defined_param)
    _ , user_defined_param = extract_params!(pm)
    return JuMP.@objective(pm.model, Min,
        sum((vm[content["element_index"]] - content["value"])^2 for (i, content) in user_defined_params["threshold_v"]))
end
