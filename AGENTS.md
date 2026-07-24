# AGENTS.md

zparts is a small library of BOSL2-attachable footprint modules for common
electronic components (breadboards, RJ45 jacks, wire connectors). Each part
exposes named anchors so downstream projects can attach standoffs, screws,
and enclosure features without knowing the part's internal coordinates.

**Rule:** zparts depends only on BOSL2. It never `include`s jl_scad or any
project-specific library. Rendering-mode concerns (preview vs print) are
handled via the `tag_this("ghost")` convention below, which is pure BOSL2.

---

## Conventions

### Ghost / print pattern

Each part's visualization geometry (the visual stand-in for the physical
component) is wrapped in `tag_this("ghost")`. Any real printable geometry
that lives inside the same module (a cradle, retention clip, etc.) is
*not* tagged, because `tag_this()` doesn't propagate to descendants.

Consumers choose what to render:

```scad
// Preview: everything visible, including the ghost body
wire_connector() attach("mount") standoff(id=3, od=5, h=5);

// Print: drop the ghost body; anchors are unaffected, real geometry stays
hide("ghost") wire_connector() attach("mount") standoff(id=3, od=5, h=5);
```

`hide()` and `tag_this()` are both BOSL2 built-ins (see
`~/repos/BOSL2/attachments.scad`). No jl_scad involvement.

In a jl_scad `box_make(...)` context the wrap can live at the top of the
box body:

```scad
box_make(print=true) box_shell_base_lid(...) {
    hide("ghost") {   // strip ghosts from every zparts part in this scope
        wire_connector() attach("mount") standoff(...);
        rj45_screw()    attach("screw_L") screw_hole("M3,10");
    }
}
```

### Fit tolerances

Use BOSL2's global `$slop` via `get_slop()` for any mating dimension
(cradle inner opening, pilot pin OD, etc.). Never hardcode.

```scad
rect_tube(isize=[WC_W + 2*get_slop(), WC_D + 2*get_slop()], wall=wall, ...);
```

Consuming projects set `$slop` once at the top of their file. Default is 0.

### Anchor debugging

Render just the named anchors (skip the 27 standard ones):

```scad
wire_connector() show_anchors(s=6, std=false);
```

Cyan arrows + white flags mark named anchors with their name in black.
Verify both position and orient — the orient controls which way attached
children face.

---

## Parts

### smallbb — half-size breadboard

`smallbb.scad`

