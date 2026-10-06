# Changelog

## [upcoming release] - 2026-..-..

### Added
- Data in MATPOWER units (`"per_unit" => false`) is accepted: network data is converted with
  PowerModels' `make_per_unit!` on load, independent of `correct_pm_network_data`. Time series,
  generator start values, storage set points and power-valued `user_defined_params`
  (`setpoint_p`, `setpoint_q`, `base_pg`, `fixed_pg`, `redispatch_cost_up/down`) are converted as well.
  The solution is returned in MW, MVAr, MWh and degrees. Data with `"per_unit" => true` behaves as before.
- `json_result(result)`: serializes a result to a JSON string, so pandapower gets it in one transfer.

### Fixed
- Multinetwork time series are read with the `from_time_step` offset, so optimizations that do not
  start at the first time step use the right values.
- `run_powermodels_pf` removes `user_defined_params` before building the model; nets with
  controllable gens failed with "invalid base 10 digit".
