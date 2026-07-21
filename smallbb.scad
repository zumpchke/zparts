include <BOSL2/std.scad>
$fn = 32;
module _smallbb() {
        rotate([90, 0, 0]) {
            import("raw/Mini-Breadboard YELLOW-2.stl");
        }
        children();
}

module smallbb() {
    _smallbb() {
        translate([0, 18.75, 1.5]) cyl(d=2, h=20);
        translate([0, -18.75, 1.5]) cyl(d=2, h=20);
    }
}


smallbb();