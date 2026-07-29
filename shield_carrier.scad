include <BOSL2/std.scad>

// Shield carrier: rectangular tube bracket for holding a PCB shield/daughterboard.
// Pure BOSL2 utility — no jl_scad needed.
//   w, d        — inner width/depth (fits over board edges)
//   h           — tube height
//   wall        — tube wall thickness
//   rounding    — inner corner radius (0 = sharp)
module shield_carrier(w, d, h=7.5, wall=2, rounding=0) {
    diff() {
        rect_tube(isize=[w, d], wall=wall, rounding=rounding, h=h);
    }
    children();
}

if (is_undef(_skip_render)) shield_carrier(30, 40, h=10);
