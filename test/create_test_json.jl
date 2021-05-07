using PyCall

# or use python file
# scriptdir = @__DIR__
# pushfirst!(PyVector(pyimport("sys")."path"), scriptdir)
# mytest = pyimport("create_test_json")


py"""
import os
import pathlib
import numpy as np
import pandas as pd
import pandapower as pp
from pandapower.converter.powermodels.to_pm import convert_pp_to_pm

def test_case_1(): # 3w_trafo

    net = pp.create_empty_network()

    # create buses
    bus1 = pp.create_bus(net, vn_kv=220.)
    bus2 = pp.create_bus(net, vn_kv=110.)
    bus3 = pp.create_bus(net, vn_kv=110.)
    bus4 = pp.create_bus(net, vn_kv=110.)
    bus5 = pp.create_bus(net, vn_kv=110.)

    pp.create_bus(net, vn_kv=110., in_service=False)

    # create 220/110 kV transformer
    pp.create_transformer3w_from_parameters(net, bus1, bus2, bus5, vn_hv_kv=220, vn_mv_kv=110,
                                            vn_lv_kv=110, vk_hv_percent=10., vk_mv_percent=10.,
                                            vk_lv_percent=10., vkr_hv_percent=0.5,
                                            vkr_mv_percent=0.5, vkr_lv_percent=0.5, pfe_kw=100,
                                            i0_percent=0.1, shift_mv_degree=0, shift_lv_degree=0,
                                            sn_hv_mva=100, sn_mv_mva=50, sn_lv_mva=50)

    # create 110 kV lines
    pp.create_line(net, bus2, bus3, length_km=70., std_type='149-AL1/24-ST1A 110.0')
    pp.create_line(net, bus3, bus4, length_km=50., std_type='149-AL1/24-ST1A 110.0')
    pp.create_line(net, bus4, bus2, length_km=40., std_type='149-AL1/24-ST1A 110.0')
    pp.create_line(net, bus4, bus5, length_km=30., std_type='149-AL1/24-ST1A 110.0')

    # create loads
    pp.create_load(net, bus2, p_mw=60, controllable=False)
    pp.create_load(net, bus3, p_mw=70, controllable=False)
    pp.create_sgen(net, bus3, p_mw=10, controllable=False)

    # create generators
    pp.create_ext_grid(net, bus1, min_p_mw=0, max_p_mw=1000, max_q_mvar=0.01, min_q_mvar=0)
    pp.create_gen(net, bus3, p_mw=80, min_p_mw=0, max_p_mw=80, vm_pu=1.01)
    pp.create_gen(net, bus4, p_mw=80, min_p_mw=0, max_p_mw=80, vm_pu=1.01)
    net.gen["controllable"] = False
    return net


def test_case_2():  # without_ext_grid

    net = pp.create_empty_network()

    min_vm_pu = 0.95
    max_vm_pu = 1.05

    # create buses
    bus1 = pp.create_bus(net, vn_kv=220., geodata=(5, 9))
    bus2 = pp.create_bus(net, vn_kv=110., geodata=(6, 10), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
    bus3 = pp.create_bus(net, vn_kv=110., geodata=(10, 9), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
    bus4 = pp.create_bus(net, vn_kv=110., geodata=(8, 8), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
    bus5 = pp.create_bus(net, vn_kv=110., geodata=(6, 8), min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)

    # create 220/110/110 kV 3W-transformer
    pp.create_transformer3w_from_parameters(net, bus1, bus2, bus5, vn_hv_kv=220, vn_mv_kv=110,
                                            vn_lv_kv=110, vk_hv_percent=10., vk_mv_percent=10.,
                                            vk_lv_percent=10., vkr_hv_percent=0.5,
                                            vkr_mv_percent=0.5, vkr_lv_percent=0.5, pfe_kw=100,
                                            i0_percent=0.1, shift_mv_degree=0, shift_lv_degree=0,
                                            sn_hv_mva=100, sn_mv_mva=50, sn_lv_mva=50)

    # create 110 kV lines
    pp.create_line(net, bus2, bus3, length_km=70., std_type='149-AL1/24-ST1A 110.0')
    pp.create_line(net, bus3, bus4, length_km=50., std_type='149-AL1/24-ST1A 110.0')
    pp.create_line(net, bus4, bus2, length_km=40., std_type='149-AL1/24-ST1A 110.0')
    pp.create_line(net, bus4, bus5, length_km=30., std_type='149-AL1/24-ST1A 110.0')

    # create loads
    pp.create_load(net, bus2, p_mw=60, controllable=False)
    pp.create_load(net, bus3, p_mw=70, controllable=False)
    pp.create_load(net, bus4, p_mw=10, controllable=False)

    # create generators
    g1 = pp.create_gen(net, bus1, p_mw=40, min_p_mw=0, min_q_mvar=-20, max_q_mvar=20, slack=True,
                    min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu)
    pp.create_poly_cost(net, g1, 'gen', cp1_eur_per_mw=1000)

    g2 = pp.create_gen(net, bus3, p_mw=40, min_p_mw=0, min_q_mvar=-20, max_q_mvar=20, vm_pu=1.01,
                    min_vm_pu=min_vm_pu, max_vm_pu=max_vm_pu, max_p_mw=40.)
    pp.create_poly_cost(net, g2, 'gen', cp1_eur_per_mw=2000)

    g3 = pp.create_gen(net, bus4, p_mw=0.050, min_p_mw=0, min_q_mvar=-20, max_q_mvar=20, vm_pu=1.01,
                        min_vm_pu=min_vm_pu,
                        max_vm_pu=max_vm_pu, max_p_mw=0.05)
    pp.create_poly_cost(net, g3, 'gen', cp1_eur_per_mw=3000)

    return net

def test_case_3():  # multiple_ext_grids

    net = pp.create_empty_network()
    # generate three ext grids
    b11, b12, l11 = add_grid_connection(net, vn_kv=110.)
    b21, b22, l21 = add_grid_connection(net, vn_kv=110.)
    b31, b32, l31 = add_grid_connection(net, vn_kv=110.)
    # connect them
    l12_22 = create_test_line(net, b12, b22)
    l22_32 = create_test_line(net, b22, b32)

    # create load and sgen to optimize
    pp.create_load(net, b12, p_mw=60)

    g3 = pp.create_sgen(net, b12, p_mw=50, min_p_mw=20, max_p_mw=200, controllable=True)

    pp.create_poly_cost(net, g3, 'sgen', cp1_eur_per_mw=10.)

    # set positive costs for ext_grid -> minimize ext_grid usage

    ext_grids = net.ext_grid.index

    net["ext_grid"].loc[0, "vm_pu"] = .99
    net["ext_grid"].loc[1, "vm_pu"] = 1.0
    net["ext_grid"].loc[2, "vm_pu"] = 1.01

    for idx in ext_grids:
        pp.create_poly_cost(net, idx, 'ext_grid', cp1_eur_per_mw=10.)

    return net

def test_case_4(): # test_voltage_angles

    net = pp.create_empty_network()
    b1, b2, l1 = add_grid_connection(net, vn_kv=110.)
    b3 = pp.create_bus(net, vn_kv=20.)
    b4 = pp.create_bus(net, vn_kv=10.)
    b5 = pp.create_bus(net, vn_kv=10., in_service=False)
    tidx = pp.create_transformer3w(
        net, b2, b3, b4, std_type='63/25/38 MVA 110/20/10 kV', max_loading_percent=120)
    pp.create_load(net, b3, p_mw=5, controllable=False)
    load_id = pp.create_load(net, b4, p_mw=5, controllable=True, max_p_mw=25, min_p_mw=0, min_q_mvar=-1e-6,
                             max_q_mvar=1e-6)
    pp.create_poly_cost(net, 0, "ext_grid", cp1_eur_per_mw=1)
    pp.create_poly_cost(net, load_id, "load", cp1_eur_per_mw=1000)
    net.trafo3w.shift_lv_degree.at[tidx] = 10
    net.trafo3w.shift_mv_degree.at[tidx] = 30
    net.bus.loc[:, "max_vm_pu"] = 1.1
    net.bus.loc[:, "min_vm_pu"] = .9

    custom_file = os.path.join(os.path.abspath(os.path.dirname(pp.test.__file__)),
                               "test_files", "run_powermodels_custom.jl")

    # load is zero since costs are high. PF results should be the same as OPF
    net.load.loc[1, "p_mw"] = 0.
    return net

def test_case_5(): # tnep_grid

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

    net.line["max_loading_percent"] = 20

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
                init_ne_line(net, new_line_index, construction_costs)
    return net

def test_case_6():  # storage_opt

    net = nw.case5()

    pp.create_storage(net, 2, p_mw=1., max_e_mwh=.2, soc_percent=100., q_mvar=1.)
    pp.create_storage(net, 3, p_mw=1., max_e_mwh=.3, soc_percent=100., q_mvar=1.)

    return net

def test_case_7(): # ots_opt

    net = nw.case5()

    branch_status = net["line"].loc[:, "in_service"].values
    assert np.array_equal(np.array([1, 1, 1, 1, 1, 1]).astype(bool), branch_status.astype(bool))

    pp.runpm_ots(net)

    branch_status = net["res_line"].loc[:, "in_service"].values
    pp.runpp(net)
    net.line.loc[:, "in_service"] = branch_status.astype(bool)

    return net

def test_case_8(): # powerflow_simple

    net = nw.simple_four_bus_system()
    net.trafo.loc[0, "shift_degree"] = 0.

    return net

def test_case_9(): # ac_powerflow_shunt

    net = nw.simple_four_bus_system()
    pp.create_shunt(net, 2, q_mvar=-0.5)
    net.trafo.loc[0, "shift_degree"] = 0.

    return net


def test_case_10(): # ac_powerflow_tap

    net = nw.simple_four_bus_system()
    net.trafo.loc[0, "shift_degree"] = 30.
    net.trafo.loc[0, "tap_pos"] = -2.

    return net


def test_case_11(): # dc_powerflow_tap

    net = nw.simple_four_bus_system()
    net.trafo.loc[0, "shift_degree"] = 0.
    net.trafo.loc[0, "shift_degree"] = 30.
    net.trafo.loc[0, "tap_pos"] = -2.

    return net

# def test_case_12():  # timeseries
#
#     profiles = pd.DataFrame()
#     n_timesteps = 3
#     profiles['load1'] = np.random.random(n_timesteps) * 2e1
#     ds = pp.timeseries.DFData(profiles)
#
#     net = nw.simple_four_bus_system()
#     time_steps = range(3)
#     pp.control.ConstControl(net, 'load', 'p_mw', element_index=0, data_source=ds, profile_name='load1', scale_factor=0.85)
#     net.load['controllable'] = False
#     pp.timeseries.run_timeseries(net, time_steps, continue_on_divergence=True, verbose=False, recycle=False, run=pp.runpm_dc_opf)
#     return net

def convert_net_to_json(net, problem = "opf", model="DCPPowerModel", solver="ipopt", mip_solver="cbc", nl_solver="ipopt"):

    # net = create_test_pp_net()
    pp.runpp(net)

    test_file = os.path.join(os.getcwd(), "test", "data", str(problem +"_"+model[:-10]+"_"+solver+".json"))

    test_net = convert_pp_to_pm(net, pm_file_path = test_file, correct_pm_network_data = True, calculate_voltage_angles = True,
        ac = True, trafo_model = "t", delta = 1e-8, trafo3w_losses = "hv", check_connectivity = True, pp_to_pm_callback = None,
        pm_model = model, pm_solver = solver, pm_mip_solver = mip_solver, pm_nl_solver = nl_solver)


# #
if __name__ == "__main__":
     net = test_case_1()
     convert_net_to_json(problem = p, model = str(m+"PowerModel"), solver = s);

#     # models = ["DCPPowerModel", "ACPPowerModel", "ACRPowerModel", "ACTPowerModel", "IVRPowerModel", "DCMPowerModel",
#     #  "BFAPowerModel", "NFAPowerModel", "DCPLLPowerModel", "LPACCPowerModel", "SOCWRPowerModel", "SOCWRConicPowerModel",
#     #  "QCRMPowerModel", "QCLSPowerModel", "SOCBFPowerModel", "SOCBFConicPowerModel", "SDPWRMPowerModel", "SparseSDPWRMPowerModel"]
    models = ["DCP", "ACP", "ACR", "ACT", "IVR", "DCM", "BFA", "NFA", "DCPLL", "LPACC", "SOCWR",
        "SOCWRConic", "QCRM", "QCLS", "SOCBF", "SOCBFConic", "SDPWRM", "SparseSDPWRM"]

    # models = dict{"dc":["DCP","DCM","DCPLL"] ,
    #             "ac":["ACP","ACR","ACT","IVR","LPACC","SOCWR","SOCWRConic","QCRM","QCLS","SDPWRM","SparseSDPWRM"],
    #             "ac_branch_flow":["SOCBF","BFA"]
    #             "ac_bus_injection":["SOCBF", "SOCBFConic"]
    #             "aprx":["NFA","NFA"]}

    solvers = ["ipopt", "gurobi", "juniper", "cbc"]

    problems = ["pf", "opf", "opb", "ots", "tnep"]

    for m in models:
        for s in solvers:
            for p in problems:
                convert_net_to_json(net, problem = p, model = str(m+"PowerModel"), solver = s);

"""


# net = py"create_test_pp_net"()
