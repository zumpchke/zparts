# AGENTS.md

## smallbb Breadboard Part

### Location
`smallbb.scad`

### Purpose
Half-size (170-hole) breadboard STL with named attachment anchors for external consumers (e.g., standoffs, brackets).

### STL Source
`raw/Mini-Breadboard YELLOW-2.stl` — from GrabCAD (https://grabcad.com/library/mini-breadboard-170-holes-1)

### Module Structure

- **`breadboard(anchors=[], anchor, spin, orient)`** — Uses `attachable(anchor, spin, orient, size=[BB_D, BB_W, BB_H], anchors=anchors)` to wrap the STL import (rotated 90° on X axis) and pass through children. Accepts an array of `named_anchor()`s for attachment points.
- **`smallbb()`** — Defines `named_anchor()` entries for the two mounting hole positions and passes them to `breadboard()`. No geometry is cut — the breadboard already has holes.

### BOSL2 Named Anchor System (from BOSL2 Tutorials)

**`named_anchor("name", point, orientation)`** — Creates a named attachment point with a position and orientation vector. Spin defaults to 0. Used to define logical attachment points that aren't on the shape's perimeter.

**`attachable(anchor, spin, orient, size=..., anchors=...)`** — Wraps geometry in an attachable context and registers the provided `named_anchor()` entries. The `anchors` array is passed as a keyword argument.

**`attach("name")`** — Snaps child objects to a named anchor position from a parent attachable. The child inherits the anchor's position, orientation, and spin.

### Usage Pattern

```scad
// Define attachable geometry that accepts named anchors
module breadboard(anchors=[], anchor=CENTER, spin=0, orient=UP) {
    attachable(anchor, spin, orient, size=[BB_D, BB_W, BB_H], anchors=anchors) {
        rotate([90, 0, 0])
            import("raw/Mini-Breadboard YELLOW-2.stl");
        children();
    }
}

// Create named anchors and pass them to the attachable
module smallbb() {
    anchors = [
        named_anchor("mount_TL", [0, BB_MOUNT_Y, BB_MOUNT_Z], UP),
        named_anchor("mount_TR", [0, -BB_MOUNT_Y, BB_MOUNT_Z], UP),
    ];
    breadboard(anchors=anchors) children();
}

// External code attaches objects to named anchors
smallbb() {
    attach("mount_TL") standoff_module();
    attach("mount_TR") standoff_module();
}
```

### Constants
- `BB_W = 55.5` — breadboard width (mm)
- `BB_D = 83.3` — breadboard depth (mm)
- `BB_H = 9.1` — breadboard height (mm)
- `BB_MOUNT_Y = 18.75` — Y offset of mounting holes from center
- `BB_MOUNT_Z = -4.5` — Z height of mounting holes

### Design Decisions
- No `diff()` or hole cutting — the breadboard STL already has mounting holes
- `named_anchor()` with `anchors=` parameter is used instead of `tag()` — this is the proper BOSL2 pattern for defining attachment points on a module that external code will consume
- Orientation is `UP` so attached objects inherit the correct upright orientation
- `breadboard()` accepts `anchors=[]` by default so it can be used standalone without anchors
- `smallbb()` composes the breadboard + named anchors for attachment workflows

### BOSL2 Lessons Learned

1. **`attachable()` requires a shape descriptor.** `attachable(anchors=...)` alone will error — it needs `size=`, `r=`, `d=`, `path=`, `vnf=`, or `extent=` to build its bounding box and resolve positional anchors like TOP/LEFT.

2. **Always forward `children()` when wrapping attachables.** If module A wraps module B (which is attachable), and external code calls `A() { attach(...) }`, the children are passed to A. If A doesn't forward `children()` to B, they're silently dropped and never reach the `attachable()` block.

3. **`size` is in the attachable's local coordinate space.** The `size=[BB_D, BB_W, BB_H]` order accounts for the 90° X rotation inside the module body, which swaps the width/depth axes relative to the local space.

4. **`named_anchor()` spin defaults to 0.** The trailing `, 0` in `named_anchor("name", point, UP, 0)` is noise — just use `named_anchor("name", point, UP)`.

5. **`attachable()` positional params come before keyword params.** The signature is `attachable(anchor, spin, orient, size=..., anchors=...)` — positional args for attachment behavior, keyword args for geometry and anchors.

6. **`rect_tube` as a child of another shape attaches at that shape's transform.** When `rect_tube` is a child of `cuboid`, it inherits the cuboid's transform context. Use `position(BOTTOM)` on the `rect_tube` to place it at the cube's bottom face. The `rect_tube`'s `size` parameter takes `[width, depth]` (2D), not 3D.

7. **Placement guides can use short `rect_tube` children.** A `rect_tube` used as a placement/alignment guide (e.g., 2mm tall) is a child of the main geometry. It doesn't affect the attachable's `size=` — that should reflect the actual part dimensions, not guide geometry.

8. **Remove example calls before shipping.** The `wire_connector()` call at the bottom of the file (for standalone preview) causes `attach("mount")` to fail if the anchor isn't defined yet. Remove example code that references anchors before the attachable is properly set up, or test with `wire_connector()` alone (no children).

---

## wire_connector Part

### Location
`wire_connector.scad`

### Purpose
2-pin spring clamp wire connector (no-solder splice) with bottom mount point.

### Dimensions
19.4 × 17.2 × 13.2mm

### Module Structure

- **`base_connector(anchors=[], anchor, spin, orient)`** — Attachable base with `cuboid([WC_W, WC_D, WC_H])` and a `rect_tube` child as a 2mm placement guide at the bottom.
- **`wire_connector()`** — Defines `named_anchor("mount", [0, 0, -WC_H/2], DOWN)` and calls `base_connector(anchors=anchors) children()`.

### Usage Pattern

```scad
module base_connector(anchors=[], anchor=CENTER, spin=0, orient=UP) {
    attachable(anchor, spin, orient, size=[WC_W, WC_D, WC_H], anchors=anchors) {
        cuboid([WC_W, WC_D, WC_H]) {
            position(BOTTOM)
                rect_tube(h=2, size=[WC_W + 4, WC_D + 4], wall=1.5, rounding=1);
        }
        children();
    }
}

module wire_connector() {
    anchors = [
        named_anchor("mount", [0, 0, -WC_H/2], DOWN)
    ];
    base_connector(anchors=anchors) children();
}

// External code attaches objects to named anchors
wire_connector() {
    attach("mount") cyl(d=4, h=10, anchor=CENTER);
}
```

### Constants
- `WC_W = 19.4` — width (mm)
- `WC_D = 17.2` — depth (mm)
- `WC_H = 13.2` — height (mm)

### Location
`~/Documents/OpenSCAD/libraries/jl_scad/` — cloned as a git repo into OpenSCAD's user libraries folder.

### Structure
```
jl_scad/
├── utils.scad          — X(), Y(), Z(), M() translation helpers, cut_inspect()
├── box.scad            — box_shell_base_lid(), box_make(), box_part(), box_cutout(), box_preview()
├── parts.scad          — standoff(), screw_hole(), box_standoff_clamp(), box_preview(), box_cutout(), etc.
├── reset_transform.scad — $_matrix tracking, save_transform(), reset_transform()
├── parts/              — Component modules (esp32_wroom_32.scad, qapass_1602a_led.scad)
├── examples/           — Example projects
├── images/             — Documentation images
└── README.md           — Installation and usage docs
```

### How jl_scad is Used (from poe_shutter/shutter.scad)

**Includes:**
```scad
include <jl_scad/utils.scad>
include <jl_scad/box.scad>
include <jl_scad/parts.scad>
```

**Box shell definition:**
```scad
box_shell_base_lid([75,82,box_height], wall_sides=1.5, wall_top=1.5, rim_gap=0,
    rbot=1.5, rbot_inside=0, rtop=1, rtop_inside=0, rsides=1, rim_height=2,
    walls_outside=true, base_height=box_height-10)
```
- `base_height` creates a base+lid system (base is 10mm shorter than total)
- `walls_outside=true` — walls extend outside the footprint
- `rim_height` — rim on top half for lid fit

**box_make() wrapper:**
```scad
box_make(print=true, explode=0, hide_box=false, hide_parts=false, hide_previews=false)
```
- Controls rendering mode (print, preview, explode)
- `print=true` — outputs final geometry
- `explode=0` — no exploded view offset

**Part placement with box_part():**
```scad
box_part(BOTTOM, CENTER) X(14) {
    box_preview() Z(5) Z(1.6/2) Z(0) Y(-25) rj45_screw();
}
```
- `box_part(side, anchor)` — combines `box_half()` + `box_pos()` for convenient placement
- `BOTTOM` — which box half (base or lid)
- `CENTER` — which face of that half
- `box_preview()` — shows transparent preview, not included in final render
- `box_cut()` — shows cut surface, included in final render
- `box_cutout()` — creates cutout geometry in the box wall

**Part placement with box_half() + box_pos():**
```scad
box_half(BOT, inside=false)
    box_pos(LEFT, undef)
        standoff(id=3, od=5, h=5);
```
- `box_half(half, inside)` — selects which box half and whether inside/outside
- `box_pos(anchor, side)` — positions children at the selected face
- `inside=false` — part is on the outside of the box

**Components used:**
- `rj45()` / `rj45_screw()` — RJ45 jacks
- `lm2596s()` — LM2596S buck converter
- `shield()` — Wemos shield
- `shield_carrier(x, y, h, corner, wall)` — shield mounting carrier
- `d1()` — D1 mini board
- `max485()` — MAX485 module
- `standoff(id, od, h)` — mounting standoffs
- `screw_hole("M2.5,20", head="flat", counterbore=0, anchor=TOP)` — screw holes

**Text labels:**
```scad
box_part(TOP+RIGHT, TOP, inside=false) text3d("RIGHT", h=0.25, size=3, anchor=BOTTOM+LEFT+BACK);
```
- `TOP+RIGHT` — right face of the top half
- `inside=false` — text on outside surface

**Global settings:**
- `$box_cut_color = "#977"` — cut surface color
- `$box_outside_color = "#ccc"` — outside color
- `$box_inside_color = "#a99"` — inside color
- `$box_preview_color = "#77f8"` — preview transparency color
- `$box_inside_overlap = 0.0001` — overlap for boolean operations

### Key jl_scad Patterns

1. **`box_part(side+half, anchor)`** — convenience wrapper combining half selection and face positioning
2. **`box_preview()`** — transparent preview mode for parts not in final render
3. **`box_cut()`** — included parts shown with cut surface color
4. **`box_cutout(shape)`** — creates cutout geometry in box walls
5. **`box_half(half, inside)` + `box_pos(anchor, side)`** — lower-level part placement
6. **`$parent_size.z`** — available inside parts for getting box height
7. **`box_standoff_clamp()`** — standoff with screw clamp for PCB mounting
8. **`text3d()`** — 3D text labels on box faces
9. **`hide_this()`** — hides preview geometry from final render
10. **`color()`** — colors parts differently for visual distinction

### jl_scad/parts/ Subdirectory
- **`esp32_wroom_32.scad`** — ESP32 module with integrated standoff mounting, USB-C cutout, and `box_preview()`
- **`qapass_1602a_led.scad`** — 1602 LCD module with standoff mounting and cutout

### reset_transform.scad
- Overrides `translate()`, `rotate()`, `scale()`, `multmatrix()` to track transforms in `$_matrix`
- `save_transform()` — resets `$_matrix` to IDENT
- `reset_transform()` — applies inverse matrix to undo accumulated transforms
- Used for complex nested transform scenarios

---

## Testing

### OpenSCAD CLI Rendering
Test changes by compiling to STL via the command line — catches syntax errors and CGAL failures that the GUI preview might hide:

```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o /tmp/out.stl <file.scad>
```

**Check the output for:**
- `Top level object is a 3D object (manifold)` — good, manifold geometry
- `Status: NoError` — no CGAL errors
- `ERROR:` lines — compilation failure, check the trace

### Debugging Anchors
Use `show_anchors()` to verify anchor positions before committing:

```scad
wire_connector() show_anchors(s=15);
```

This renders arrows and labels at all anchor positions (standard + named) without modifying geometry.

### Stashing Before Testing
If a change causes compile errors, stash to revert:

```bash
git stash          # save working changes
git stash pop      # restore them
```

### Common Pitfalls
- **`attach()` fails with "Unknown anchor"** — the named anchor wasn't registered in the parent's `attachable()`. Check that `named_anchor()` is in the `anchors=` array passed to `attachable()`.
- **`attachable()` errors** — missing `size=` parameter. Always provide a shape descriptor.
- **Children silently dropped** — forgot to forward `children()` through a wrapper module.
- **`rect_tube` wrong position** — use `position(BOTTOM)` on the child, not `anchor=BOTTOM` on the `rect_tube` itself.
