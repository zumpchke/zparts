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
- `BB_MOUNT_Z = 1.5` — Z height of mounting holes

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
