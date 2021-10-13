# Run Optimal MultiNetwork Storage
This tutorial describes how to run a [storage optimization](https://lanl-ansi.github.io/PowerModels.jl/stable/storage/) over [multiple timesteps](https://lanl-ansi.github.io/PowerModels.jl/stable/multi-networks/) with a PowerModels.jl multinetwork together with pandapower.

To run a storage optimization over multiple time steps, the power system data is copied n_timestep times internally. This is done efficiently in a julia script. Each network in the multinetwork dict represents a single time step. The input time series must be written to the loads and generators accordingly to each network. This is currently done by converting input time series to a dict, saving it as a json file and loading the data back in julia. This "hack" is probably just a temporary solution.

Some notes:
* only storages which are set as "controllable" are optimized
* time series can be written to load / sgen elements only at the moment
* output of the optimization is a dict containing pandas DataFrames for every optimized storage and time step   


### Run the storage optimization
In order to start the optimization and visualize results, we follow four steps:
1. Load the pandapower grid data (here the cigre MV grid)
2. Convert the time series to the dict
3. Start the optimization
4. plot the results


#### Get the grid data
We load the cigre medium voltage grid with "pv" and "wind" generators. Also we set some limits and add a storage with **controllable** == True



```python
import json
import os
import tempfile

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

import pandapower as pp
import pandapower.networks as nw

def cigre_grid():
    net = nw.create_cigre_network_mv("pv_wind")
    # set some limits
    min_vm_pu = 0.95
    max_vm_pu = 1.05

    net["bus"].loc[:, "min_vm_pu"] = min_vm_pu
    net["bus"].loc[:, "max_vm_pu"] = max_vm_pu

    net["line"].loc[:, "max_loading_percent"] = 100.

    # close all switches
    net.switch.loc[:, "closed"] = True
    # add storage to bus 10
    pp.create_storage(net, 10, p_mw=0.5, max_e_mwh=.2, soc_percent=0., q_mvar=0., controllable=True)

    return net


```

#### Convert the time series to a dict
The following functions loads the example time series from the input_file and scales the power accordingly.
It then stores the dict to a json file to a temporary folder.



```python
def convert_timeseries_to_dict(net, input_file):
    # set the load type in the cigre grid, since it is not specified
    net["load"].loc[:, "type"] = "residential"
    # change the type of the last sgen to wind
    net.sgen.loc[:, "type"] = "pv"
    net.sgen.loc[8, "type"] = "wind"

    # read the example time series
    time_series = pd.read_json(input_file)
    time_series.sort_index(inplace=True)
    # this example time series has a 15min resolution with 96 time steps for one day
    n_timesteps = time_series.shape[0]

    n_load = len(net.load)
    n_sgen = len(net.sgen)
    p_timeseries = np.zeros((n_timesteps, n_load + n_sgen), dtype=float)
    # p
    load_p = net["load"].loc[:, "p_mw"].values
    sgen_p = net["sgen"].loc[:7, "p_mw"].values
    wind_p = net["sgen"].loc[8, "p_mw"]

    p_timeseries_dict = dict()
    for t in range(n_timesteps):
        # print(time_series.at[t, "residential"])
        p_timeseries[t, :n_load] = load_p * time_series.at[t, "residential"]
        p_timeseries[t, n_load:-1] = - sgen_p * time_series.at[t, "pv"]
        p_timeseries[t, -1] = - wind_p * time_series.at[t, "wind"]
        p_timeseries_dict[t] = p_timeseries[t, :].tolist()

    time_series_file = os.path.join(tempfile.gettempdir(), "timeseries.json")
    with open(time_series_file, 'w') as fp:
        json.dump(p_timeseries_dict, fp)

    return net, p_timeseries_dict

```

#### Start the optimization
Here we start the optimization for the 15min resolution time series. Since we have 96 time steps and 15 min resolution
we set n_timesteps=96 and time_elapsed=.25 as a quarter of an hour.



```python
# open the cigre mv grid
net = cigre_grid()
# convert the time series to a dict and save it to disk
input_file = "assets/cigre_timeseries_15min.json"
net, p_timeseries = convert_timeseries_to_dict(net, input_file)
# run the PowerModels.jl optimization
# n_time steps = 96 and time_elapsed is a quarter of an hour (since the time series are in 15min resolution)
storage_results = pp.runpm_storage_opf(net, n_timesteps=96, time_elapsed=0.25)

```

#### Store the results (optionally)
Store the results to a json file



```python
def store_results(storage_results, grid_name):
    for key, val in storage_results.items():
        file = grid_name + "_strg_res" + str(key) + ".json"
        print("Storing results to file {}".format(file))
        print(val)
        val.to_json(file)
# store the results to disk optionally
store_results(storage_results, "cigre_ts")

```

### Plot the results
Plot the optimization results for the storage.



```python
def plot_storage_results(storage_results):
    n_res = len(storage_results.keys())
    fig, axes = plt.subplots(n_res, 2)
    if n_res == 1:
        axes = [axes]
    for i, (key, val) in enumerate(storage_results.items()):
        res = val
        axes[i][0].set_title("Storage {}".format(key))
        el = res.loc[:, ["p_mw", "q_mvar", "soc_mwh"]]
        el.plot(ax=axes[i][0])
        axes[i][0].set_xlabel("time step")
        axes[i][0].legend(loc=4)
        axes[i][0].grid()
        ax2 = axes[i][1]
        patch = plt.plot([], [], ms=8, ls="--", mec=None, color="grey", label="{:s}".format("soc_percent"))
        ax2.legend(handles=patch)
        ax2.set_label("SOC percent")
        res.loc[:, "soc_percent"].plot(ax=ax2, linestyle="--", color="grey")
        ax2.grid()

    plt.show()
# plot the result
plot_storage_results(storage_results)
```
