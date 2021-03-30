using PyCall

py"""
import os
import pathlib
import numpy as np
import pandas as pd
# import simbench as sb
import pandapower as pp
from pandapower.converter.powermodels.to_pm import convert_pp_to_pm

try:
    import pplog as logging
except ImportError:
    import logging

logger = logging.getLogger(__name__)

def create_test_pp_net():

    net = pp.create_empty_network()

    min_vm_pu = 0.95
    max_vm_pu = 1.05

    # create buses
    bus1 = pp.create_bus(net, vn_kv=110., geodata=(5, 9), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
    bus2 = pp.create_bus(net, vn_kv=110., geodata=(6, 10), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
    bus3 = pp.create_bus(net, vn_kv=110., geodata=(10, 9), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
    bus4 = pp.create_bus(net, vn_kv=110., geodata=(8, 8), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)

    # create 110 kV lines
    pp.create_line(net, bus1, bus2, length_km=70., std_type='149-AL1/24-ST1A 110.0')
    pp.create_line(net, bus1, bus3, length_km=50., std_type='149-AL1/24-ST1A 110.0')
    pp.create_line(net, bus1, bus4, length_km=100., std_type='149-AL1/24-ST1A 110.0')

    # create loads
    pp.create_load(net, bus2, p_mw=60)
    pp.create_load(net, bus3, p_mw=70)
    pp.create_load(net, bus4, p_mw=50)

    # create generators
    g1 = pp.create_gen(net, bus1, p_mw=9.513270, min_p_mw=0, max_p_mw=200, vm_pu=1.01, slack=True)
    pp.create_poly_cost(net, g1, 'gen', cp1_eur_per_mw=1)

    g2 = pp.create_gen(net, bus2, p_mw=78.403291, min_p_mw=0, max_p_mw=200, vm_pu=1.01)
    pp.create_poly_cost(net, g2, 'gen', cp1_eur_per_mw=3)

    g3 = pp.create_gen(net, bus3, p_mw=92.375601, min_p_mw=0, max_p_mw=200, vm_pu=1.01)
    pp.create_poly_cost(net, g3, 'gen', cp1_eur_per_mw=3)

    # set maximum line max_loading_percent
    net.line["max_loading_percent"] = 80

    # possible new lines (set out of service in line DataFrame)
    l1 = pp.create_line(net, bus1, bus4, 10., std_type="305-AL1/39-ST1A 110.0", name="new_line1",
                        max_loading_percent=20., in_service=False)
    l2 = pp.create_line(net, bus2, bus4, 20., std_type="149-AL1/24-ST1A 110.0", name="new_line2",
                        max_loading_percent=20., in_service=False)
    l3 = pp.create_line(net, bus3, bus4, 30., std_type='149-AL1/24-ST1A 110.0', name="new_line3",
                        max_loading_percent=20., in_service=False)
    l4 = pp.create_line(net, bus3, bus4, 40., std_type='149-AL1/24-ST1A 110.0', name="new_line4",
                        max_loading_percent=20., in_service=False)

    new_line_index = [l1, l2, l3, l4]
    construction_costs = [10., 20., 30., 45.]

    # create new line dataframe
    # init dataframe
    net["ne_line"] = net["line"].loc[new_line_index, :]

    # add costs, if None -> init with zeros
    construction_costs = np.zeros(len(new_line_index)) if construction_costs is None else construction_costs
    net["ne_line"].loc[new_line_index, "construction_cost"] = construction_costs

    # set in service, but only in ne line dataframe
    net["ne_line"].loc[new_line_index, "in_service"] = True

    # init res_ne_line to save built status afterwards
    net["res_ne_line"] = pd.DataFrame(data=0, index=new_line_index, columns=["built"], dtype=int)

    return net

def convert_net_to_json(problem = "opf", model="DCPPowerModel", solver="ipopt", mip_solver="cbc", nl_solver="ipopt"):

    net = create_test_pp_net()
    pp.runpp(net)

    test_file = os.path.join(os.getcwd(), "test", "data", str(problem +"_"+model[:-10]+"_"+solver+".json"))

    test_net = convert_pp_to_pm(net, pm_file_path = test_file, correct_pm_network_data = True, calculate_voltage_angles = True,
        ac = True, trafo_model = "t", delta = 1e-8, trafo3w_losses = "hv", check_connectivity = True, pp_to_pm_callback = None,
        pm_model = model, pm_solver = solver, pm_mip_solver = mip_solver, pm_nl_solver = nl_solver)

if __name__ == "__main__":

    # models = ["DCPPowerModel", "ACPPowerModel", "ACRPowerModel", "ACTPowerModel", "IVRPowerModel", "DCMPowerModel",
    #  "BFAPowerModel", "NFAPowerModel", "DCPLLPowerModel", "LPACCPowerModel", "SOCWRPowerModel", "SOCWRConicPowerModel",
    #  "QCRMPowerModel", "QCLSPowerModel", "SOCBFPowerModel", "SOCBFConicPowerModel", "SDPWRMPowerModel", "SparseSDPWRMPowerModel"]

    models = ["DCP", "ACP", "ACR", "ACT", "IVR", "DCM", "BFA", "NFA", "DCPLL", "LPACC", "SOCWR",
            "SOCWRConic", "QCRM", "QCLS", "SOCBF", "SOCBFConic", "SDPWRM", "SparseSDPWRM"]

    solvers = ["ipopt", "gurobi", "juniper", "cbc"]

    problems = ["pf", "opf", "opb", "ots", "tnep"]

    for m in models:
        for s in solvers:
            for p in problems:
                convert_net_to_json(problem = p, model = str(m+"PowerModel"), solver = s);

"""
