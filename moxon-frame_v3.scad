// simple moxon antenna frame generator
// based on this idea: https://www.thingiverse.com/thing:2068392

// values come from https://www.antenna2.net/cebik/content/moxon/moxpage.html
// or any other online calculator
// current values (all in mm, btw :) are for 896.5 MHz

// license: CC-BY-NC-SA


A = 123.6;
B = 15.8;
C = 6.4;
D = 23.9;
E = 46.0;

dia = 1.5;					// wire diameter (+ some tolerance for 3D-printing, .1 maybe)

frame         = 7;		  // frame width
thickness     = 3.0;	  // frame thickness
thicknessUp   = 3.0;	  // frame thickness
cover         = 1.5;    // radome thikness
corner_radius = 3;
wire_depth    = dia/3;  // where the wire channel gets placed
wire_depthUp  = -dia/3;	// where the wire channel gets shield placed

handle_length = 60;
coax_diam     = 4;
connector = "screw";			// "sma" (2-hole sma jack), "bnc" (4-hole jack), "screw" or none
screw_dia = 4.4;

freq = "896";				// only used for text generation
tsize = 7;
font = "Core Sans D 55 Bold";

$fn = 255;

// modules

module cable_ties(spacing,extra) {
	translate(v = [-spacing, 0, 0])
		rcube([1.5, 5, thickness+extra], 0.5, true, false);
	translate(v = [spacing, 0, 0])
		rcube([1.5, 5, thickness+extra], 0.5, true, false);
}

module connectors() {
	if (connector=="sma") {
		// holes for SMA jack
		cylinder(h=(dia + thickness), r=4.5/2);
		translate(v = [6, 0, 0])
			cylinder(h=(thickness), r=3/2);
		translate(v = [-6, 0, 0])
			cylinder(h=(thickness), r=3/2);
	}
	else if (connector=="bnc") {
		// holes for BNC jack
		translate(v = [0, 1, 0])   // 2do placement
			cylinder(h=(thickness), r=11/2);
		translate(v = [6, 7, 0])
			cylinder(h=(thickness), r=3/2);
		translate(v = [-6, 7, 0])
			cylinder(h=(thickness), r=3/2);
		translate(v = [6, -5, 0])
			cylinder(h=(thickness), r=3/2);
		translate(v = [-6, -5, 0])
			cylinder(h=(thickness), r=3/2);
	}
	else if (connector=="screw") {
		// just a screw hole
		cylinder(h=(thickness), r=screw_dia/2);
	}
}


// adapted from https://github.com/nophead/NopSCADlib

module rcube(size, r = 0, xy_center = false, z_center = false) {
	linear_extrude(size.z, center = z_center, convexity = 5)
		offset(r) offset(-r) square([size.x, size.y], center = xy_center);
}


// Frame A
difference() {
	union() {
		// outer roundtangle
		rcube([A + frame, E + frame, thickness], 3, true, false);
		// handle
		translate(v = [0, -E/2 - frame - handle_length/2 + 10, 0])
			rcube([21, handle_length + 10, thickness], 6.5, true, false);
	}

	// wire channels
    // left short leg
	translate(v = [-A/2, E/2-corner_radius, thickness-wire_depth])
		rotate([90, 0, 0])  linear_extrude(B - corner_radius) circle(dia/2);
  translate(v = [-A/2, D-E/2 , thickness-wire_depth])
		rotate([90, 0, 0])  linear_extrude(D - corner_radius) circle(dia/2);
   // rigth short leg
  
  translate(v = [A/2, E/2-corner_radius, thickness-wire_depth])
		rotate([90, 0, 0])  linear_extrude(B - corner_radius) circle(dia/2);
  translate(v = [A/2, D-E/2 , thickness-wire_depth])
		rotate([90, 0, 0])  linear_extrude(D - corner_radius) circle(dia/2);
    // long leg
	translate(v = [-A/2 + corner_radius, E/2, thickness-wire_depth])
		rotate([0, 90, 0]) linear_extrude(A - corner_radius*2) circle(dia/2);
	translate(v = [-A/2 + corner_radius, -E/2, thickness-wire_depth])
		rotate([0, 90, 0]) linear_extrude(A - corner_radius*2) circle(dia/2);

	// wire channel rounded corners
	translate(v = [-A/2 + corner_radius, E/2 - corner_radius, thickness-wire_depth])
		rotate([0, 0, 90]) rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
	translate(v = [A/2 - corner_radius, E/2 - corner_radius, thickness-wire_depth])
		rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
	translate(v = [-A/2 + corner_radius, -E/2 + corner_radius, thickness-wire_depth])
		rotate([0, 0, 180]) rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
	translate(v = [A/2 - corner_radius, -E/2 + corner_radius, thickness-wire_depth])
		rotate([0, 0, 270]) rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);

	// left wing cutout
	translate(v = [-((A/2 + frame)/2), 0, 0])
		rcube([(A/2 - frame*2), E - frame, thickness], 2.5, true, false);

	// right wing cutout
	translate(v = [(A/2 + frame)/2, 0, 0])
		rcube([(A/2 - frame*2), E - frame, thickness], 2.5, true, false);

	// big notch
	translate(v = [0, E/2-5, +cover])
		rcube([10, 15, thickness], 3, true, false);

	// smaller notch
	translate(v = [0, E/2-10, +cover])
		rcube([5, 25, thickness], 1.5, true, false);

	// holes for cable ties
	if (E>80) {
		cable_ties(4,0);
		translate(v = [0, -20, 0])
			cable_ties(4,0);
	}
	else if (E>40) {
		translate(v = [0, -7, 0])
			cable_ties(4,0);
	}
	if (handle_length > 30) {
		translate(v = [0, -(E/2) - 15, 0])
			cable_ties(4,0);
	}

	// holes for mounting a connector
	translate(v = [0, -E/2 - frame - handle_length + 15, 0])
		connectors();

	// text
  mirror ([1,0,0])
	translate(v = [0, -(E/2 - 5), - 0.01])
		linear_extrude(0.6)
			text(freq, size=tsize, font=font, halign = "center");
}



