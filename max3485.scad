include <BOSL2/std.scad>
include <jl_scad/box.scad>
use <jl_scad/parts.scad>
use <zparts/shield_carrier.scad>

// MAX3485 RS485-to-DB9 breakout board
// Board: 19.3 x 13.3 mm, ~10mm tall, no mounting holes.
// Held by a shield_carrier bracket that wraps the board's lower portion.
//
//   max3485()                     Standalone / attachable footprint.
//                                 Ghost board + carrier, "mount" anchor.
//   max3485_jl(carrier_h, ...)    jl_scad box_part(...) drop-in. Origin sits
//                                 on the box's inside floor face; the carrier
//                                 rises from it and the board sits inside.

$fn = 32;

MAX3485_W = 19.3;
MAX3485_D = 13.3;
// Ghost height is a CLEARANCE envelope, not the bare board. Covers the PCB,
// the 0.1" pin headers, and the Dupont jumper shells seated on them — so the
// preview shows how much vertical room the assembly actually needs.
MAX3485_H = 15;

MAX3485_CARRIER_H    = 7.5;
MAX3485_CARRIER_WALL = 0.8;   // thin so the walls can flex for the press fit

// Interference fit: the carrier opening is deliberately UNDERSIZE so the
// board press-fits and is held by friction against the walls. Positive
// values squeeze tighter. Print a test coupon and tune before committing
// to a full enclosure — too tight bows the PCB or cracks the carrier,
// too loose and the board rattles.
MAX3485_CARRIER_PRESS = 0.1;   // per axis, total (not per side)

function max3485_carrier_w() = MAX3485_W - MAX3485_CARRIER_PRESS;
function max3485_carrier_d() = MAX3485_D - MAX3485_CARRIER_PRESS;

module max3485(anchor=CENTER, spin=0, orient=UP) {
    anchors = [
        named_anchor("mount", [0, 0, -MAX3485_H/2], DOWN),
    ];
    attachable(anchor, spin, orient,
               size=[MAX3485_W, MAX3485_D, MAX3485_H],
               anchors=anchors) {
        union() {
            // ghost board — hideable via hide("ghost")
            tag_this("ghost") cuboid([MAX3485_W, MAX3485_D, MAX3485_H]);
            // carrier — real printed geometry, rises from the board's base
            down(MAX3485_H/2)
                shield_carrier(max3485_carrier_w(), max3485_carrier_d(),
                               h=MAX3485_CARRIER_H, wall=MAX3485_CARRIER_WALL,
                               anchor=BOTTOM);
        }
        children();
    }
}

module max3485_jl(carrier_h=MAX3485_CARRIER_H, carrier_wall=MAX3485_CARRIER_WALL) {
    // ghost board — preview only, resting on the floor
    box_preview() up(MAX3485_H/2) cuboid([MAX3485_W, MAX3485_D, MAX3485_H]);
    // carrier — real printed geometry, rising from the floor
    shield_carrier(max3485_carrier_w(), max3485_carrier_d(),
                   h=carrier_h, wall=carrier_wall, anchor=BOTTOM);
}

// Standalone test: flat surface + carrier + ghost body, to preview how the
// module looks mounted on a box floor.
module max3485_test() {
    color("steelblue", 0.3) cuboid([MAX3485_W*1.125, MAX3485_D*1.125, 3], anchor=TOP);
    max3485_jl();
}

if (is_undef(_skip_render)) max3485_test();
