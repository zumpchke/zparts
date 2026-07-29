include <BOSL2/std.scad>
include <jl_scad/box.scad>
use <jl_scad/parts.scad>
use <zparts/shield_carrier.scad>

// MAX3485 RS485-to-DB9 breakout board
// Board: 19.3 x 13.3 mm, ~10mm tall, no mounting holes.
// Uses shield_carrier bracket to secure to enclosure wall.
//
//   max3485()                          Standalone / attachable footprint.
//                                      Ghost board + shield carrier.
//   max3485_jl(host_thickness, ...)    jl_scad box_part(...) drop-in.
//                                      Carrier sits on floor, wraps board.

$fn = 32;

MAX3485_W = 19.3;
MAX3485_D = 13.3;
MAX3485_H = 10;

// Carrier adds clearance around the board
CARRIER_CLEARANCE = 0.5;  // per side
CARRIER_W = MAX3485_W + 2 * CARRIER_CLEARANCE;
CARRIER_D = MAX3485_D + 2 * CARRIER_CLEARANCE;

module max3485(anchor=CENTER, spin=0, orient=UP) {
    total_h = MAX3485_H;  // board height; carrier is short, board sticks up
    anchors = [
        named_anchor("mount", [0, 0, -total_h/2], DOWN),
    ];
    attachable(anchor, spin, orient,
               size=[MAX3485_W, MAX3485_D, total_h],
               anchors=anchors) {
        tag_this("ghost") {
            // Board body
            cuboid([MAX3485_W, MAX3485_D, MAX3485_H]);
            // Carrier bracket around base
            down(MAX3485_H/2) shield_carrier(CARRIER_W, CARRIER_D, h=7.5, wall=1.5);
        }
        children();
    }
}

// jl_scad variant: carrier on floor, board rises above it.
module max3485_jl(host_thickness=3, carrier_h=7.5, carrier_wall=1.5) {
    // Ghost board preview
    box_preview() up(host_thickness + MAX3485_H/2) cuboid([MAX3485_W, MAX3485_D, MAX3485_H]);
    // Carrier bracket on the floor
    shield_carrier(CARRIER_W, CARRIER_D, h=carrier_h, wall=carrier_wall);
}

if (is_undef(_skip_render)) max3485() show_anchors(s=6, std=false);