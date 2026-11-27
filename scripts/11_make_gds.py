import os
import pya

design_name = os.environ["DESIGN_NAME"]
in_def      = os.environ["IN_DEF"]
stdcell_gds = os.environ["STDCELL_GDS"]
tech_file   = os.environ["TECH_FILE"]
tlef        = os.environ["TLEF"]
mlef        = os.environ["MLEF"]
out_gds     = os.environ["OUT_GDS"]

tech = pya.Technology()
tech.load(tech_file)
opts = tech.load_layout_options
cfg = opts.lefdef_config
cfg.lef_files = [tlef, mlef]
cfg.read_lef_with_def = False
if cfg.map_file and not os.path.isabs(cfg.map_file):
    cand = os.path.join(os.path.dirname(tech_file), cfg.map_file)
    if os.path.exists(cand):
        cfg.map_file = cand
opts.lefdef_config = cfg

layout = pya.Layout()
print("[INFO] Reading DEF:", in_def)
layout.read(in_def, opts)

print("[INFO] Merging standard-cell GDS:", stdcell_gds)
gds_opts = pya.LoadLayoutOptions()
gds_opts.cell_conflict_resolution = pya.LoadLayoutOptions.OverwriteCell
layout.read(stdcell_gds, gds_opts)

top = layout.cell(design_name)
if top is None:
    raise RuntimeError(f"Top cell '{design_name}' not found. Top cells: {[c.name for c in layout.top_cells()[:10]]}")

print("[INFO] Writing final GDS:", out_gds)
top.write(out_gds)
print("[INFO] GDS STREAM-OUT COMPLETE")
