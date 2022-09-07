export _run_ploss
const _PM = PowerModels
"""
run model for Q flexibility objective with AC Power Flow equations
"""

function _run_ploss(file, model_type::_PM.Type, optimizer; kwargs...)
    return _PM.solve_model(file, model_type, optimizer, _build_ploss; kwargs...)
end

"""
given a JuMP model and a PowerModels network data structure,
builds an "reactive power flexibility" formulation of the given data and returns the JuMP model
"""

function _build_ploss(pm::_PM.AbstractPowerModel)

    _PM.variable_bus_voltage(pm)
    _PM.variable_gen_power(pm)
    _PM.variable_branch_power(pm)
    _PM.variable_dcline_power(pm, bounded = false) # TODO: why false?

    objective_ploss(pm)
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

# function objective_ploss(pm::_PM.AbstractPowerModel)
#
#     return JuMP.@objective(pm.model, Min,
#     sum((var(pm, :p, (content["element_index"], content["f_bus"], content["t_bus"])))^2 -
#          (var(pm, :p, (content["element_index"], content["t_bus"], content["f_bus"])))^2
#         for (i, content) in pm.ext[:target_branch]))
# end

# function objective_ploss(pm::_PM.AbstractPowerModel)
#
#     return JuMP.@objective(pm.model, Min,
#         sum((var(pm, :p, (content["element_index"], content["f_bus"], content["t_bus"])) +
#              var(pm, :p, (content["element_index"], content["t_bus"], content["f_bus"])))^2
#              for (i, content) in pm.ext[:target_branch]))
# end

function objective_ploss(pm::_PM.AbstractPowerModel)

    return JuMP.@objective(pm.model, Min,
        sum((var(pm, :p, (content["element_index"], content["f_bus"], content["t_bus"])) +
             var(pm, :p, (content["element_index"], content["t_bus"], content["f_bus"])))^2
             for (i, content) in pm.ext[:target_branch]))
end

# multi obj example:
# fac1 = 0.4
# fac2 = 1 - fac1
# # campare fac1 = 0 and fac1 = 1
# function objective_multi_qflex(pm::_PM.AbstractPowerModel)
#     timestep_ids = [id for id in _PM.nw_ids(pm) if id != 0]
#     return JuMP.@objective(pm.model, Min,
#         fac1*sum(
#         sum((var(pm, nw, :q, (content["element_index"], content["f_bus"], content["t_bus"])) - content["value"])^2 for (i, content) in pm.ext[:setpoint_q])
#         for nw in timestep_ids)
#             +
#         fac2*sum(
#         sum((var(pm, nw, :q, (content["element_index"], content["f_bus"], content["t_bus"])) - content["value"])^2 for (i, content) in pm.ext[:setpoint_q])
#         for nw in timestep_ids)
#             )
# end
