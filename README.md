# PandaModels

[![Dev](https://img.shields.io/badge/docs-dev-blue)](https://e2niee.github.io/PandaModels.jl/dev/)
[![Documentation](https://github.com/e2nIEE/PandaModels.jl/actions/workflows/documentation.yml/badge.svg)](https://github.com/e2nIEE/PandaModels.jl/actions/workflows/documentation.yml)

[![CI](https://github.com/e2nIEE/PandaModels.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/e2nIEE/PandaModels.jl/actions/workflows/ci.yml)
[![CompatHelper](https://github.com/e2nIEE/PandaModels.jl/actions/workflows/CompatHelper.yml/badge.svg)](https://github.com/e2nIEE/PandaModels.jl/actions/workflows/CompatHelper.yml)
[![TagBot](https://github.com/e2nIEE/PandaModels.jl/actions/workflows/TagBot.yml/badge.svg)](https://github.com/e2nIEE/PandaModels.jl/actions/workflows/TagBot.yml)

[![codecov](https://codecov.io/gh/e2nIEE/PandaModels.jl/branch/master/graph/badge.svg?label=codecov)](https://codecov.io/gh/e2nIEE/PandaModels.jl)
[![coveralls](https://coveralls.io/repos/github/e2nIEE/PandaModels.jl/badge.svg?branch=master)](https://coveralls.io/github/e2nIEE/PandaModels.jl?branch=master)

[PandaModels.jl](https://github.com/e2nIEE/PandaModels.jl) is a [Julia](https://julialang.org/) package which containing supplementary data and codes to prepare [pandapower](https://github.com/e2nIEE/pandapower) networks in a compatible format for Julia packages which are based on [InfrastructureModels](https://lanl-ansi.github.io/InfrastructureModels.jl/dev/), such as [PowerModels.jl](https://github.com/lanl-ansi/PowerModels.jl) to run and calculate steady-state power network optimization. These packages use [JuMP](https://github.com/JuliaOpt/JuMP.jl) as optimization environment.

## Acknowledgements
This package has been developed as part of the De­part­ment of En­er­gy Ma­nage­ment and Power Sys­tem Ope­ra­ti­on [(e²n)](https://www.uni-kassel.de/eecs/en/faculties/energy-management-and-power-system-operation/home), University of Kassel and Fraunhofer Institute for Energy Economics and Energy System Technology [(IEE)](https://www.iee.fraunhofer.de/en.html).

The developers thank [Carleton Coffrin](https://www.coffrin.com/), the primary developer of [PowerModels.jl](https://lanl-ansi.github.io/PowerModels.jl/stable/), for his support.
<!--
### Dependencies

* [JuMP.jl](https://github.com/JuliaOpt/JuMP.jl)
* [PowerModels.jl](https://github.com/lanl-ansi/PowerModels.jl)

i/o:
* [JSON.jl](https://github.com/JuliaIO/JSON.jl)

solvers:
* [Ipopt.jl](https://github.com/jump-dev/Ipopt.jl)
* [Juniper.jl](https://github.com/lanl-ansi/Juniper.jl)
* [Cbc.jl](https://github.com/jump-dev/Cbc.jl)
* [Gurobi.jl](https://github.com/jump-dev/Gurobi.jl)

#### Gurobi Installation

* To use [Gurobi](https://www.gurobi.com/):

    1. Download and install from [Gurobi Download Center](https://www.gurobi.com/downloads/)

    1. Get the Gurobi license, activate it and add its path to the local PATH environment variables by following the steps from [Gurobi License Center](https://www.gurobi.com/downloads/licenses/)

        * for `linux` users: open `.bashrc` file with , e.g., `nano .bashrc` in your home folder and add:
        ```bash
        # gurobi
        export GUROBI_HOME="/opt/gurobi_VERSION/linux64"
        export PATH="${PATH}:${GUROBI_HOME}/bin"
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
        export GRB_LICENSE_FILE="/PATH_TO_YOUR_LICENSE_DIR/gurobi.lic"
        ```

    1. Add the package to `Julia` by following the installation Instructions from [Gurobi.jl](https://github.com/jump-dev/Gurobi.jl)


### Add and Develop PandaModels

To install and develop, as-for-yet unregistered, [PandaModels](https://github.com/e2nIEE/PandaModels.jl) from `Git Bash`:


1. Clone [PandaModels](https://github.com/e2nIEE/PandaModels.jl) repository into your local machine: ::
    ```bash
    $ git clone https://github.com/e2nIEE/PandaModels.jl.git
    ```
1. open `Julia REPL` in `Git Bash`:
    ```bash
    $ julia
    ```

1. In `Julia REPL`, type:
    ```julia
    import Pkg
    # path to cloned repository
    Pkg.add(path = "path/to/your/local/PandaModels.jl")
    Pkg.develop("PandaModels")
    Pkg.build("PandaModels")
    Pkg.resolve()
    ```

1. Check if your package is in develop mode:
    ```julia
    import PandaModels
    pathof(PandaModels)
    ```

> The result should be:
>```julia
>"~/.julia/dev/PandaModels/src/PandaModels.jl"
>```

To install and develop [PandaModels](https://github.com/e2nIEE/PandaModels.jl) directly from `python`:

1. call `Julia` in `python`:

* before running the following codes please set the `Julia/python` interface by following the steps [here](https://syl1.gitbook.io/julia-language-a-concise-tutorial/language-core/interfacing-julia-with-other-languages).

```python
import julia
from julia import Main
from julia import Pkg
```

2. install `PandaModels` and build the develop mode:
```python
# add PandaModels in "~/.julia/packages/PandaModels"
Pkg.add(url = "https://github.com/e2nIEE/PandaModels.jl")
Pkg.develop("PandaModels")
Pkg.build("PandaModels")
Pkg.resolve()
```

3. Check if your package is in develop mode:
```python
from julia import Base
Base.find_package("PandaModels")
```
> The result should be:
> ```python
> "~/.julia/dev/PandaModels/src/PandaModels.jl"
> ```


> Note: [PyJulia](https://pyjulia.readthedocs.io/en/latest/) crashes on Julia new released version 1.6.0, please install the older versions.

-->

<!--### Optimization Tool

In `python`, for any net in [pandapower](https://github.com/e2nIEE/pandapower) or [SimBench](https://github.com/e2nIEE/simbench) format, simply by calling `pandapower.runpm` function you are able to solve wide range of available OPF [models, approximations and relaxations](https://lanl-ansi.github.io/PowerModels.jl/stable/formulation-details/), from [PowerModels.jl](https://github.com/lanl-ansi/PowerModels.jl).

```python
runpm(net, julia_file=None, pp_to_pm_callback=None, calculate_voltage_angles=True,
          trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
          correct_pm_network_data=True, pm_model="ACPPowerModel", pm_solver="ipopt",
          pm_mip_solver="cbc", pm_nl_solver="ipopt", pm_time_limits=None, pm_log_level=0,
          delete_buffer_file=True, pm_file_path = None, opf_flow_lim="S", **kwargs)
```
For example to run semi-definite relaxation of AC OPF with :

```python
import pandapower as pp
import pandapower.networks as nw

net = nw.example_simple()
pp.runpm(net, pm_model="SDPWRMPowerModel", pm_solver="gurobi", pm_nl_solver="gurobi")
```

| exact non-convex model  | linear approximations | quadratic approximations | quadratic relaxations | sdp relaxations |
| ------------- | ------------- |------------- | ------------- | ------------- |
| ACPPowerModel | DCPPowerModel | DCPLLPowerModel | SOCWRPowerModel | SDPWRMPowerModel |
| ACRPowerModel | DCMPPowerModel | LPACCPowerModel | SOCWRConicPowerModel | SparseSDPWRMPowerModel |
| ACTPowerModel | BFAPowerModel | | SOCBFPowerModel | |
| IVRPowerModel | NFAPowerModel | | SOCBFConicPowerModel | |
| | | | QCRMPowerModel | |
| | | | QCLSPowerModel | |


Different solver options are availabe in [PandaModels](https://github.com/e2nIEE/PandaModels.jl). For more information please check the supported solvers by [JuMP.jl](https://github.com/JuliaOpt/JuMP.jl) in [here](https://jump.dev/JuMP.jl/dev/installation/).


| solvers  | support | license |
| ------------- | ------------- | ------------- |
| Juniper | (MI)SOCP, (MI)NLP | MIT |  
| Ipopt | LP, QP, NLP | EPL |
| Cbc | (MI)LP | EPL |
| SCIP | (MI)LP, (MI)NLP | ZIB |
| Gurobi | (MI)LP, (MI)SOCP | Comm. |
| KNITRO | (MI)LP, (MI)SOCP, (MI)NLP | Comm. |



For DC and AC OPF, you can directly call `pandapower.runpm_dc_opf` and `pandapower.runpm_ac_opf`, respectively.


For example:

```python
import pandapower as pp
import pandapower.networks as nw

net = nw.example_simple()
pp.runpm_ac_opf(net)
```

for more  details about the settings please see [here](https://pandapower.readthedocs.io/en/v2.6.0/opf/powermodels.html#usage), also the detailed tutorial is available [here](https://github.com/e2nIEE/pandapower/blob/develop/tutorials/opf_powermodels.ipynb).
-->

<!-- ### Developing:
##### Add New Optimization Model to PowerModels



### Use pandapower Directly in Julia




### Test pandapower

All changes in [PandaModels](https://github.com/e2nIEE/PandaModels.jl) should be synced to [pandapower](https://github.com/e2nIEE/pandapower). To test the changes, first checkout to `julia_pkg` branch in [pandapower](https://github.com/e2nIEE/pandapower) and run pandapower test:

```python
import pandapower.test
pandapower.test.run_all_tests()
```
-->
