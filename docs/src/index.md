# PandaModels.jl

```@meta
CurrentModule = PandaModels
```

## Overview

[PandaModels.jl](https://github.com/e2nIEE/PandaModels.jl) is a [Julia](https://julialang.org/) package which containing supplementary data and codes to prepare [pandapower](https://pandapower.readthedocs.io/en/latest/index.html) networks in a compatible format for Julia packages which are based on [InfrastructureModels](https://lanl-ansi.github.io/InfrastructureModels.jl/dev/), such as [PowerModels.jl](https://lanl-ansi.github.io/PowerModels.jl/stable/) to run and calculate steady-state power network optimization. These packages use [JuMP](https://jump.dev/JuMP.jl/stable/) as optimization environment which [clearly outperforms the Python alternative Pyomo](http://yetanothermathprogrammingconsultant.blogspot.com/2015/05/model-generation-in-julia.html).

## Installation

### Install Julia
If you are not yet using Julia, install it. Note that you need a version that is supported PowerModels, PyCall and pyjulia for the interface to work. Currently, [Julia 1.5](https://julialang.org/downloads/)  is the most recent stable version of Julia that supports all these packages.

You don't necessarily need a Julia IDE if you are using PowerModels through pandapower, but it might help for debugging to install an IDE such as [Juno](http://docs.junolab.org/latest/man/installation). Also, [PyCharm](https://www.jetbrains.com/pycharm/) has a Julia Plugin.

Add the Julia binary folder (e.g. /Julia-1.5.0/bin) to the [system variable PATH](https://www.computerhope.com/issues/ch000549.htm) Providing the path is correct, you can now enter the `Julia` prompt by executing:

```bash
$ julia
```

### Install PyCall

The Julia package [PyCall](https://github.com/JuliaPy/PyCall.jl#installation) allows to call `Python` in `Julia`. By default, `PyCall` uses the [Conda.jl](https://github.com/JuliaPy/Conda.jl) package to install a Miniconda distribution private to Julia.
```julia
import Pkg
Pkg.add("PyCall")
```
To use an already installed Python distribution (e.g. Anaconda), set the `PYTHON` environment variable inside the Julia prompt to e.g.:
```julia
ENV["PYTHON"]="C:\\Anaconda3\\python.exe"
import Pkg
Pkg.build("PyCall")
```

test if calling `Python` from `Julia` works as described [here](https://github.com/JuliaPy/PyCall.jl#usage).

If you cannot plot using `PyCall` and `PyPlot` in Julia, see the workarounds offered [here](https://github.com/JuliaPy/PyCall.jl/issues/665).


### Install PyJulia

At the moment only the `pip` package manager, not `conda`, is supported in `Python` to install the [PyJulia](https://pyjulia.readthedocs.io/en/latest/index.html) package, the name of the `PyJulia` package in `pip` is `Julia`:

```shell
pip install julia
```

### Install Package

If you want to use the [PandaModels.jl](https://github.com/e2nIEE/PandaModels.jl) package out of Python/pandapower environment, you can install is as a registered package by using the Julia package manager:
```julia
import Pkg
Pkg.add("PandaModels")
Pkg.build("PandaModels")
Pkg.resolve()
```

Otherwise, the package will be automatically installed in pandapower environment by applying the `PyJulia`-`PyCall` interface.

## Acknowledgements

This package has been developed as part of the De­part­ment of En­er­gy Ma­nage­ment and Power Sys­tem Ope­ra­ti­on [(e²n)](https://www.uni-kassel.de/eecs/en/faculties/energy-management-and-power-system-operation/home), University of Kassel and Fraunhofer Institute for Energy Economics and Energy System Technology [(IEE)](https://www.iee.fraunhofer.de/en.html).

The developers thank [Carleton Coffrin](https://www.coffrin.com/), the primary developer of [PowerModels.jl](https://lanl-ansi.github.io/PowerModels.jl/stable/), for his support.
