# -*- coding: utf-8 -*-
"""
Created on Thu Feb  3 11:38:22 2022

@author: zliu
"""
from pandapower.timeseries import DFData
import pandapower.networks as pn
import numpy as np
import pandapower.timeseries as ts 
import tempfile
from pandapower.timeseries.run_time_series import run_timeseries
import matplotlib.pyplot as plt
import os
import pandapower as pp
import simbench as sb
import pandapower.plotting as plot
from pandapower.control import ConstControl
from char_curve_calc.segmented_regression import Characteristic
import time
from copy import deepcopy
import pandas as pd

def calculate_qmax_qmin(net, df_p, grid_code):
    sn = net.sgen.sn_mva.values
    sn[~net.sgen.controllable.values] = 0.0
    df_qmax = df_p.copy()
    df_qmin = df_p.copy()
    
    if grid_code == "4110":
        px = [0.0, 0.1, 0.1, 0.2, 1.0]
        py = [0.0, 0.0, 0.1, 0.328, 0.328]
    elif grid_code =="4105":
        px = [0.0, 1.0]
        py = [0.0, 0.436]
    else:
        assert 1==0
    charCurve = Characteristic(px, py)
    qmax = charCurve.target(df_p/sn) * sn
    df_qmax[df_qmax.columns] = qmax
    df_qmin[df_qmax.columns] = -qmax


    return df_qmax, df_qmin


if __name__ == "__main__":
    
    grid_code = "1-HV-urban--0-sw"
    net_sb = sb.get_simbench_net(grid_code)
    net = pp.from_json("D:\PROJECTS\RPC2\char_curve_calc\char_curve_calc\pm_test\cigre_mv.json")
    net.bus["pm_param/setpoint_v"] = net.bus["pm_param/threshold_v"]
    net.bus.drop(columns=["pm_param/threshold_v"], inplace=True)
    
    net.profiles = net_sb.profiles
    net.load["profile"] = "mv_rural"
    net.sgen["profile"] = "WP5"
    net.sgen["profile"][5:8] = "WP11"  
    net.sgen.controllable[2:5] = False
    pp.create_gen(net, 14, p_mw=0.01)
    profiles = sb.get_absolute_values(net, profiles_instead_of_study_cases=True)
    # pp.runpp(net)
    sb.apply_const_controllers(net, profiles)

    ## add timesereis for q_max q_min
    df_p = net.controller["object"][2].data_source.df
    df_qmax, df_qmin = calculate_qmax_qmin(net, df_p, "4110") 
    
    ConstControl(net, element="sgen", variable="max_q_mvar",
                  element_index=net.sgen.index.tolist(), profile_name=net.sgen.index.tolist(),
                  data_source=DFData(df_qmax))
    ConstControl(net, element="sgen", variable="min_q_mvar",
                  element_index=net.sgen.index.tolist(), profile_name=net.sgen.index.tolist(),
                  data_source=DFData(df_qmin))



    net.bus["pm_param/setpoint_v"][[3,4,5,6,7,8,9,10,11]] = 1.05
    net.gen.drop(net.gen.index, inplace=True)
    net.controller.drop([3], inplace=True)
    # pp.runpm(net)
    # pp.runpm_vd(net)
    # pp.runpm_v_stad_ts(net, from_time_step=0, to_time_step=15)


    # print(net.res_ts_opt["0"].res_sgen.p_mw[8])
    # print(net.res_ts_opt["1"].res_sgen.p_mw[8])
    # print(net.res_ts_opt["2"].res_sgen.p_mw[8])
    
    # print("------pm------")   
    # print(net._pm["time_series"]["gen"]["8"]["p_mw"]["0"])
    # print(net._pm["time_series"]["gen"]["8"]["p_mw"]["1"])
    # print(net._pm["time_series"]["gen"]["8"]["p_mw"]["2"])
    
    # print("------ref------")
    # print(df_p[8].loc[0])
    # print(df_p[8].loc[1])
    # print(df_p[8].loc[2])
    
    #%% time sereis in a loop
    net_loop = deepcopy(net)
    loop_res = {}
    time_start = time.time()
    from pandapower.control import ConstControl
    for tp in range(50):
        for idx, content in net_loop.controller.iterrows():
            if type(content["object"]) == ConstControl:
                element = content["object"].__dict__["matching_params"]["element"]
                variable = content["object"].__dict__["matching_params"]["variable"]
                elm_idxs = content["object"].__dict__["matching_params"]["element_index"]
                df = content["object"].data_source.df
                net_loop[element][variable][elm_idxs] = df.loc[int(tp)]
        net_loop.sgen.max_p_mw = net_loop.sgen.p_mw
        net_loop.sgen.min_p_mw = net_loop.sgen.p_mw
        pp.runpm_vd(net_loop)
        loop_res[str(tp)] = {}
        loop_res[str(tp)]["res_bus"] = net_loop.res_bus.copy()
        loop_res[str(tp)]["res_sgen"] = net_loop.res_sgen.copy()
        loop_res[str(tp)]["res_load"] = net_loop.res_load.copy()
        loop_res[str(tp)]["res_gen"] = net_loop.res_gen.copy()
        loop_res[str(tp)]["res_ext_grid"] = net_loop.res_ext_grid.copy()
    print("loop opt:", time.time()-time_start)
    
    #%% time series
    net_ts = deepcopy(net)
    time_start = time.time()
    pp.runpm_v_stad_ts(net_ts, from_time_step=0, to_time_step=50)
    print("ts opt:", time.time()-time_start)
    
    #%% evaluation
    df = pd.DataFrame(columns=["sgen_p", "sgen_q", "load_p", "load_q", "vm_pu"])
    for t in range(50):
        df.loc[t] = [(net_ts.res_ts_opt[str(t)].res_sgen.p_mw.values - loop_res[str(t)]["res_sgen"].p_mw.values).max(),
                     (net_ts.res_ts_opt[str(t)].res_sgen.q_mvar.values - loop_res[str(t)]["res_sgen"].q_mvar.values).max(),
                     (net_ts.res_ts_opt[str(t)].res_load.p_mw.values - loop_res[str(t)]["res_load"].p_mw.values).max(),
                     (net_ts.res_ts_opt[str(t)].res_load.q_mvar.values - loop_res[str(t)]["res_load"].q_mvar.values).max(),
                     (net_ts.res_ts_opt[str(t)].res_bus.vm_pu.values - loop_res[str(t)]["res_bus"].vm_pu.values).max()] 
    
    # a=net_ts.res_ts_opt
    # b=loop_res
    # print("---------- X ----------------")
    # print("max sgen error:", abs(a["0"].res_sgen.values - b["0"]["res_sgen"].values).max())
    # print("max load error:", abs(a["0"].res_load.values - b["0"]["res_load"].values).max())
    # print("max vm_pu error:", abs(a["0"].res_bus.vm_pu.values - b["0"]["res_bus"].vm_pu.values).max())
    
    
    
    
    
    