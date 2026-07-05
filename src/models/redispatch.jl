export _run_redispatch

"""
run a simple redispatch optimization.

The redispatch model uses the standard PowerModels OPF constraints (so it works for both AC and DC
power models) but replaces the fuel-cost objective by a redispatch objective that keeps the selected
generators close to a base dispatch pg0.

The base dispatch and (in cost mode) the up/down redispatch costs are passed from pandapower in
pm.ext:
    - pm.ext[:base_pg]              : Dict(pm_gen_index_str => pg0)  (participating gens, per unit)
    - pm.ext[:fixed_pg]             : Dict(pm_gen_index_str => pg0)  (controllable but non-priced
                                      gens that are pinned to their base dispatch)
    - pm.ext[:redispatch_cost_up]   : Dict(pm_gen_index_str => cost_up)    (cost mode only)
    - pm.ext[:redispatch_cost_down] : Dict(pm_gen_index_str => cost_down)  (cost mode only)

If the up/down cost dicts are present the cost objective is used, otherwise the least-deviation
objective (keep pg close to pg0) is used.
"""
function _run_redispatch(file, model_type::_PM.Type, optimizer; kwargs...)
    return _PM.solve_model(file, model_type, optimizer, _build_redispatch; kwargs...)
end

"""
build the redispatch optimization model (standard OPF constraints + redispatch objective)
"""
function _build_redispatch(pm::_PM.AbstractPowerModel)

    _PM.variable_bus_voltage(pm)
    _PM.variable_gen_power(pm)
    _PM.variable_branch_power(pm)
    _PM.variable_dcline_power(pm, bounded = false)

    objective_redispatch(pm)

    # pin controllable-but-non-participating generators to their base dispatch
    if haskey(pm.ext, :fixed_pg)
        for (k, v) in pm.ext[:fixed_pg]
            JuMP.@constraint(pm.model, var(pm, :pg, parse(Int, k)) == v)
        end
    end

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

        _PM.constraint_voltage_angle_difference(pm, i)

        _PM.constraint_thermal_limit_from(pm, i)
        _PM.constraint_thermal_limit_to(pm, i)
    end

    for i in _PM.ids(pm, :dcline)
        _PM.constraint_dcline_power_losses(pm, i)
    end
end

"""
returns Dict(pm_gen_index::Int => pg0) with the base dispatch of the redispatch generators
"""
function _redispatch_base_pg(pm::_PM.AbstractPowerModel)
    base_pg = Dict{Int,Float64}()
    if haskey(pm.ext, :base_pg)
        for (k, v) in pm.ext[:base_pg]
            base_pg[parse(Int, k)] = v
        end
    end
    return base_pg
end

function objective_redispatch(pm::_PM.AbstractPowerModel)
    base_pg = _redispatch_base_pg(pm)

    # cost mode is selected implicitly by the presence of the up/down cost dicts, otherwise the
    # least-deviation objective is used (see add_redispatch_params on the pandapower side).
    redispatch_cost = haskey(pm.ext, :redispatch_cost_up) && haskey(pm.ext, :redispatch_cost_down)

    if redispatch_cost
        cost_up = Dict(parse(Int, k) => v for (k, v) in pm.ext[:redispatch_cost_up])
        cost_down = Dict(parse(Int, k) => v for (k, v) in pm.ext[:redispatch_cost_down])

        gen_ids = collect(keys(base_pg))

        # split the redispatch of each participating generator into a non-negative upward and
        # downward part: pg = pg0 + pg_up - pg_down
        JuMP.@variable(pm.model, pg_up[i in gen_ids] >= 0)
        JuMP.@variable(pm.model, pg_down[i in gen_ids] >= 0)

        for i in gen_ids
            JuMP.@constraint(pm.model, var(pm, :pg, i) == base_pg[i] + pg_up[i] - pg_down[i])
        end

        return JuMP.@objective(pm.model, Min,
            sum(cost_up[i] * pg_up[i] + cost_down[i] * pg_down[i] for i in gen_ids))
    else
        # least-deviation objective: keep generators close to their base dispatch
        return JuMP.@objective(pm.model, Min,
            sum((var(pm, :pg, i) - pg0)^2 for (i, pg0) in base_pg))
    end
end
