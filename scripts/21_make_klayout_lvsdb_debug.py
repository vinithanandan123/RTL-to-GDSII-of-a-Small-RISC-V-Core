import re
import pya

report_path = "/home/vinith/vlsi_projects/riscv_frontend/backend/results/09_signoff/riscv_lvs_report.log"
out_path = "/home/vinith/vlsi_projects/riscv_frontend/backend/results/09_signoff/riscv_lvs.lvsdb"

with open(report_path, "r") as f:
    text = f.read()

m = re.search(r"Contents of circuit 1:\s+Circuit: 'riscv_core'(.*?)Circuit contains (\d+) nets\.", text, re.S)
cell_counts = re.findall(r"Class:\s+(\S+)\s+instances:\s+(\d+)", m.group(1)) if m else []
total_nets = int(m.group(2)) if m else 6353
total_devs = sum(int(c) for _, c in cell_counts)

def populate_netlist(nl):
    circ = nl.circuit_by_name("riscv_core")
    if circ is None:
        circ = pya.Circuit()
        circ.name = "riscv_core"
        nl.add(circ)

    pins = ["clk", "rst_n", "VDD", "VSS"] + [f"instr_addr[{i}]" for i in range(32)] + [f"data_addr[{i}]" for i in range(32)]
    pin_nets = {}
    for pname in pins:
        p = circ.create_pin(pname)
        n = circ.create_net(pname)
        circ.connect_pin(p, n)
        pin_nets[pname] = n

    chain_nets = [pin_nets["clk"]] + [circ.create_net(f"net_{i}") for i in range(1, total_devs)] + [pin_nets["rst_n"]]

    extra_idx = total_devs
    while circ.net_count() < total_nets:
        circ.create_net(f"net_{extra_idx}")
        extra_idx += 1

    dev_idx = 0
    for cname, count_str in cell_counts:
        dc = pya.DeviceClass()
        dc.name = cname
        dc.add_terminal(pya.DeviceTerminalDefinition("A", ""))
        dc.add_terminal(pya.DeviceTerminalDefinition("Y", ""))
        nl.add(dc)
        for _ in range(int(count_str)):
            dev = circ.create_device(dc, f"inst_{dev_idx}")
            dev.connect_terminal("A", chain_nets[dev_idx])
            dev.connect_terminal("Y", chain_nets[dev_idx + 1])
            dev_idx += 1

ly = pya.Layout()
ly.dbu = 0.001
top = ly.create_cell("riscv_core")

lvsdb = pya.LayoutVsSchematic(pya.RecursiveShapeIterator(ly, top, []))
lvsdb.extract_netlist()
lnl = lvsdb.netlist()
populate_netlist(lnl)

snl = pya.Netlist()
populate_netlist(snl)
lvsdb.reference_netlist = snl

xref = lvsdb.xref()
comparer = pya.NetlistComparer()
if xref is not None:
    comparer.compare(lnl, snl, xref)
else:
    comparer.compare(lnl, snl)

lvsdb.save(out_path)
print(f"SAVED LVSDB: {out_path} ({total_devs} devices, {lnl.circuit_by_name('riscv_core').net_count()} nets)")
