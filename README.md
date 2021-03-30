# PandaModels

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://e2nIEE.github.io/PandaModels.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://e2nIEE.github.io/PandaModels.jl/dev)
[![Build Status](https://travis-ci.com/e2nIEE/PandaModels.jl.svg?branch=master)](https://travis-ci.com/e2nIEE/PandaModels.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/e2nIEE/PandaModels.jl?svg=true)](https://ci.appveyor.com/project/e2nIEE/PandaModels-jl)
[![Coverage](https://codecov.io/gh/e2nIEE/PandaModels.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/e2nIEE/PandaModels.jl)
[![Coverage](https://coveralls.io/repos/github/e2nIEE/PandaModels.jl/badge.svg?branch=master)](https://coveralls.io/github/e2nIEE/PandaModels.jl?branch=master)


[PandaModels](https://github.com/e2nIEE/PandaModels.jl) is a [Julia](https://julialang.org/)/[JuMP](https://github.com/JuliaOpt/JuMP.jl) package which containing supplementary data and codes to prepare [pandapower](https://github.com/e2nIEE/pandapower) networks in a compatible format for [PowerModels.jl](https://github.com/lanl-ansi/PowerModels.jl) to run and calculate optimal Power Flow.

**Dependencies:**

* [JuMP.jl](https://github.com/JuliaOpt/JuMP.jl)
* [PowerModels.jl](https://github.com/lanl-ansi/PowerModels.jl)

i/o:

  * [JSON.jl](https://github.com/JuliaIO/JSON.jl)

solvers:

 * [Ipopt.jl](https://github.com/jump-dev/Ipopt.jl)
 * [Juniper.jl](https://github.com/lanl-ansi/Juniper.jl)
 * [Cbc.jl](https://github.com/jump-dev/Cbc.jl)
 * [Gurobi.jl](https://github.com/jump-dev/Gurobi.jl)


To install and develop `PandaModels`:

1. Clone the repository into your local folder
2. In `Julia REPL`, type:
```julia
]
(@v1.5) pkg> add path/to/your/local/PandaModels.jl
(@v1.5) pkg> dev PandaModels
```
3. Check if your package is in develop mode:
```julia
import PandaModels
pathof(PandaModels)
```
   The result should be
```julia
~/.julia/dev/PandaModels/src/PandaModels.jl"
```
<!-- **Instructions:**



**Running the Code:**

**Example and TestCase:** -->
