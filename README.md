 RTL-to-GDSII-of-a-Small-RISC-V-Core
What it does: Run a full RTL-to-GDSII flow on an open PDK. Track timing, area and power at every stage, fix violations, and compare results across floorplan, utilization and clock settings. Tools: OpenLane, Yosys, OpenROAD, OpenSTA, Magic, KLayout, open PDKs (SkyWater 130nm, GF180
32-Bit RISC-V Processor | RTL to GDSII using SkyWater 130nm

![ISA](https://img.shields.io/badge/ISA-RV32I-blue)
![PDK](https://img.shields.io/badge/PDK-SkyWater%20130nm-orange)
![EDA](https://img.shields.io/badge/EDA-Open%20Source-brightgreen)
![LVS](https://img.shields.io/badge/Netgen-LVS%20Matched-success)

 About the Project:

   I worked on implementing a 32-bit RISC-V processor core (RV32I) and taking it through the ASIC physical design flow, from Verilog RTL to GDSII layout.

  I used the SkyWater 130nm High-Density PDK for this project. The main idea was to understand how a digital design moves from RTL code to a physical chip layout and how each stage affects the final implementation.

 I used Yosys for synthesis, OpenROAD for physical design, OpenSTA for timing analysis, Magic for layout inspection and extraction, Netgen for LVS checking, and KLayout to view the final GDSII layout.

This project helped me understand the practical steps involved in ASIC back-end design, especially placement, clock tree synthesis, routing, timing analysis and physical verification.

Tools and Technologies

| Tool | What I used it for |
|---|---|
| Verilog HDL | RTL design of the RISC-V core |
| Yosys | Logic synthesis and technology mapping |
| OpenROAD | Floorplanning, placement, CTS and routing |
| OpenSTA | Setup and hold timing analysis |
| OpenRCX | Parasitic extraction |
| Magic | Layout inspection, DRC and SPICE extraction |
| Netgen | LVS comparison |
| KLayout | Viewing and inspecting the GDSII layout |
| SkyWater SKY130 HD | Target standard-cell technology |

 Design Flow

The project follows this sequence:

Verilog RTL
     |
     v
Yosys Synthesis
     |
     v
Technology-Mapped Netlist
     |
     v
Floorplanning
     |
     v
Power Planning (PDN)
     |
     v
Standard-Cell Placement
     |
     v
Clock Tree Synthesis (CTS)
     |
     v
Global Routing
     |
     v
Detailed Routing
     |
     v
Parasitic Extraction (SPEF)
     |
     v
Post-Route Timing Analysis (STA)
     |
     v
GDSII Stream-Out
     |
     +------------------+
     |                  |
     v                  v
    DRC                LVS
   Magic              Netgen
     |                  |
     v                  v
Physical Rule       Netlist
   Checking         Comparison


 What I Did in Each Stage

1. RTL Design and Synthesis

I started with the Verilog RTL of the RISC-V processor and used Yosys to check and synthesize the design.

I then mapped the logic into the SkyWater 130nm High-Density standard-cell library. The synthesized netlist was used as the input for the physical design stages.

Tool: Yosys

 2. Floorplanning and Power Planning

After synthesis, I moved to the physical design stage using OpenROAD.

I defined the die and core area, configured placement utilization and assigned the I/O pins. I also worked on the Power Distribution Network (PDN) to connect the standard cells to the VDD and VSS power networks.

Tool: OpenROAD

 3. Standard-Cell Placement

In this stage, the synthesized cells were placed inside the floorplanned core area.

I worked on global placement and placement legalization. The goal was to arrange the cells properly while considering timing and routing congestion.

Tool: OpenROAD

 4. Clock Tree Synthesis

Once placement was completed, I worked on Clock Tree Synthesis.

The clock distribution network was created using clock buffers. This stage is important because the clock must reach the sequential elements with controlled insertion delay and skew.

Tool: OpenROAD

 5. Global and Detailed Routing

After CTS, I moved to routing.

Global routing estimates the paths for the connections, while detailed routing creates the actual metal interconnections between the cells.

I completed the detailed routing stage and generated the routed DEF and ODB files.

Tool: OpenROAD / TritonRoute

6. Parasitic Extraction and Timing Analysis

After routing, the interconnect resistance and capacitance were extracted.

I used OpenRCX to generate parasitic information and OpenSTA to analyse the timing of the design. The main parameters considered were setup slack, hold slack, WNS and TNS.

Tools: OpenRCX and OpenSTA

 7. GDSII Generation and Physical Verification

The final physical layout was exported in GDSII format and opened in KLayout for inspection.

I also used Magic to extract the layout netlist into SPICE format. This extracted netlist was compared against the reference netlist using Netgen.

The top-level LVS report showed that the two circuits matched uniquely.

Tools:Magic, Netgen and KLayout

 Current Project Results

Here are some of the results from my implementation:

| Parameter | Result |
|---|---|
| Processor | 32-bit RISC-V core |
| ISA | RV32I |
| Technology | SkyWater 130nm HD |
| Top module | `riscv_core` |
| Die dimensions | 399.105 × 399.105 µm |
| Detailed routing | Completed |
| Routed wirelength | Approximately 447,805 µm |
| Number of vias | 71,435 |
| Routed design files | DEF and ODB |
| Final GDSII file | `riscv_core_detailed_routed.gds` |
| GDSII file size | Approximately 27 MB |
| Netgen LVS | Top-level circuits match uniquely |

 LVS Result

The final Netgen report contains the following result:

Circuit 1: riscv_core
Circuit 2: riscv_core

Netlists match uniquely.

Device classes riscv_core and riscv_core are equivalent.

Final result: Circuits match uniquely.


This means the extracted layout netlist matched the reference netlist in the top-level Netgen comparison.

The independent Magic DRC report has also been generated. The final DRC violation count still needs to be confirmed before claiming a clean DRC result.

 Project Folder Structure


riscv-rtl-to-gdsii-sky130/
│
├── backend/
│   ├── inputs/
│   │   ├── rtl/
│   │   ├── sdc/
│   │   └── netlist/
│   │
│   ├── scripts/
│   │   └── Tcl and Python implementation scripts
│   │
│   ├── results/
│   │   ├── synthesis/
│   │   ├── floorplan/
│   │   ├── placement/
│   │   ├── cts/
│   │   ├── routing/
│   │   └── 09_signoff/
│   │
│   └── final_signoff/
│       ├── gds/
│       │   └── riscv_core_detailed_routed.gds
│       ├── lvs/
│       │   └── riscv_core_layout.spice
│       ├── drc/
│       └── scripts/
│
├── docs/
│   └── images/
│
└── README.md

 How to View the Results

Clone the repository:

git clone <your-repository-url>
cd riscv-rtl-to-gdsii-sky130

Open the GDSII layout in KLayout:
klayout backend/final_signoff/gds/riscv_core_detailed_routed.gds
gedit backend/results/09_signoff/riscv_lvs_report.log
Open the extracted layout SPICE file:
gedit backend/final_signoff/lvs/riscv_core_layout.spice
The complete implementation can be studied through the RTL, SDC constraints, Tcl scripts, generated layout files and verification reports.

 Challenges I Worked On

During this project, I had to deal with several practical issues in the physical design flow.

- Understanding how the synthesized netlist is used in the back-end flow.
- Handling placement and routing congestion.
- Debugging clock and power connectivity.
- Working with multiple metal layers during detailed routing.
- Extracting parasitic information for post-route timing analysis.
- Setting up Magic for GDSII import and layout extraction.
- Resolving netlist connectivity issues during LVS comparison.
- Checking the final GDSII layout and its verification reports.

Working through these issues gave me a better understanding of how the different EDA tools work together during ASIC implementation.

 What I Learned

Through this project, I gained practical experience with:

- Verilog RTL and logic synthesis.
- Sky130 technology mapping.
- ASIC floorplanning and PDN generation.
- Standard-cell placement and CTS.
- Global and detailed routing.
- Parasitic extraction and static timing analysis.
- GDSII layout inspection.
- DRC and LVS verification.


Project: 32-Bit RISC-V Processor Core  
Domain: VLSI / ASIC Physical Design  
Technology: SkyWater 130nm HD  
Flow: RTL-to-GDSII  
Tools: Yosys, OpenROAD, OpenSTA, OpenRCX, Magic, Netgen and KLayout
