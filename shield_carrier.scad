include <BOSL2/std.scad>

// Shield carrier: rectangular tube bracket for holding a PCB shield/daughterboard.
// Pure BOSL2 utility — no jl_scad needed.
//   w, d        — inner width/depth (fits over board edges)
//   h           — tube height
//   wall        — tube wall thickness
//   rounding    — inner corner radius (0 = sharp)
//   anchor/spin/orient — standard BOSL2 attachment args
module shield_carrier(w, d, h=7.5, wall=2, rounding=0, anchor=CENTER, spin=0, orient=UP) {
    rect_tube(isize=[w, d], wall=wall, rounding=rounding, h=h,
              anchor=anchor, spin=spin, orient=orient)
        children();
}

if (is_undef(_skip_render)) shield_carrier(30, 40, h=10);
