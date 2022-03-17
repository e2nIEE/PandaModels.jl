# Optimization Model

## Implement New optimization Model

To implement a new optimization model, at first, you need to introduce it in a new script in **src/models** directory as **<your_model>.jl**, for example, the optimization model for minimizing the voltage deviation is implemented in the **vd.jl** script.

Please note that, every new model needs at least two functions:
    1. The `_run_<your_model>` function which implicitly defines your model as an extension model in the PowerModels environment. This function must be exported by adding `export _run_<your_model>` at the beginning of **<your_model>.jl** script.
    1. The `_bulid_<your_model>` function which defines your optimization model, in this function, you can directly use the pre-defined variable, constraint, and objective from PowerModels or customize them. For example, in the **vd** model, the variable and constraints are from PowerModels and the objective function is customized.

!!! note "Functions for Optimization Model"
    * any customized function for variable, constraint, and object should be placed in **<your_model>.jl** script.
    * the auxiliary functions should be defined in the **input.jl** or **tools.jl** in **src/input** directory.

After defining the optimization model, you need to call your model by adding a new function `run_pandamodels_<your_model>` in **src/call_pandamodels.jl**. this function parses the JSON file of the pandapower net and based on the JSON file set the model and solver, then get the result by running your `_run_<your_model>` function.

Finally, you need to add `run_pandamodels_<your_model>` function into export list and call the model by adding `include("models/<your_model>.jl")` in before `include("models/call_pandamodels.jl")` in PandaModels module in **src/PandaModels.jl**.


## Application of New optimization Model in pandapower

Please check [here](https://github.com/e2nIEE/pandapower/blob/develop/tutorials/new_optimization_model_pandamodels.ipynb) to find out how call the new model in pandapower.
