include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <jl_scad/box.scad>

$fn = 32;

// Mini breadboard (self-adhesive, ~170 tie-point). Two molded pegs on the
// underside locate it — the printed host just needs matching holes,
// counterbored for M2 socket-head screws driven from the outside face.
MBB_W = 20;
MBB_D = 15;
MBB_H = 9.6;
MBB_PEG_X = 5;             // peg offset from center on X
MBB_PEG_D = 2;
MBB_PEG_H = 12.3 - 9.6;    // peg protrusion below the board (~2.7mm)

// Board body with the two molded pegs pointing down. Anchored BOTTOM so the
// board base sits at the origin — pegs poke into −Z.
module minibb(anchor=BOTTOM, spin=0, orient=UP) {
    cuboid([MBB_W, MBB_D, MBB_H], anchor=anchor, spin=spin, orient=orient)
        for (x = [-MBB_PEG_X, MBB_PEG_X])
            position(BOTTOM) move([x, 0])
                cyl(d=MBB_PEG_D, h=MBB_PEG_H, anchor=TOP);
}

// jl_scad drop-in. Origin on the host inside face; board rests on it and its
// pegs seat into holes cut in the host. The holes are counterbored from the
// outside face to take M2 socket-head screws.
module minibb_jl(host_thickness=3) {
    box_preview() minibb();
    box_cut()
        for (x = [-MBB_PEG_X, MBB_PEG_X])
            move([x, 0]) down(host_thickness)
                screw_hole("M2,10",head="socket",counterbore=1.5,anchor=TOP, orient=DOWN);
}

// Standalone test: host plate with the same cutters, ghost board on top.
module minibb_test() {
    $box_show_previews = true;
    host = 3.5;
    diff() {
        cuboid([MBB_W*1.4, MBB_D*1.4, host], anchor=TOP);
        for (x = [-MBB_PEG_X, MBB_PEG_X])
            move([x, 0]) down(host) screw_hole("M2,10",head="socket",counterbore=1.5,anchor=TOP, orient=DOWN);
    }
    %minibb();
}

if (is_undef(_skip_render)) minibb_test();
