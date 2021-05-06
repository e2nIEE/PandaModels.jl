import os
import pathlib
import tempfile
import pandas as pd
import numpy as np
import simbench as sb
import pandapower as pp
import pandapower.networks as pn
# from pandapower import pp_dir
from pandapower.converter.powermodels.to_pm import convert_pp_to_pm, init_ne_line

types = ["pm", "powerflow", "powermodels", "custom"]

net = {type: pp.create_empty_network() 
        for type in types}
net["tnep"] = pn.create_cigre_network_mv()
net["ots"] = pn.case5()
net["mn_storage"] = pn.create_cigre_network_mv("pv_wind")

min_vm_pu = 0.95
max_vm_pu = 1.05

for type in types:
        # create buses
    bus1 = pp.create_bus(net[type], vn_kv=110., geodata=(5, 9), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
    bus2 = pp.create_bus(net[type], vn_kv=110., geodata=(6, 10), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
    bus3 = pp.create_bus(net[type], vn_kv=110., geodata=(10, 9), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
    bus4 = pp.create_bus(net[type], vn_kv=110., geodata=(8, 8), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)

        # create 110 kV lines
    pp.create_line(net[type], bus1, bus2, length_km=70., std_type='149-AL1/24-ST1A 110.0')
    pp.create_line(net[type], bus1, bus3, length_km=50., std_type='149-AL1/24-ST1A 110.0')
    pp.create_line(net[type], bus1, bus4, length_km=100., std_type='149-AL1/24-ST1A 110.0')

        # create loads
    pp.create_load(net[type], bus2, p_mw=60)
    pp.create_load(net[type], bus3, p_mw=70)
    pp.create_load(net[type], bus4, p_mw=50)

        # create generators
    g1 = pp.create_gen(net[type], bus1, p_mw=9.513270, min_p_mw=0, max_p_mw=200, vm_pu=1.01, slack=True)
    pp.create_poly_cost(net[type], g1, 'gen', cp1_eur_per_mw=1)

    g2 = pp.create_gen(net[type], bus2, p_mw=78.403291, min_p_mw=0, max_p_mw=200, vm_pu=1.01)
    pp.create_poly_cost(net[type], g2, 'gen', cp1_eur_per_mw=3)

    g3 = pp.create_gen(net[type], bus3, p_mw=92.375601, min_p_mw=0, max_p_mw=200, vm_pu=1.01)
    pp.create_poly_cost(net[type], g3, 'gen', cp1_eur_per_mw=3)

    net[type].line["max_loading_percent"] = 20

        # possible new lines (set out of service in line DataFrame)
    l1 = pp.create_line(net[type], bus1, bus4, 10., std_type="305-AL1/39-ST1A 110.0", name="new_line1",
                            max_loading_percent=20., in_service=False)
    l2 = pp.create_line(net[type], bus2, bus4, 20., std_type="149-AL1/24-ST1A 110.0", name="new_line2",
                            max_loading_percent=20., in_service=False)
    l3 = pp.create_line(net[type], bus3, bus4, 30., std_type='149-AL1/24-ST1A 110.0', name="new_line3",
                            max_loading_percent=20., in_service=False)
    l4 = pp.create_line(net[type], bus3, bus4, 40., std_type='149-AL1/24-ST1A 110.0', name="new_line4",
                            max_loading_percent=20., in_service=False)

    new_line_index = [l1, l2, l3, l4]
    construction_costs = [10., 20., 30., 45.]
        # create new line dataframe
        # init dataframe
    net[type]["ne_line"] = net[type]["line"].loc[new_line_index, :]
        # add costs, if None -> init with zeros
    net[type]["ne_line"].loc[new_line_index, "construction_cost"] = construction_costs
        # set in service, but only in ne line dataframe
    net[type]["ne_line"].loc[new_line_index, "in_service"] = True
        # init res_ne_line to save built status afterwards
    net[type]["res_ne_line"] = pd.DataFrame(data=0, index=new_line_index, columns=["built"], dtype=int)

    pp.runpp(net[type])


net["tnep"]["bus"].loc[:, "min_vm_pu"] = 0.95
net["tnep"]["bus"].loc[:, "max_vm_pu"] = 1.05
net["tnep"]["line"].loc[:, "max_loading_percent"] = 60.


net["tnep"]["line"] = pd.concat([net["tnep"]["line"]] * 2, ignore_index=True)
net["tnep"]["line"].loc[max(net["tnep"]["line"].index) + 1:, "in_service"] = False
new_lines = net["tnep"]["line"].loc[max(net["tnep"]["line"].index) + 1:].index
init_ne_line(net["tnep"], new_lines, construction_costs=np.ones(len(new_lines)))
pp.runpp(net["tnep"])

net["mn_storage"]["bus"].loc[:, "min_vm_pu"] = min_vm_pu
net["mn_storage"]["bus"].loc[:, "max_vm_pu"] = max_vm_pu
net["mn_storage"]["line"].loc[:, "max_loading_percent"] = 100.
net["mn_storage"].switch.loc[:, "closed"] = True
pp.create_storage(net["mn_storage"], 10, p_mw=0.5, max_e_mwh=.2, soc_percent=0., q_mvar=0., controllable=True)
##TODO: add time series to mn_storage

# pkg_dir = pathlib.Path(pp_dir, "pandapower", "opf", "PpPmInterface", "test", "data")
# # pkg_dir = pathlib.Path(pathlib.Path.home(), "GitHub", "pandapower", "pandapower", "opf", "PpPmInterface")
# json_path = os.path.join(pkg_dir, "test" , "data", "test_tnep.json")
jul_path = pathlib.PurePath(pathlib.Path.home(), ".julia")
if not os.path.exists(jul_path):
    raise KeyError("julia failed. Check julia install!")
dev_path = pathlib.PurePath(jul_path, "dev", "PandaModels")
if os.path.exists(dev_path):
    Warning("PandaModels is in development mode.")
    json_path = pathlib.PurePath(dev_path, "test", "data")
else:
    json_path = pathlib.PurePath(tempfile.TemporaryDirectory().name).parent

test_pm_json = os.path.join(json_path, "test_pm.json") # 1gen, 82bus, 116branch, 177load, DCPPowerModel, solver:Ipopt
test_powerflow_json = os.path.join(json_path, "test_powerflow.json")
test_powermodels_json = os.path.join(json_path, "test_powermodels.json")
test_custom_json = os.path.join(json_path, "test_powermodels_custom.json")
test_ots_json = os.path.join(json_path, "test_ots.json")
test_tnep_json = os.path.join(json_path, "test_tnep.json")
test_gurobi_json = os.path.join(json_path, "test_gurobi.json")
test_mn_storage_json = os.path.join(json_path, "test_mn_storage.json")

test_pm = convert_pp_to_pm(net["pm"], pm_file_path=test_pm_json, correct_pm_network_data=True, calculate_voltage_angles=True, ac=False,
                     trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
                     pp_to_pm_callback=None, pm_model="DCPPowerModel", pm_solver="ipopt",
                     pm_mip_solver="cbc", pm_nl_solver="ipopt")

test_powerflow = convert_pp_to_pm(net["powerflow"], pm_file_path=test_powerflow_json, correct_pm_network_data=True, calculate_voltage_angles=True, ac=True,
                     trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
                     pp_to_pm_callback=None, pm_model="ACPPowerModel", pm_solver="ipopt",
                     pm_mip_solver="cbc", pm_nl_solver="ipopt")
                    
test_powermodels = convert_pp_to_pm(net["powermodels"], pm_file_path=test_powermodels_json, correct_pm_network_data=True, calculate_voltage_angles=True, ac=True,
                     trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
                     pp_to_pm_callback=None, pm_model="ACPPowerModel", pm_solver="ipopt",
                     pm_mip_solver="cbc", pm_nl_solver="ipopt")
                    
test_custom = convert_pp_to_pm(net["custom"], pm_file_path=test_custom_json, correct_pm_network_data=True, calculate_voltage_angles=True, ac=False,
                     trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
                     pp_to_pm_callback=None, pm_model="DCPPowerModel", pm_solver="ipopt",
                     pm_mip_solver="cbc", pm_nl_solver="ipopt")
                    
test_ots = convert_pp_to_pm(net["ots"], pm_file_path=test_ots_json, correct_pm_network_data=True, calculate_voltage_angles=True, ac=True,
                     trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
                     pp_to_pm_callback=None, pm_model="DCPPowerModel", pm_solver="juniper",
                     pm_mip_solver="cbc", pm_nl_solver="ipopt")
                    
test_tnep = convert_pp_to_pm(net["tnep"], pm_file_path=test_tnep_json, correct_pm_network_data=True, calculate_voltage_angles=True, ac=True,
                     trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
                     pp_to_pm_callback=None, pm_model="ACPPowerModel", pm_solver="juniper",
                     pm_mip_solver="cbc", pm_nl_solver="ipopt")

test_gurobi = convert_pp_to_pm(net["tnep"], pm_file_path=test_gurobi_json, correct_pm_network_data=True, calculate_voltage_angles=True, ac=True,
                     trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
                     pp_to_pm_callback=None, pm_model="DCPPowerModel", pm_solver="gurobi",
                     pm_mip_solver="cbc", pm_nl_solver="ipopt")
                    
test_mn_storage = convert_pp_to_pm(net["mn_storage"], pm_file_path=test_mn_storage_json, correct_pm_network_data=True, calculate_voltage_angles=True, ac=True,
                     trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True,
                     pp_to_pm_callback=None, pm_model="ACPPowerModel", pm_solver="ipopt",
                     pm_mip_solver="cbc", pm_nl_solver="ipopt")
                    



#
# using PyCall
#
# py"""
# import os
# import pplog
# import pathlib
# # import simbench as sb
# import pandapower as pp
# from pandapower.converter.powermodels.to_pm import convert_pp_to_pm
#
# logger = pplog.getLogger(__name__)
# """
# def create_test_net():
#
#     net = pp.create_empty_network()
#
#     min_vm_pu = 0.95
#     max_vm_pu = 1.05
#
#     # create buses
#     bus1 = pp.create_bus(net, vn_kv=110., geodata=(5, 9), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
#     bus2 = pp.create_bus(net, vn_kv=110., geodata=(6, 10), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
#     bus3 = pp.create_bus(net, vn_kv=110., geodata=(10, 9), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
#     bus4 = pp.create_bus(net, vn_kv=110., geodata=(8, 8), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
#
#     # create 110 kV lines
#     pp.create_line(net, bus1, bus2, length_km=70., std_type='149-AL1/24-ST1A 110.0')
#     pp.create_line(net, bus1, bus3, length_km=50., std_type='149-AL1/24-ST1A 110.0')
#     pp.create_line(net, bus1, bus4, length_km=100., std_type='149-AL1/24-ST1A 110.0')
#
#     # create loads
#     pp.create_load(net, bus2, p_mw=60)
#     pp.create_load(net, bus3, p_mw=70)
#     pp.create_load(net, bus4, p_mw=50)
#
#     # create generators
#     g1 = pp.create_gen(net, bus1, p_mw=9.513270, min_p_mw=0, max_p_mw=200, vm_pu=1.01, slack=True)
#     pp.create_poly_cost(net, g1, 'gen', cp1_eur_per_mw=1)
#
#     g2 = pp.create_gen(net, bus2, p_mw=78.403291, min_p_mw=0, max_p_mw=200, vm_pu=1.01)
#     pp.create_poly_cost(net, g2, 'gen', cp1_eur_per_mw=3)
#
#     g3 = pp.create_gen(net, bus3, p_mw=92.375601, min_p_mw=0, max_p_mw=200, vm_pu=1.01)
#     pp.create_poly_cost(net, g3, 'gen', cp1_eur_per_mw=3)
#
#     # set maximum line max_loading_percent
#     net.line["max_loading_percent"] = 80
#
#     # possible new lines (set out of service in line DataFrame)
#     l1 = pp.create_line(net, bus1, bus4, 10., std_type="305-AL1/39-ST1A 110.0", name="new_line1",
#                         max_loading_percent=20., in_service=False)
#     l2 = pp.create_line(net, bus2, bus4, 20., std_type="149-AL1/24-ST1A 110.0", name="new_line2",
#                         max_loading_percent=20., in_service=False)
#     l3 = pp.create_line(net, bus3, bus4, 30., std_type='149-AL1/24-ST1A 110.0', name="new_line3",
#                         max_loading_percent=20., in_service=False)
#     l4 = pp.create_line(net, bus3, bus4, 40., std_type='149-AL1/24-ST1A 110.0', name="new_line4",
#                         max_loading_percent=20., in_service=False)
#
#     new_line_index = [l1, l2, l3, l4]
#     construction_costs = [10., 20., 30., 45.]
#
#     # create new line dataframe
#     # init dataframe
#     net["ne_line"] = net["line"].loc[new_line_index, :]
#
#     # add costs, if None -> init with zeros
#     construction_costs = np.zeros(len(new_line_index)) if construction_costs is None else construction_costs
#     net["ne_line"].loc[new_line_index, "construction_cost"] = construction_costs
#
#     # set in service, but only in ne line dataframe
#     net["ne_line"].loc[new_line_index, "in_service"] = True
#
#     # init res_ne_line to save built status afterwards
#     net["res_ne_line"] = pd.DataFrame(data=0, index=new_line_index, columns=["built"], dtype=int)
#
#     return net
#
# # def convert_net_to_json(file_name, model="DCPPowerModel", solver="ipopt", mip_solver="cbc", nl_solver="ipopt"):
# #
# #     net = create_test_net()
# #     pp.runpp(net)
# #
# #     test_file = os.path.join(os.getcwd(), str("test_"+model[:-11]+"_"+solver+".json"))
# #     print(test_file)
# #
# #     test_net = convert_pp_to_pm(net, pm_file_path=test_file, correct_pm_network_data=True, calculate_voltage_angles=True,
# #         ac=True, trafo_model="t", delta=1e-8, trafo3w_losses="hv", check_connectivity=True, pp_to_pm_callback=None,
# #         pm_model="DCPPowerModel", pm_solver="ipopt", pm_mip_solver="cbc", pm_nl_solver="ipopt")
#
# if __name__ == "__main__":
#     net = create_test_net()
#     # models = ["DCPPowerModel", "ACPPowerModel"]
#     # solvers = ["ipopt", "Gurobi"]
#     # # problems = ["ots" , "tnep"]
#     # for m in models:
#     #     for s in solvers:
#     #         convert_net_to_json(file_name, model= m, solver = s)
#
# """
