# Run Transmission Network Expansion Planning
This tutorial describes how to run the [TNEP](https://lanl-ansi.github.io/PowerModels.jl/stable/specifications/#Transmission-Network-Expansion-Planning-(TNEP)) feature of PowerModels.jl together with pandapower.


### Choose Proper Solver

The TNEP problem is a mixed-integer non-linear problem, which is especially not easy to solve. To be able to solve these kind of problems, you need a suitable solver. Either you use commercial ones (such as Knitro) or the open-source [Juniper](https://github.com/lanl-ansi/Juniper.jl) solver which is partly developed by Carleton Coffrin from PowerModels itself. Additionally [CBC](https://github.com/JuliaOpt/Cbc.jl) is needed.

Note that Juniper is a heuristic based solver. Another non-heuristic option would be to use [Alpine](https://github.com/lanl-ansi/Alpine.jl)


### Prepare the Input Data

To put it simple, the goal of the optimization is to find a set of new lines from a pre-defined set of possible
new lines so that not voltage or line loading violations are violated.   

In order to start the optimization, we have to define certain things:
1. The "common" pandapower, or SimBench, grid data with line loading and voltage limits
2. The set of available new lines to choose from

#### Create the grid
In this example we use the CIGRE medium voltage grid from pandapower.networks and define the limits for all lines /
buses as:
* max line loading limit: 60%
* min voltage magnitude: 0.95 p.u.
* max voltage magnitude: 1.05 p.u.



```python
import pandapower.networks as nw
from pandapower.converter.powermodels.to_pm import init_ne_line

def cigre_grid():
    net = nw.create_cigre_network_mv()

    net["bus"].loc[:, "min_vm_pu"] = 0.95
    net["bus"].loc[:, "max_vm_pu"] = 1.05

    net["line"].loc[:, "max_loading_percent"] = 60.
    return net

```

#### Define the new line measures to choose from
Since we want to solve a line loading problem, we define "parallel" lines to all existing lines to choose from. To
define this, two steps are necessary:
1. Create new lines in the existing "line" DataFrame and set them out of service
2. Create the "ne_line" DataFrame which specifies which lines are the possible ones to be built. This DataFrame is
similar to the line DataFrame, except that is has an additional column "construction_cost". These define the costs
for the lines to be built.

Note that it is important to set the lines "out of service" in the line DataFrame. Otherwise, they are already "built".
In the "ne_line" DataFrame the lines are set "in service". The init_ne_line() function takes care of this.


```python
import pandas as pd
import numpy as np

def define_possible_new_lines(net):
    # Here the possible new lines are a copy of all the lines which are already in the grid
    max_idx = max(net["line"].index)
    net["line"] = pd.concat([net["line"]] * 2, ignore_index=True) # duplicate
    # they must be set out of service in the line DataFrame (otherwise they are already "built")
    net["line"].loc[max_idx + 1:, "in_service"] = False
    # get the index of the new lines
    new_lines = net["line"].loc[max_idx + 1:].index

    # creates the new line DataFrame net["ne_line"] which defines the measures to choose from. The costs are defined
    # exemplary as 1. for every line.
    init_ne_line(net, new_lines, construction_costs=np.ones(len(new_lines)))

    return net

```

### Run the optimization
Now we run the optimization and print the results. First we initiate the grid with the new lines and check if some limits are violated (otherwise there is not much to optimize). Then we run `runpm_tnep(net)` and print the newly built lines and assert the line loading limits with a power flow calculation.

The newly built lines can be found in the DataFrame net["res_ne_line"], which has one column "built". A newly
built line is marked as True, otherwise False.



```python
import pandapower as pp

def pm_tnep_cigre():
    # get the grid
    net = cigre_grid()
    # add the possible new lines
    define_possible_new_lines(net)
    # check if max line loading percent is violated (should be)
    pp.runpp(net)
    print("Max line loading prior to optimization:")
    print(net.res_line.loading_percent.max())
    assert np.any(net["res_line"].loc[:, "loading_percent"] > net["line"].loc[:, "max_loading_percent"])

    # run power models tnep optimization
    pp.runpm_tnep(net)
    # print the information about the newly built lines
    print("These lines are to be built:")
    print(net["res_ne_line"])

    # set lines to be built in service
    lines_to_built = net["res_ne_line"].loc[net["res_ne_line"].loc[:, "built"], "built"].index
    net["line"].loc[lines_to_built, "in_service"] = True

    # run a power flow calculation again and check if max_loading percent is still violated
    pp.runpp(net)

    # check max line loading results
    assert not np.any(net["res_line"].loc[:, "loading_percent"] > net["line"].loc[:, "max_loading_percent"])

    print("Max line loading after the optimization:")
    print(net.res_line.loading_percent.max())

```

### Notes
1. Juniper is based on a heuristic, it does not necessarly find the global optimum. For this use another solver
2. In the PowerModels OPF formulation, generator limits are taken into account. This means you have to specify limits for all gens, ext_grids and controllable sgens / loads.
3. Optionally costs for these can be defined.
4. The CIGRE MV grid has pre-defined limits set for the ext_grid. In other cases you might get an error.

Here is a code snippet:

```python
def define_ext_grid_limits(net):
    # define limits
    net["ext_grid"].loc[:, "min_p_mw"] = -9999.
    net["ext_grid"].loc[:, "max_p_mw"] = 9999.
    net["ext_grid"].loc[:, "min_q_mvar"] = -9999.
    net["ext_grid"].loc[:, "max_q_mvar"] = 9999.
    # define costs
    for i in net.ext_grid.index:
        pp.create_poly_cost(net, i, 'ext_grid', cp1_eur_per_mw=1)
```
