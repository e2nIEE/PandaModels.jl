# Quick Start Guide

In `python`, for any net in [pandapower](https://pandapower.readthedocs.io/en/latest/index.html) or [SimBench](https://github.com/e2nIEE/simbench) format, simply by calling `pandapower.runpm` function you are able to solve wide range of available OPF [models, approximations and relaxations](https://lanl-ansi.github.io/PowerModels.jl/stable/formulation-details/), from [PowerModels.jl](https://lanl-ansi.github.io/PowerModels.jl/stable/).

```python
runpm(net, julia_file=None, pp_to_pm_callback=None, calculate_voltage_angles=True,
          trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
          correct_pm_network_data=True, pm_model="ACPPowerModel", pm_solver="ipopt",
          pm_mip_solver="cbc", pm_nl_solver="ipopt", pm_time_limits=None, pm_log_level=0,
          delete_buffer_file=True, pm_file_path = None, opf_flow_lim="S", pm_tol=1e-8,
          pdm_dev_mode=False, **kwargs)
```
For example to run semi-definite relaxation of AC-OPF with :

```python
import pandapower as pp
import pandapower.networks as nw

net = nw.example_simple()
pp.runpm(net, pm_model="SDPWRMPowerModel", pm_solver="ipopt", pm_nl_solver="juniper")
```

| exact non-convex model  | linear approximations | quadratic approximations | quadratic relaxations | sdp relaxations |
| ------------- | ------------- |------------- | ------------- | ------------- |
| ACPPowerModel | DCPPowerModel | DCPLLPowerModel | SOCWRPowerModel | SDPWRMPowerModel |
| ACRPowerModel | DCMPPowerModel | LPACCPowerModel | SOCWRConicPowerModel | SparseSDPWRMPowerModel |
| ACTPowerModel | BFAPowerModel | | SOCBFPowerModel | |
| IVRPowerModel | NFAPowerModel | | SOCBFConicPowerModel | |
| | | | QCRMPowerModel | |
| | | | QCLSPowerModel | |


Different solver options are available in PandaModels. For more information please check the supported solvers by [JuMP.jl](https://jump.dev/JuMP.jl/stable/) in [here](https://jump.dev/JuMP.jl/dev/installation/).


| solvers  | support | license |
| ------------- | ------------- | ------------- |
| Juniper | (MI)SOCP, (MI)NLP | MIT |  
| Ipopt | LP, QP, NLP | EPL |
| Cbc | (MI)LP | EPL |
| Gurobi | (MI)LP, (MI)SOCP | Comm. |


For DC and AC OPF, you can directly call `pandapower.runpm_dc_opf` and `pandapower.runpm_ac_opf`, respectively.


For example:

```python
import pandapower as pp
import pandapower.networks as nw

net = nw.example_simple()
pp.runpm_ac_opf(net)
```

for more  details about the settings please see [here](https://pandapower.readthedocs.io/en/latest/opf/powermodels.html#usage), also the detailed tutorial is available in [Tutorials](@ref).
