# Developer Documentation

### Develop Mode

To install and develop, as-for-yet unregistered, PandaModels you can use either `Git Bash` or `Python`:

#### Git Bash:
To install and develop, as-for-yet unregistered, PandaModels from `Git Bash`:

Open `Julia REPL` in `Git Bash`:
```bash
$ julia
```

In `Julia REPL`, add the as-for-yet unregistered, package:
```julia
import Pkg
# add package
Pkg.add(url = "https://github.com/e2nIEE/PandaModels.jl")
# develop-mode
Pkg.develop("PandaModels")
Pkg.build("PandaModels")
Pkg.resolve()
```

Check if your package is in develop mode:
```julia
import PandaModels
pathof(PandaModels)
```
> The result should be:
>```julia
>"~/.julia/dev/PandaModels/src/PandaModels.jl"
>```

#### Python:

To install and develop, as-for-yet unregistered, PandaModels directly from `python`:

before running the following codes please set the `Julia/python` interface by following the steps in [here](https://syl1.gitbook.io/julia-language-a-concise-tutorial/language-core/interfacing-julia-with-other-languages).

Call `Julia` in `python`:
```python
# call julia
import julia
from julia import Main
from julia import Pkg
# add package
Pkg.add(url = "https://github.com/e2nIEE/PandaModels.jl")
# develop-mode
Pkg.develop("PandaModels")
Pkg.build("PandaModels")
Pkg.resolve()
```

Check if your package is in develop mode:
```python
from julia import Base
Base.find_package("PandaModels")
```
> The result should be:
> ```python
> "~/.julia/dev/PandaModels/src/PandaModels.jl"
> ```

!!! warning "Julia Version"
    [PyJulia](https://pyjulia.readthedocs.io/en/latest/) crashes on Julia new released version 1.6.0, please install the older versions.

### Dependencies

In develop-mode you need to add the following dependencies:

optimization environment:
* [JuMP.jl](https://github.com/JuliaOpt/JuMP.jl)

infrastructure-based packages:
* [InfrastructureModels.jl](https://github.com/lanl-ansi/InfrastructureModels.jl)
* [PowerModels.jl](https://github.com/lanl-ansi/PowerModels.jl)
* [PowerModelsDistribution.jl](https://github.com/lanl-ansi/PowerModelsDistribution.jl)

logger:
* [Memento.jl](https://github.com/invenia/Memento.jl)

i/o:
* [JSON.jl](https://github.com/JuliaIO/JSON.jl)

solvers:
* [Ipopt.jl](https://github.com/jump-dev/Ipopt.jl)
* [Juniper.jl](https://github.com/lanl-ansi/Juniper.jl)
* [Cbc.jl](https://github.com/jump-dev/Cbc.jl)
* [Gurobi.jl](https://github.com/jump-dev/Gurobi.jl)


Open `Julia REPL` in `Git Bash`:
```bash
$ julia
```
In `Julia REPL`, add dependencies:
```julia
import Pkg
Pkg.Registry.update()
Pkg.add([
    Pkg.PackageSpec(;name="JuMP"),
    Pkg.PackageSpec(;name="InfrastructureModels"),
    Pkg.PackageSpec(;name="PowerModels"),
    Pkg.PackageSpec(;name="PowerModelsDistribution"),
    Pkg.PackageSpec(;name="Memento"),
    Pkg.PackageSpec(;name="JSON"),
    Pkg.PackageSpec(;name="Ipopt"),
    Pkg.PackageSpec(;name="Juniper"),
    Pkg.PackageSpec(;name="Cbc"),
    ])
Pkg.build()
Pkg.resolve()
```

#### Gurobi Installation:

To use [Gurobi](https://www.gurobi.com/), download and install from [Gurobi Download Center](https://www.gurobi.com/downloads/), then get the license, activate it and add its path to the local PATH environment variables by following the steps from [Gurobi License Center](https://www.gurobi.com/downloads/licenses/).

!!! note "Linux Users"
    for `linux` users: open `.bashrc` file with , e.g., `nano .bashrc` in your home folder and add:
    ```bash
    export GUROBI_HOME="/opt/gurobi_VERSION/linux64"
    export PATH="${PATH}:${GUROBI_HOME}/bin"
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
    export GRB_LICENSE_FILE="/PATH_TO_YOUR_LICENSE_DIR/gurobi.lic"
    ```

Finally, add the package to `Julia` by following installation instructions from [Gurobi.jl](https://github.com/jump-dev/Gurobi.jl).
