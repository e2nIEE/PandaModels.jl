# Redispatch Optimization

The redispatch model computes the smallest (or cheapest) change to a given generator
schedule that makes the network satisfy all of its operational constraints. It starts
from a **base dispatch** `pg0` — the active-power setpoint of every generator from a
previously computed power flow — and adjusts the *participating* generators until branch
loading, bus voltage and generator limits are respected again.

The model is implemented in `src/models/redispatch.jl` and is called from pandapower through
`runpm_redispatch`. On the pandapower side the base dispatch, the participating generators and
the redispatch costs are prepared and written into the PowerModels data structure; on the Julia
side those values arrive in `pm.ext` and drive the objective.

## Entry points

Like every PandaModels model, redispatch exposes two functions:

* `_run_redispatch(file, model_type, optimizer; kwargs...)` registers the model as a
  PowerModels extension via `PowerModels.solve_model` and the builder `_build_redispatch`.
* `_build_redispatch(pm)` assembles the JuMP model: variables, objective, the redispatch
  pinning constraints and the standard OPF constraints.

The model is invoked from `run_pandamodels_redispatch(json_path)` in
`src/models/call_pandamodels.jl`, which loads the JSON buffer, selects the power model
(`pm["pm_model"]`) and solver, and passes `extract_params!(pm)` into `pm.ext`.

Because the model is built entirely from the generic PowerModels constraint templates
(`variable_gen_power`, `constraint_ohms_yt_from`/`_to`, `constraint_power_balance`,
`constraint_thermal_limit_from`/`_to`, …), it works for **both** `ACPPowerModel` and
`DCPPowerModel` without any model-specific code — only the objective and the pinning
constraints are custom.

## Data passed from pandapower (`pm.ext`)

The builder reads the following keys from `pm.ext`. All generator keys are the
**1-based PowerModels generator indices** (as strings), and all power values are in
per unit on `baseMVA`.

| key | type | meaning |
|---|---|---|
| `:base_pg` | `Dict(gen_idx => pg0)` | base dispatch of the *participating* (priced) generators |
| `:fixed_pg` | `Dict(gen_idx => pg0)` | base dispatch of controllable generators that do **not** participate and must stay fixed |
| `:redispatch_cost_up` | `Dict(gen_idx => c_up)` | upward redispatch cost (cost mode only) |
| `:redispatch_cost_down` | `Dict(gen_idx => c_down)` | downward redispatch cost (cost mode only) |

`:base_pg` is always present. `:fixed_pg` is present only when there are controllable
generators without redispatch costs. The cost dictionaries are present only in cost mode
(see below).

## Which generators do what

pandapower classifies every generator/static generator before the model is built, so the
Julia model only has to react to the `pm.ext` dictionaries:

| generator | behavior in the model |
|---|---|
| controllable **with** redispatch costs | **participating** — its active power is a free variable driven towards `pg0` (see the objective) |
| controllable **without** redispatch costs | **pinned** to `pg0` through `:fixed_pg` |
| non-controllable generator | already pinned during conversion (tight `pmin = pmax` bounds), no extra handling |
| non-controllable static generator | converted to a fixed load, so it is not a generator variable at all |
| external grid / slack | a normal generator variable, left free to balance the system |

The pinning of controllable-but-unpriced generators is applied directly in `_build_redispatch`:

```julia
if haskey(pm.ext, :fixed_pg)
    for (k, v) in pm.ext[:fixed_pg]
        JuMP.@constraint(pm.model, var(pm, :pg, parse(Int, k)) == v)
    end
end
```

## Objective

The mode is selected **implicitly**: if both `:redispatch_cost_up` and
`:redispatch_cost_down` are present the cost objective is used, otherwise the
least-deviation objective is used. Let ``G`` be the set of participating generators
(the keys of `:base_pg`).

### Least-deviation mode (default)

Minimize the squared deviation of the participating generators from their base dispatch:

```math
\min \; \sum_{i \in G} \bigl(p_{g,i} - p^0_{g,i}\bigr)^2
```

This is a convex quadratic objective. It finds the operating point closest to the original
schedule that still satisfies the network constraints — the "least redispatch".

### Cost mode

Each participating generator's adjustment is split into a non-negative upward and downward
part,

```math
p_{g,i} = p^0_{g,i} + p^{up}_{g,i} - p^{down}_{g,i}, \qquad p^{up}_{g,i} \ge 0, \; p^{down}_{g,i} \ge 0,
```

and the total redispatch cost is minimized:

```math
\min \; \sum_{i \in G} \bigl(c^{up}_i \, p^{up}_{g,i} + c^{down}_i \, p^{down}_{g,i}\bigr)
```

The auxiliary variables `pg_up`/`pg_down` and the splitting constraint are added inside
`objective_redispatch`. Because the up/down costs are non-negative, at an optimal solution at
most one of `pg_up`/`pg_down` is non-zero per generator, so the split correctly represents the
signed redispatch amount.

## Constraints

Apart from the redispatch-specific pinning and up/down splitting, the model uses the standard
AC/DC OPF constraint set from PowerModels:

* reference-bus angle: `constraint_theta_ref`
* nodal power balance: `constraint_power_balance`
* branch flow (Ohm's law): `constraint_ohms_yt_from` / `constraint_ohms_yt_to`
* voltage-angle-difference limits: `constraint_voltage_angle_difference`
* branch thermal limits: `constraint_thermal_limit_from` / `constraint_thermal_limit_to`
* DC line losses: `constraint_dcline_power_losses`
* model-voltage relations: `constraint_model_voltage`

Generator limits (`pmin`/`pmax`, `qmin`/`qmax`) and bus voltage limits (`vmin`/`vmax`) are the
usual variable bounds created by `variable_gen_power` and `variable_bus_voltage`, so the
redispatch always stays within the physical capabilities of the generators and the voltage band.

## Result

`run_pandamodels_redispatch` returns the usual PowerModels result dictionary (with
`branch_flows` enabled), containing `termination_status`, `primal_status`, `objective`,
`solve_time` and a `solution` with the redispatched generator setpoints (`pg`, `qg`), bus
voltages (`vm`, `va`) and branch flows (`pf`, `pt`, `qf`, `qt`). pandapower reads this back
into the standard result tables, so `net.res_gen`/`net.res_sgen` hold the redispatched active
powers.

## API

```@docs
PandaModels._run_redispatch
PandaModels._build_redispatch
PandaModels._redispatch_base_pg
```

## See also

* Model implementation: `src/models/redispatch.jl`
* Call function: `run_pandamodels_redispatch` in `src/models/call_pandamodels.jl`
* Tests: the `case_redispatch` test sets in `test/call_pandamodels.jl`
