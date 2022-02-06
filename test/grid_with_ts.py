# -*- coding: utf-8 -*-
"""
Created on Thu Feb  3 11:38:22 2022

@author: zliu
"""


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




if __name__ == "__main__":
    
    grid_code = "1-HV-urban--0-sw"
    net_sb = sb.get_simbench_net(grid_code)
    net = pp.from_json("D:\PROJECTS\RPC2\char_curve_calc\char_curve_calc\pm_test\cigre_mv.json")
    net.profiles = net_sb.profiles
    net.load["profile"] = "mv_rural"
    net.sgen["profile"] = "WP5"
    net.sgen["profile"][5:8] = "WP11"  
    net.sgen.controllable[2:5] = False
    pp.create_gen(net, 14, p_mw=0.01)
    profiles = sb.get_absolute_values(net, profiles_instead_of_study_cases=True)
    pp.runpp(net)
    sb.apply_const_controllers(net, profiles)
    pp.runpm(net)

    # v_max_allowed = 1.02
    # v_min_allowed = 0.98  
    # for i in range(1):
    #     # check upper limit
    #     target_buses_basic = net.bus.index[(net.bus.index.isin(net.sgen.bus))&
    #                                         (net.res_bus.vm_pu > v_max_allowed)].tolist()
    #     if target_buses_basic:
    #         pp.runpm(net, julia_file=voltage, pm_solver="ipopt") # pm_solver="gurobi"
    #         target_bus_iter =  list(set(target_buses_basic) + 
    #                             set(net.bus.index[(net.bus.index.isin(net.sgen.bus))&
    #                                     (net.res_bus.vm_pu > v_max_allowed)].tolist()))
    #         if set(target_buses_basic) != set(target_bus_iter):
    #             print("after optimization the voltage of some other buses are outside the user defined v-range, run opt again.")
    #             pp.runpm(net, julia_file=voltage, pm_solver="ipopt")
                
    #     # check lower limit
    #     target_bus = net.bus.index[(net.bus.index.isin(net.sgen.bus))&
    #                                 (net.res_bus.vm_pu < v_min_allowed)].tolist()
    #     if target_bus:
    #         pp.runpm(net, julia_file=voltage, pm_solver="ipopt") # pm_solver="gurobi"
        
    # print("---- after PM opf -----")
    # print(net.res_bus.loc[net.sgen.bus])