import os
import json
import pathlib
import tempfile
import pandas as pd
import numpy as np
import simbench as sb
import pandapower as pp
import pandapower.networks as pn
from pandapower.converter.powermodels.to_pm import convert_pp_to_pm, init_ne_line, dump_pm_json, convert_to_pm_structure
from pandapower.auxiliary import _add_ppc_options, _add_opf_options
from pandapower.opf.pm_storage import add_storage_opf_settings

jul_path = pathlib.PurePath(pathlib.Path.home(), ".julia")

if not os.path.exists(jul_path):
    raise KeyError("julia failed. Check julia install!")

dev_path = pathlib.PurePath(jul_path, "dev", "PandaModels")

if os.path.exists(dev_path):
    Warning("PandaModels is in development mode.")
    json_path = pathlib.PurePath(dev_path, "test", "data")
else:
    json_path = tempfile.gettempdir()

types = ["pm", "powerflow", "opf", "custom"]

net = {type: pp.create_empty_network()
        for type in types}

net["tnep"] = pn.create_cigre_network_mv()
net["ots"] = pn.case5()

min_vm_pu = 0.95
max_vm_pu = 1.05

for type in types:
    #create buses
    bus1 = pp.create_bus(net[type], vn_kv=220., geodata=(5,9), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
    bus2 = pp.create_bus(net[type], vn_kv=110., geodata=(6,10), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
    bus3 = pp.create_bus(net[type], vn_kv=110., geodata=(10,9), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
    bus4 = pp.create_bus(net[type], vn_kv=110., geodata=(8,8), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
    bus5 = pp.create_bus(net[type], vn_kv=110., geodata=(6,8), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)

    #create 220/110/110 kV 3W-transformer
    pp.create_transformer3w_from_parameters(net[type], bus1, bus2, bus5, vn_hv_kv=220, vn_mv_kv=110,
                                        vn_lv_kv=110, vk_hv_percent=10., vk_mv_percent=10.,
                                        vk_lv_percent=10., vkr_hv_percent=0.5,
                                        vkr_mv_percent=0.5, vkr_lv_percent=0.5, pfe_kw=10,
                                        i0_percent=0.1, shift_mv_degree=0, shift_lv_degree=0,
                                        sn_hv_mva=100, sn_mv_mva=50, sn_lv_mva=50)

    #create 110 kV lines
    l1 = pp.create_line(net[type], bus2, bus3, length_km=70., std_type='149-AL1/24-ST1A 110.0')
    l2 = pp.create_line(net[type], bus3, bus4, length_km=50., std_type='149-AL1/24-ST1A 110.0')
    l3 = pp.create_line(net[type], bus4, bus2, length_km=40., std_type='149-AL1/24-ST1A 110.0')
    l4 = pp.create_line(net[type], bus4, bus5, length_km=30., std_type='149-AL1/24-ST1A 110.0')

    #create loads
    pp.create_load(net[type], bus2, p_mw=60)
    pp.create_load(net[type], bus3, p_mw=70)
    pp.create_load(net[type], bus4, p_mw=10)

    #create generators
    g1 = pp.create_gen(net[type], bus1, p_mw=40, min_p_mw=0, max_p_mw=200, vm_pu=1.01, slack=True)
    pp.create_poly_cost(net[type], g1, 'gen', cp1_eur_per_mw=1)

    g2 = pp.create_gen(net[type], bus3, p_mw=40, min_p_mw=0, max_p_mw=200, vm_pu=1.01)
    pp.create_poly_cost(net[type], g2, 'gen', cp1_eur_per_mw=3)

    g3 = pp.create_gen(net[type], bus4, p_mw=50, min_p_mw=0, max_p_mw=200, vm_pu=1.01)
    pp.create_poly_cost(net[type], g3, 'gen', cp1_eur_per_mw=3)
    pp.runpp(net[type])


net["tnep"]["bus"].loc[:, "min_vm_pu"] = min_vm_pu
net["tnep"]["bus"].loc[:, "max_vm_pu"] = max_vm_pu
net["tnep"]["line"].loc[:, "max_loading_percent"] = 80.
net["tnep"]["line"] = pd.concat([net["tnep"]["line"]] * 2, ignore_index=True)
net["tnep"]["line"].loc[max(net["tnep"]["line"].index) + 1:, "in_service"] = False

new_lines = net["tnep"]["line"].loc[max(net["tnep"]["line"].index) + 1:].index
init_ne_line(net["tnep"], new_lines, construction_costs=np.ones(len(new_lines)))

pp.runpp(net["tnep"])

test_pm_json = os.path.join(json_path, "test_pm.json") # 1gen, 82bus, 116branch, 177load, DCPPowerModel, solver:Ipopt
test_powerflow_opf_json = os.path.join(json_path, "test_pf.json")
test_powermodels_json = os.path.join(json_path, "test_opf.json")
test_custom_json = os.path.join(json_path, "test_custom.json")
test_ots_json = os.path.join(json_path, "test_ots.json")
test_tnep_json = os.path.join(json_path, "test_tnep.json")


test_pm = convert_pp_to_pm(net["pm"], pm_file_path=test_pm_json, correct_pm_network_data=True, calculate_voltage_angles=True, ac=False,
                     trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
                     pp_to_pm_callback=None, pm_model="DCPPowerModel", pm_solver="ipopt",
                     pm_mip_solver="cbc", pm_nl_solver="ipopt")

test_powerflow = convert_pp_to_pm(net["powerflow"], pm_file_path=test_powerflow_opf_json, correct_pm_network_data=True, calculate_voltage_angles=True, ac=True,
                     trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
                     pp_to_pm_callback=None, pm_model="ACPPowerModel", pm_solver="ipopt",
                     pm_mip_solver="cbc", pm_nl_solver="ipopt")

test_powermodels = convert_pp_to_pm(net["opf"], pm_file_path=test_powermodels_json, correct_pm_network_data=True, calculate_voltage_angles=True, ac=True,
                     trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
                     pp_to_pm_callback=None, pm_model="ACPPowerModel", pm_solver="ipopt",
                     pm_mip_solver="cbc", pm_nl_solver="ipopt")

test_custom = convert_pp_to_pm(net["custom"], pm_file_path=test_custom_json, correct_pm_network_data=True, calculate_voltage_angles=True, ac=False,
                     trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
                     pp_to_pm_callback=None, pm_model="ACPPowerModel", pm_solver="ipopt",
                     pm_mip_solver="cbc", pm_nl_solver="ipopt")

test_ots = convert_pp_to_pm(net["ots"], pm_file_path=test_ots_json, correct_pm_network_data=True, calculate_voltage_angles=True, ac=True,
                      trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
                      pp_to_pm_callback=None, pm_model="DCPPowerModel", pm_solver="juniper",
                      pm_mip_solver="cbc", pm_nl_solver="ipopt")

test_tnep = convert_pp_to_pm(net["tnep"], pm_file_path=test_tnep_json, correct_pm_network_data=True, calculate_voltage_angles=True, ac=True,
                      trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
                      pp_to_pm_callback=None, pm_model="ACPPowerModel", pm_solver="juniper",
                      pm_mip_solver="cbc", pm_nl_solver="ipopt")