// Frame B
difference (){  
  union (){
    translate(v = [0, E+20, 0])
    difference() {
    
      // outer roundtangle
      rcube([A + frame, E + frame, thicknessUp], 3, true, false);
  
      // wire channels
        // left short leg
      translate(v = [-A/2, E/2-corner_radius, thicknessUp-wire_depthUp])
        rotate([90, 0, 0])  linear_extrude(B - corner_radius) circle(dia/2);
      translate(v = [-A/2, D-E/2 , thicknessUp-wire_depthUp])
        rotate([90, 0, 0])  linear_extrude(D - corner_radius) circle(dia/2);
       // rigth short leg
      
      translate(v = [A/2, E/2-corner_radius, thicknessUp-wire_depthUp])
        rotate([90, 0, 0])  linear_extrude(B - corner_radius) circle(dia/2);
      translate(v = [A/2, D-E/2 , thicknessUp-wire_depthUp])
        rotate([90, 0, 0])  linear_extrude(D - corner_radius) circle(dia/2);
        // long leg
      translate(v = [-A/2 + corner_radius, E/2, thicknessUp-wire_depthUp])
        rotate([0, 90, 0]) linear_extrude(A - corner_radius*2) circle(dia/2);
      translate(v = [-A/2 + corner_radius, -E/2, thicknessUp-wire_depthUp])
        rotate([0, 90, 0]) linear_extrude(A - corner_radius*2) circle(dia/2);
      
      // wire channel rounded corners
      translate(v = [-A/2 + corner_radius, E/2 - corner_radius, thicknessUp-wire_depthUp])
        rotate([0, 0, 90]) rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
      translate(v = [A/2 - corner_radius, E/2 - corner_radius, thicknessUp-wire_depthUp])
        rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
      translate(v = [-A/2 + corner_radius, -E/2 + corner_radius, thicknessUp-wire_depthUp])
        rotate([0, 0, 180]) rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
      translate(v = [A/2 - corner_radius, -E/2 + corner_radius, thicknessUp-wire_depthUp])
        rotate([0, 0, 270]) rotate_extrude(angle=90) translate ([corner_radius,0,0]) circle(dia/2);
      
      // left wing cutout
      translate(v = [-((A/2 + frame)/2), 0, 0])
        rcube([(A/2 - frame*2), E - frame, thicknessUp], 2.5, true, false);
      
      // right wing cutout
      translate(v = [(A/2 + frame)/2, 0, 0])
        rcube([(A/2 - frame*2), E - frame, thicknessUp], 2.5, true, false);
      
      // big notch
      translate(v = [0, E/2-5, +cover])
        rcube([10, 15, thicknessUp], 3, true, false);
      
      // smaller notch
      translate(v = [0, E/2-10, +cover])
        rcube([5, 25, thicknessUp], 1.5, true, false);
        
     	// holes for cable ties
      if (E>80) {
        cable_ties(4,0);
        translate(v = [0, -20, 0])
          cable_ties(4,0);
      }
      else if (E>40) {
        translate(v = [0, -7, 0])
          cable_ties(4,0);
      } 
    }

    // coax tube
    difference (){
    translate(v = [0, E/2 - frame/2 +20, 0])
    rotate(a=[-90,0,0])
    cylinder(h = E + frame, r1 = 8, r2 = 0.4, center = false);
    
    translate(v = [0-21/2, E/2 - frame/2+20, 0])
    cube([21,E + frame,21],false);
    }
  }
  
translate(v = [0, E/2 - frame +20, frame/2-thicknessUp-coax_diam/2+wire_depthUp])
//rotate(a=[-84.8,0,0])
rotate(a=[-acos((thicknessUp+coax_diam/2-wire_depthUp)/(E + frame) ),0,0])
 
cylinder(h = E + frame, r1 = coax_diam/2, r2 = coax_diam/5, center = false);
}

translate(v = [A/4, E+20, -thicknessUp])  
cable_ties(4,thicknessUp);