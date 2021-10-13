# Run Optimal Transmission Switching
This tutorial describes how to run the [OTS](https://lanl-ansi.github.io/PowerModels.jl/stable/specifications/#Optimal-Transmission-Switching-(OTS)) feature of PowerModels.jl together with pandapower.

The OTS allows to optimize the "switching state" of a (meshed) grid by taking lines out of service. This not exactly the same as optimizing the switching state provided by pandapower. In the OTS case **every in service branch element** in the grid is taken into account in the optimization. This includes all lines and transformers. The optimization then chooses some lines/transformers to be taken out of service in order to minimize fuel cost, see available [objectives](https://lanl-ansi.github.io/PowerModels.jl/stable/objective/) options.

To summerize this means:
* the switching state of the pandapower switches are **not** changed
* all lines / transformer in service states are variables of the optimization
* output of the optimization is a changed "in_service" state in the res_line / res_trafo... tables.   


### Choose Proper Solver

The OTS problem is a mixed-integer non-linear problem, which is especially not easy to solve. To be able to solve these kind of problems, you need a suitable solver. Either you use commercial ones (such as Knitro) or the open-source [Juniper](https://github.com/lanl-ansi/Juniper.jl) solver which is partly developed by Carleton Coffrin from PowerModels itself. Additionally [CBC](https://github.com/JuliaOpt/Cbc.jl) is needed.

Note that Juniper is a heuristic based solver. Another non-heuristic option would be to use [Alpine](https://github.com/lanl-ansi/Alpine.jl)


### Prepare the Input Data

To put it simple, the goal of the optimization is to find a changed in_service state for the branch elements
(lines, transformers). Note that the OPF calculation also takes into account the voltage and line loading limits.   

In order to start the optimization, we follow two steps:
1. Load the pandapower, or SimBench, grid data
2. Start the optimization

#### Run OTS

In this example we use the tset case grid from pandapower.networks:

```python
import pandapower.networks as nw
import pandapower as pp

# here we use the simple case5 grid
net = nw.case5()
line_status = net["line"].loc[:, "in_service"].values
print("Line status prior to optimization is:")
print(line_status.astype(bool))

# runs the powermodels.jl switch optimization
pp.runpm_ots(net)
# note that the result is taken from the res_line instead of the line table. The input DataFrame is not changed
line_status = net["res_line"].loc[:, "in_service"].values
print("Line status after the optimization is:")
print(line_status.astype(bool))


```

#### What to do with the result
The optimized line / trafo status can be found in the result DataFrames, e.g. net["res_line"]. The result ist **not** automatically written to the inputs ("line" DataFrame). To do this you can use:


```python
import pandapower as pp    

# Change the input data
net["line"].loc[:, "in_service"] = net["res_line"].loc[:, "in_service"].values
net["trafo"].loc[:, "in_service"] = net["res_trafo"].loc[:, "in_service"].values

# optional: run a power flow calculation with the changed in service status
pp.runpp(net)
```

If you have line-switches / trafo-switches at these lines/trafos you could also search for the switches connected to these elements (with the topology search) and change the switching state according to the in_service result. This should deliver identical results as changing the in service status of the element.
However, this requires to have line switches at **both** ends of the line. If you just open the switch on one of the two sides, the power flow result is slightly different since the line loading of the line without any connected elements is calculated.


### Notes
1. Juniper is based on a heuristic, it does not necessarly find the global optimum. For this use another solver

1. In the PowerModels OPF formulation, generator limits are taken into account. This means you have to specify limits for all gens, ext_grids and controllable sgens / loads.

2. Optionally costs for these can be defined.

3. Also limits for line/trafo loadings and buse voltages are to be defined. The case5 grid has pre-defined limits set. In other cases you might get an error.

Here is a code snippet:

```python
def define_ext_grid_limits(net):
    # define line loading and bus voltage limits
    min_vm_pu = 0.95
    max_vm_pu = 1.05

    net["bus"].loc[:, "min_vm_pu"] = min_vm_pu
    net["bus"].loc[:, "max_vm_pu"] = max_vm_pu

    net["line"].loc[:, "max_loading_percent"] = 100.
    net["trafo"].loc[:, "max_loading_percent"] = 100.

    # define limits
    net["ext_grid"].loc[:, "min_p_mw"] = -9999.
    net["ext_grid"].loc[:, "max_p_mw"] = 9999.
    net["ext_grid"].loc[:, "min_q_mvar"] = -9999.
    net["ext_grid"].loc[:, "max_q_mvar"] = 9999.
    # define costs
    for i in net.ext_grid.index:
        pp.create_poly_cost(net, i, 'ext_grid', cp1_eur_per_mw=1)
```