Wraps `raw/Mini-Breadboard YELLOW-2.stl` (170-hole breadboard from
GrabCAD: https://grabcad.com/library/mini-breadboard-170-holes-1) in an
attachable frame with two mounting-hole anchors. The STL already has the
holes; no `diff()` needed.

**Anchors:** `mount_TL`, `mount_TR` — both point UP at the top-face
mounting-hole positions.

**Constants:** `BB_W = 55.5`, `BB_D = 83.3`, `BB_H = 9.1`,
`BB_MOUNT_Y = 18.75`, `BB_MOUNT_Z = -4.5`.

### rj45_screw — RJ45 screw-terminal jack

`rj45_screw.scad`

Base plate + jack body, with through-holes cut in the plate.

**Anchors:**
- `mount` at assembly bottom, orient DOWN.
- `screw_L`, `screw_R` on the plate's top face, orient UP — for attaching
  screws/nuts through the mounting holes.

**Constants:** `RJ45_BASE = [24.49, 33, 1.6]`, `RJ45_BODY = [16.5, 15.5, 13]`,
`RJ45_HOLE_D = 3`. Hole X/Y offsets are exposed as `RJ45_HOLE_X`,
`RJ45_HOLE_Y` and used by both the `diff()` cutters and the anchor
list — single source of truth.

The `attachable` size uses `total_h = RJ45_BASE.z + RJ45_BODY.z` so
standard anchors (`TOP`/`BOTTOM`/etc.) line up with the real extremes.
Missing that is the classic bug — if `size.z` reflects only the body,
`TOP` lands inside the assembly.

### wire_connector — CH-2 spring clamp connector

`wire_connector.scad`

Ghost body representing the physical CH-2 connector, plus a printable
`rect_tube` cradle at its base that acts as a drop-in locator.

**Anchors:** `mount` at the underside, orient DOWN.

**Constants:** `WC_W = 19.4`, `WC_D = 17.2`, `WC_H = 13.2`.

Notes:
- The `cuboid` visualization is tagged `ghost`; the `rect_tube` cradle is
  not, so `hide("ghost")` in the consumer keeps the cradle but drops the
  block.
- `rect_tube` uses `get_slop()` for its inner-envelope tolerance.
- Known limitation: the `mount` anchor is at `-WC_H/2` (the ghost's
  bottom), but the cradle extends further below. If you need the anchor
  on the print's actual bottom face, use `-WC_H/2 - cradle_h`.

---

## BOSL2 gotchas encountered building these parts

1. **`attachable()` requires a shape descriptor.** Passing only
   `anchors=` errors out. Provide `size=`, `r=`, `d=`, `path=`, `vnf=`,
   or `extent=`.

2. **Forward `children()` explicitly.** OpenSCAD does not auto-propagate
   children. If module A wraps attachable module B, A must call
   `B() children();` (or invoke `children()` somewhere) — otherwise the
   consumer's `A() { attach(...) ... }` children are silently dropped
   before reaching B's `attachable()` block.

3. **`attachable()` `size` is in the local frame.** Rotations inside
   the block (e.g. `rotate([90,0,0]) import(...)`) swap axes relative to
   the file, so `size` must match post-rotation dimensions.

4. **Size must include the whole part.** If geometry stacks (base plate
   + body), compute `total_h = base.z + body.z` and use that. Standard
   anchors resolve against `size`, not against the geometry.

5. **Center the geometry inside the attachable frame.** `attachable()`
   assumes the shape is centered at the origin. If you build with
   `anchor=BOTTOM` or similar, either match by shifting (`down(h/2)
   ...`) or pass `cp=` to `attachable()`.

6. **`named_anchor()` spin defaults to 0.** No need for the trailing
   `, 0`.

7. **`tag_this("ghost")` vs `tag("ghost")`.** `tag_this` sets `$tag` at
   the current level only; children/descendants keep their own tags.
   `tag` propagates and requires re-tagging children to escape a
   `hide()` filter. For the ghost/cradle pattern, `tag_this` is the right
   choice — a printable cradle nested inside the ghost cuboid stays
   visible under `hide("ghost")`.

8. **Reserve the tag name `"keep"` carefully.** It has special meaning
   inside `diff()` (protects geometry from subtraction). Prefer neutral
   names like `"ghost"` for visualization stand-ins.

9. **`rect_tube` `position(BOTTOM)` straddles the face.** The tube's
   center lands on the parent's face, so half of it is inside the
   parent. Add `anchor=TOP` on the `rect_tube` to hang it fully below.

10. **`show_anchors()` needs the parent's `$parent_geom`.** Call it as
    a child of the attachable: `part() show_anchors(...)`. `std=false`
    hides the 27 standard arrows so named anchors are readable.

---

## Testing

### Render via CLI

Catches CGAL failures that GUI preview hides:

```bash
/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o /tmp/out.stl <file.scad>
```

Success looks like `Top level object is a 3D object (manifold)` and
`Status: NoError`.

### Visual anchor check

```scad
wire_connector() show_anchors(s=6, std=false);
```

Confirms both position and orient of each named anchor.

### Common failures

- **"Unknown anchor"** — the named anchor isn't in the `anchors=` array
  passed to `attachable()`. Check spelling and that it's registered on
  the correct parent.
- **`attachable()` errors** — missing shape descriptor (see gotcha 1).
- **Children silently dropped** — forgot `children()` in a wrapper (see
  gotcha 2).
- **`rect_tube` in the wrong Z** — `position(BOTTOM)` centers it; add
  `anchor=TOP` on the tube (see gotcha 9).

---

## jl_scad integration (consumer-side, not zparts)

zparts does not depend on jl_scad. This section documents how consuming
projects (e.g. `poe_shutter/`) combine the two — the jl_scad calls live in
the consumer, not here.

### Layout (`~/Documents/OpenSCAD/libraries/jl_scad/`)

- `box.scad` — `box_shell_base_lid()`, `box_make()`, `box_part()`,
  `box_cut()`, `box_cutout()`, `box_preview()`, `box_half()`, `box_pos()`.
- `parts.scad` — `standoff()`, `box_screw_clamp()`,
  `box_screw_clamp_cube()`, `box_standoff_clamp()`, and pre-built
  component modules like `d1mini()`, `dht22()`, `grove_oled_066()`.
- `utils.scad` — `X()`, `Y()`, `Z()`, `M()` translation shortcuts,
  `cut_inspect()`.
- `reset_transform.scad` — `$_matrix` tracking helpers.
- `parts/` — additional pre-built component .scad files.

### Consumer skeleton

```scad
include <BOSL2/std.scad>
include <jl_scad/utils.scad>
include <jl_scad/box.scad>
include <jl_scad/parts.scad>
use <zparts/wire_connector.scad>

$slop = 0.1;

box_make(print=true, explode=0)
box_shell_base_lid([75,82,48], wall_sides=1.5, wall_top=1.5, rim_height=2,
                   base_height=38, walls_outside=true)
hide("ghost") {   // strip ghost visualization from every zparts part
    box_part(TOP, CENTER) X(15) Y(-15)
        wire_connector() attach("mount") standoff(id=3, od=5, h=5);

    for (a = [BACK+LEFT, FRONT+LEFT, BACK+RIGHT, FRONT+RIGHT])
        M(a) position(a) M(a * -1.2) box_screw_clamp_cube(anchor=a, gap=0.1);
}
```

### jl_scad idioms observed in `poe_shutter/shutter.scad`

- `box_part(side, half_anchor) { ... }` — positions children on a
  specific face of a specific half.
- `box_preview() ...` — geometry only rendered in preview mode; auto-
  suppressed from print output. Uses jl_scad's own tag system, unrelated
  to zparts' `"ghost"` tag.
- `box_cut() ...` — geometry included in the print, colored as a cut
  surface.
- `box_cutout(shape) ...` — subtracts a shape through the box wall.
- `hide_this() cuboid(...) { position(...) real_thing(); }` — BOSL2
  idiom for using an invisible parent purely to position children.
- Global settings like `$box_cut_color`, `$box_outside_color`,
  `$box_inside_color` are library defaults; poe_shutter doesn't override
  them.

### Compound patterns

jl_scad's own `parts.scad` (see `d1mini`, `grove_oled_066`, `dht22`)
embeds `box_preview(...)` calls inside part modules. This couples the
part to jl_scad. zparts avoids that coupling by using `tag_this("ghost")`
instead — the caller decides visibility with `hide("ghost")`, without
zparts knowing jl_scad exists.
