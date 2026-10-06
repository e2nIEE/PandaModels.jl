# Units and Results

Since PandaModels 0.10, pandapower sends the network in **MATPOWER units**, marked with `"per_unit" => false`:
powers in MW / MVAr, energies in MWh, angles in degrees and branch impedances in per unit on
`baseMVA`. Older pandapower versions send per-unit data (`"per_unit" => true`); that data is passed
through unchanged.

## Conversion on load

`load_pm_from_json` converts data in MATPOWER units to per unit with
`mixed_units_to_per_unit!`. Besides the network itself (PowerModels' `make_per_unit!`), this
converts the values `make_per_unit!` does not know about:

* generator start values `pg_start` / `qg_start`,
* storage set points `ps` / `qs`,
* the time series in `pm["time_series"]`,
* the power-valued `user_defined_params`: `setpoint_p`, `setpoint_q`, `base_pg` and `fixed_pg`
  (MW / MVAr), and `redispatch_cost_up` / `redispatch_cost_down` (per MW).

The conversion runs before `correct_network_data!`, so it does not depend on
`correct_pm_network_data`.

## Results

Every `run_*` entry point returns its result through `finalize_result!`. For data that arrived in
MATPOWER units, `solution_to_mixed_units!` converts the solution back to MW, MVAr, MWh and degrees,
including the storage results (`ps`, `qs`, `se`, …).

`json_result` serializes a result to a JSON string, so pandapower receives it in one transfer
instead of accessing the Julia `Dict` element by element. `NaN` and `Inf` are written as `null`,
solver status codes as strings.

```@docs
PandaModels.mixed_units_to_per_unit!
PandaModels.solution_to_mixed_units!
PandaModels.finalize_result!
PandaModels.json_result
```
