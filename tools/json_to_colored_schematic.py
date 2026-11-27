
import json
import sys
import html
from collections import defaultdict

if len(sys.argv) != 3:
    print("Usage: python3 json_to_colored_schematic.py input.json output.dot")
    sys.exit(1)

json_file = sys.argv[1]
dot_file = sys.argv[2]

with open(json_file) as f:
    design = json.load(f)

modules = design["modules"]

top = "riscv_core"

if top not in modules:
    print("ERROR: Top module riscv_core not found")
    print("Available modules:", list(modules.keys()))
    sys.exit(1)

module = modules[top]
cells = module.get("cells", {})
ports = module.get("ports", {})
netnames = module.get("netnames", {})

def esc(value):
    return html.escape(str(value), quote=True)

def cell_color(cell_type):
    name = cell_type.lower()

    if any(x in name for x in ["df", "dfr", "dft", "dly", "latch"]):
        return "#F59E0B", "#FEF3C7"

    if "mux" in name:
        return "#8B5CF6", "#EDE9FE"

    if any(x in name for x in ["xor", "xnor"]):
        return "#0891B2", "#CFFAFE"

    if any(x in name for x in ["and", "nand"]):
        return "#2563EB", "#DBEAFE"

    if any(x in name for x in ["or", "nor"]):
        return "#16A34A", "#DCFCE7"

    if any(x in name for x in ["inv", "not"]):
        return "#DC2626", "#FEE2E2"

    if any(x in name for x in ["buf", "clkbuf"]):
        return "#64748B", "#E2E8F0"

    if any(x in name for x in ["fa", "ha", "maj"]):
        return "#0D9488", "#CCFBF1"

    return "#475569", "#F1F5F9"


# Find readable names for signal bits
bit_names = {}

for net_name, net in netnames.items():
    for index, bit in enumerate(net["bits"]):
        if isinstance(bit, int):
            label = net_name
            if len(net["bits"]) > 1:
                label += f"[{index}]"

            old = bit_names.get(bit)

            if old is None or len(label) < len(old):
                bit_names[bit] = label


drivers = defaultdict(list)
sinks = defaultdict(list)

lines = []

lines.append('digraph SKY130_RISCV {')
lines.append('graph [rankdir=LR, splines=polyline, overlap=false,')
lines.append('bgcolor="#F8FAFC", pad=0.35, nodesep=0.30, ranksep=0.65,')
lines.append('fontname="DejaVu Sans", label="RISC-V SKY130 MAPPED CIRCUIT",')
lines.append('labelloc="t", fontsize=22, fontcolor="#0F172A"];')

lines.append('node [fontname="DejaVu Sans", fontsize=9];')
lines.append('edge [fontname="DejaVu Sans", fontsize=7,')
lines.append('color="#64748B", fontcolor="#334155", arrowsize=0.6, penwidth=1.2];')

# Draw every mapped standard cell
for ci, (inst_name, cell) in enumerate(cells.items()):

    node_id = f"c{ci}"
    cell_type = cell["type"]

    border, header = cell_color(cell_type)

    directions = cell.get("port_directions", {})
    connections = cell.get("connections", {})

    rows = []

    rows.append(
        f'<TR><TD COLSPAN="2" BGCOLOR="{header}">'
        f'<B>{esc(cell_type)}</B><BR/>'
        f'<FONT POINT-SIZE="7">{esc(inst_name)}</FONT></TD></TR>'
    )

    pin_count = 0

    for pin, bits in connections.items():

        direction = directions.get(pin, "input")
        port_id = f"p{pin_count}"
        pin_count += 1

        if direction in ("input", "inout"):
            rows.append(
                f'<TR><TD PORT="{port_id}" ALIGN="LEFT" '
                f'BGCOLOR="#DBEAFE">{esc(pin)}</TD>'
                f'<TD ALIGN="LEFT">IN</TD></TR>'
            )

            for bit in bits:
                if isinstance(bit, int):
                    sinks[bit].append((node_id, port_id))

        if direction in ("output", "inout"):
            rows.append(
                f'<TR><TD ALIGN="RIGHT">OUT</TD>'
                f'<TD PORT="{port_id}" ALIGN="RIGHT" '
                f'BGCOLOR="#DCFCE7">{esc(pin)}</TD></TR>'
            )

            for bit in bits:
                if isinstance(bit, int):
                    drivers[bit].append((node_id, port_id))

    table = (
        '<<TABLE BORDER="1" CELLBORDER="1" '
        'CELLSPACING="0" CELLPADDING="4" COLOR="'
        + border + '">'
        + ''.join(rows)
        + '</TABLE>>'
    )

    lines.append(f'{node_id} [shape=plain, label={table}];')


# Draw primary input and output ports
for port_name, port in ports.items():

    direction = port["direction"]
    bits = port["bits"]

    for index, bit in enumerate(bits):

        if not isinstance(bit, int):
            continue

        label = port_name
        if len(bits) > 1:
            label += f"[{index}]"

        io_id = f"io_{len(lines)}"

        lines.append(
            f'{io_id} [shape=ellipse, style=filled, '
            f'fillcolor="#0F172A", fontcolor="white", '
            f'color="#38BDF8", label="{esc(label)}"];'
        )

        if direction == "input":
            drivers[bit].append((io_id, None))

        elif direction == "output":
            sinks[bit].append((io_id, None))


# Draw real net connections
for bit, source_list in drivers.items():

    destination_list = sinks.get(bit, [])

    wire_label = bit_names.get(bit, "")

    for src_node, src_pin in source_list:

        for dst_node, dst_pin in destination_list:

            if src_node == dst_node:
                continue

            source = src_node
            destination = dst_node

            if src_pin:
                source += f":{src_pin}:e"

            if dst_pin:
                destination += f":{dst_pin}:w"

            label = esc(wire_label)

            lines.append(
                f'{source} -> {destination} '
                f'[label="{label}"];'
            )


# Colour legend
lines.append('subgraph cluster_legend {')
lines.append('label="CELL COLOUR LEGEND";')
lines.append('style="rounded"; color="#CBD5E1";')
lines.append('fontsize=11; fontcolor="#0F172A";')

legend = [
    ("Sequential / DFF", "#F59E0B"),
    ("MUX", "#8B5CF6"),
    ("XOR / XNOR", "#0891B2"),
    ("AND / NAND", "#2563EB"),
    ("OR / NOR", "#16A34A"),
    ("INV / NOT", "#DC2626"),
    ("Buffer", "#64748B"),
]

for i, (name, color) in enumerate(legend):
    lines.append(
        f'legend{i} [shape=box, style="filled,rounded", '
        f'fillcolor="{color}", fontcolor="white", '
        f'label="{name}"];'
    )

lines.append('}')

lines.append('}')

with open(dot_file, "w") as f:
    f.write("\n".join(lines))

print("==========================================")
print(" SKY130 CIRCUIT DIAGRAM SOURCE GENERATED")
print("==========================================")
print("Top module       :", top)
print("Mapped cells     :", len(cells))
print("Top-level ports  :", len(ports))
print("Net names        :", len(netnames))
print("DOT output       :", dot_file)
print("==========================================")
