////////////////////////////////////
//
// Parametric chastity cage, modified from this one: https://www.thingiverse.com/thing:2764421/
// Version 3, published August 2018

// V4 update: February 2019
//    - Added option to bend the base ring, for comfort
//    - Updated variables for Thingiverse Customizer

// V5 update: June 2019
//    - Rewrote as many functions as possible

// V6 update: January 2021
//    - Another major overhaul

//////////////////////////////////////

// Use abbreviations for translate() and rotate() operations
use <handyfunctions.scad>

// Use separate module for the lock shape (modelled in Fusion 360)
use <fusion_lock.scad>

// Use separate module for torus functions
use <torus.scad>

// Use separate module for computing points along the cage path
use <vec3math.scad>

/* [General] */

// Render cage and ring separately
separate_parts = 0; // [0: Together, 1: Separate]

// Cage shape: a full cage with bars, or a flat cap (a wall ring with a flat top plate)
flat_top = 0; // [0: Cage, 1: Flat]

// Cage diameter
cage_diameter=35; // [30:40]

// Tilt angle of the cage at the base ring
tilt=15; // [0:30]

// Gap between the bottom of the cage and the base ring
gap=10; // [10:20]

/* [Cage] */

// Length of cage from base ring to cage tip
penis_length=90; // [30:200]

// Thickness of the rings of the cage
cage_bar_thickness=4; // [4:8]

// Number of vertical bars on the cage
cage_bar_count=8;

// Replace the bars with a solid wall along the same shape
solid_wall = 0; // [0: Bars, 1: Solid wall]

// Thickness of the solid wall, measured outward from the cage diameter
solid_wall_thickness = 2; // [1.2:0.1:8]

// Width of the slit at the front opening
slit_width=12; // [0:40]

// Solid wall: where the slit starts, in degrees over the dome from its base on the lock side (90 = the tip)
slit_start = 0; // [0:1:180]

// Solid wall: where the slit ends, in degrees over the dome from its base on the lock side (180 = base on the far side)
slit_end = 180; // [0:1:180]

// X-axis coordinate of the bend point (the center of the arc the cage bends around)
bend_point_x=50; // [0:0.1:200]

// Z-axis coordinate of the bend point (the center of the arc the cage bends around)
bend_point_z=15; // [0:0.1:200]

/* [Flat top] */

// Height of the wall of the flat cap, from the bottom of the cage ring to the top of the plate
flat_wall_height = 9.4; // [4.8:0.1:40]

// Thickness of the top plate
flat_plate_thickness = 1; // [0.6:0.1:4]

// Diameter of the center hole in the top plate
flat_center_hole = 6; // [0:0.5:15]

// Number of holes around the center hole
flat_hole_count = 6; // [0:12]

// Diameter of the holes around the center hole
flat_hole_diameter = 3; // [1:0.5:8]

// Radius of the circle the holes around the center sit on
flat_hole_radius = 12; // [3:0.5:16]

// Close the holes with a thin layer on the underside of the plate, so the slicer bridges the plate in one piece; poke it through after printing
flat_bridge_layer = 1; // [0: No, 1: Yes]

// Thickness of that layer (one or two print layers)
flat_bridge_layer_thickness = 0.2; // [0.1:0.05:0.6]

/* [Base ring] */

// Base ring diameter
base_ring_diameter=45; // [30:55]

// Thickness of base ring 
base_ring_thickness=6; // [6:10]

// Cross-section of the base ring and the cage ring: 0 = square (easier to print), 1 = round. Edge radius = value * base ring thickness/2; 0.33 matches the lock block at thickness 6. The wavy base ring is always round
base_ring_roundness = 0.33; // [0:0.01:1]

// Add a "wave" to the base ring (contours to the body a little better)
wavy_base = 0; // [0: Flat, 1: Wavy]

// If the base ring has a wave, set the angle of the wave
wave_angle = 12; // [0:45]

/* [Lock] */

// How deep the key face of the lock sits below the surface of the case
lock_key_depth = 1.5; // [0:0.1:4]

// Direction the lock core turns, seen from the key side
lock_clockwise = 1; // [1: Clockwise, 0: Counterclockwise]

// Show the lock in place (preview only)
show_lock = 0; // [0: No, 1: Unlocked, 2: Locked]

/* [Clearances] */

// If your lock fits too tightly in the casing, add some space around it here
lock_margin = 0.1; // [0:0.01:1]

// If the two parts slide too stiffly, add some space here
part_margin = 0.2; // [0:0.01:1]

/* [Hidden] */

// Glans cage height (minimum is cage radius)
glans_cage_height=cage_diameter/2; // [15:50]

// Variables affecting the lock case
lock_case_upper_radius = 9;
lock_case_lower_radius = 4;
base_lock_bridge_width = 11;
mount_width=5;
mount_height=18;
mount_length=24;

// Radius of rounded edges
rounding=.99;

// Square function for math
function sq(x) = pow(x, 2);


////////////////////////////////////
//
// Useful values calculated from parameters above
//

// Thickness of base ring of cage
cage_ring_thickness = 1.2*cage_bar_thickness;

// step: angle between cage bars
step = 360/cage_bar_count;

// R1: Inner radius of shaft of cage
// R2: Inner radius of base ring
R1 = cage_diameter/2;
R2 = base_ring_diameter/2;

// r1: cage bar radius
// r2: base ring radius
// r3: cage ring radius
r1 = cage_bar_thickness/2;
r2 = base_ring_thickness/2;
r3 = cage_ring_thickness/2;

// Length of cage
cage_length = max(penis_length-gap, glans_cage_height+(R1+r1)*sin(tilt));

// Vertical placement of lock hole
lock_vertical = mount_height/2+1.5;
// Horizontal placement of lock hole
lock_lateral = 5.6;
// Angle the lock core turns
lock_turn = 45;

// P: bend point (assumed to be on the XZ plane)
// dP: distance from origin to bend point
P = [bend_point_x, 0, bend_point_z];
dP = norm(P);

// psi: angle from origin to bend point (in degrees)
psi = atan(P.z/P.x);

// dQ: length of straight cage segment
dQ = min(dP*cos(90-tilt-psi), cage_length-glans_cage_height);

// Q: upper endpoint of straight segment of cage
Q = [dQ*sin(tilt), 0, dQ*cos(tilt)];

// Phi: arc length of curved segment of cage (in degrees)
curve_radius = norm(P-Q);
Phi = (cage_length - dQ - glans_cage_height)/curve_radius * 180/PI;

// R: endpoint of curved segment of cage
R = ry(Q-P, Phi) + P;

//slit_width = (R1+r1)*cos(step);

////////////////////////////////////
//
// Finally, here's where the modules begin
//
// Facet resolution: max angle and max length of a facet (coarser in preview for speed)
$fa = $preview ? 6 : 2;
$fs = $preview ? 1 : 0.4;
make();

module make() {
  cage();
  make_base();
  if (show_lock) %lock_position() fusion_lock_body(show_lock == 2 ? lock_turn : 0, lock_clockwise);
}

module make_base() {
  baseOrigin = separate_parts ? [-base_ring_diameter-cage_diameter, 0, gap] : [0, 0, 0];
  translate(baseOrigin) {
    base_ring();
    lock_dovetail_outer();
  }
}

// Generate a cylinder with rounded edges
module rounded_cylinder(r,h,n, center=false) {
  zshift = center ? -h/2 : 0;
  dz(zshift) rotate_extrude(convexity=1) {
    offset(r=n) offset(delta=-n) square([r,h]);
    square([n,h]);
  }
}

// Generate a cube with rounded edges
module rounded_cube(size, radius, center=false) {
  offset = center ? [0, 0, 0] : [radius, radius, radius];
	translate(offset) minkowski() {
		cube(size = [
			size[0] - (radius * 2),
			size[1] - (radius * 2),
			size[2] - (radius * 2)
		], center=center);
		sphere(r = radius);
	}
}

module cage() {
  if (flat_top || solid_wall) {
    // Closed shapes: keep the lock block and the ring out of the cavity, flush with the inner surface
    difference() {
      union() {
        if (flat_top) {
          // The flat cap's wall is upright but the lock pieces slide along a tilted plane:
          // trim the wall back to that plane so the base part's lock pieces clear it
          difference() {
            flat_cap();
            lock_slide_clearance();
          }
        } else {
          cage_solid_wall();
          // Cage ring, sheared with the tilt like the wall: inner surface flush with the wall,
          // outer edge where the barred cage's ring has it. At a steep tilt it would reach past
          // the plane the lock pieces slide on, so it is trimmed there too
          difference() {
            skewxz(tan(tilt)) profile_torus(R1+(r1+r3)/2, r1+r3, 2*r3, base_ring_roundness*r2/(r1+r3)*2);
            lock_slide_clearance();
          }
        }
        cage_lock();
      }
      cage_cavity();
    }
  } else {
    cage_bar_segments(); // The bars
    glans_cap(); // The cap
    profile_torus(R1+r1, 2*r3, 2*r3, base_ring_roundness*r2/r3);  // Cage base ring, same edge radius as the base ring
    cage_lock(); // The part where the lock goes
  }
}

// Everything past the plane the base part's lock pieces slide on (the outer face of the slab)
module lock_slide_clearance() {
  dz(-r3) skewxz(tan(tilt)) translate([-100, -mount_length/2-1, -50]) cube([100-(R1+r3+mount_width/2), mount_length+2, 150]);
}

// Inside of the flat cap / solid wall, extended below the base so nothing is left hanging into it
module cage_cavity() {
  if (flat_top) {
    wall_h = max(flat_wall_height, 2*r3);
    dz(-r3-1) cylinder(r=R1+r1-r3, h=wall_h-flat_plate_thickness+1);
  } else {
    cage_volume(R1, open_bottom=true);
  }
}

// Solid wall along the path of the bars: straight segment, bend around P, and a domed cap with the slit.
// The inner surface is at the cage diameter, the wall grows outward
module cage_solid_wall() {
  t = solid_wall_thickness;
  difference() {
    cage_volume(R1+t);
    cage_volume(R1, open_bottom=true);
    if (slit_width > 0) translate(R) ry(Phi+tilt) slit_cutter(R1+t/2, slit_width/2+t/2, t, slit_start, slit_end);
  }
  // Rounded lip along the slit edge; the clear opening is slit_width
  if (slit_width > 0) translate(R) ry(Phi+tilt) slit_lip(R1+t/2, slit_width/2+t/2, t, slit_start, slit_end);
}

// Slit geometry on the dome (cap frame: dome toward +Z, slit running along X, the lock side toward -X).
// Positions along the slit are angles phi in the XZ plane from +X: the dome's base on the lock side
// is phi=180, the tip is phi=90, the base on the far side is phi=0.
// The lip's center line lies on the wall's mid-sphere (radius Rm):
//  - each side is the circle where the plane y=+-c cuts the sphere (radius rho around the Y axis);
//  - each end is a half circle of radius c around rho*[cos(phi), 0, sin(phi)], tangent to both sides.
// The ends stop t/2 above the dome's base, so the lip stays on the dome.
function slit_c(Rm, c, t) = min(c, Rm*sin(80 - asin(t/2/Rm)));
function slit_th(Rm, c, t) = asin(slit_c(Rm, c, t)/Rm) + asin(t/2/Rm);
// [phi at the far-side end, phi at the lock-side end] for slit_start/slit_end (degrees from the lock-side base)
function slit_span(Rm, c, t, start, end) = let(
  th = slit_th(Rm, c, t),
  lo = min(max(180 - max(start, end), th), 180 - th),
  hi = min(max(180 - min(start, end), th), 180 - th)
) [lo, hi];

// Cone from the dome center over the slit outline, so the cut faces are normal to the wall
module slit_cutter(Rm, c0, t, start, end) {
  c = slit_c(Rm, c0, t);
  rho = sqrt(Rm*Rm - c*c);
  span = slit_span(Rm, c0, t, start, end);
  L = 2*(Rm + t);
  // Sides: |y| < c/rho * (distance from the Y axis), between the ends
  if (span[1] - span[0] > 0.01)
    rx(90) rz(span[0]) rotate_extrude(angle=span[1]-span[0]) polygon([[0, 0], [L, c/rho*L], [L, -c/rho*L]]);
  // Ends: cones around the end centers
  for (phi = span) ry(90-phi) cylinder(r1=0, r2=L*c/rho, h=L);
}

module slit_lip(Rm, c0, t, start, end) {
  c = slit_c(Rm, c0, t);
  rho = sqrt(Rm*Rm - c*c);
  span = slit_span(Rm, c0, t, start, end);
  tube_fn = 48; // multiple of 4, so the side and end tubes meet vertex to vertex
  // Sides
  if (span[1] - span[0] > 0.01)
    for (y = [-c, c]) dy(y) rx(90) rz(span[0]) rotate_extrude(angle=span[1]-span[0]) dx(rho) circle(t/2, $fn=tube_fn);
  // Ends: half rings from +Y around the outside of the slit to -Y (sgn=-1 at the far-side end, +1 at the lock side)
  for (k = [0, 1]) let(
    phi = span[k],
    sgn = k == 0 ? -1 : 1,
    n = [cos(phi), 0, sin(phi)],
    d = sgn*[-sin(phi), 0, cos(phi)],
    e = sgn*n
  ) multmatrix([[0, d.x, e.x, rho*n.x], [1, d.y, e.y, 0], [0, d.z, e.z, rho*n.z], [0, 0, 0, 1]])
      rotate_extrude(angle=180) dx(c) circle(t/2, $fn=tube_fn);
}

// Solid volume of the cage with cross-section radius r: the straight segment, the bend and a hemisphere on top
module cage_volume(r, open_bottom=false) {
  bend_steps = max(1, ceil(Phi/2));
  // Straight segment, from the base ring to Q
  hull() {
    cage_section(r);
    translate(Q) ry(tilt) cage_section(r);
  }
  // Below the base, continue along the tilt (same shear as the ring), deep enough to clear the ring
  if (open_bottom) hull() {
    cage_section(r);
    translate([-(r3+1)*tan(tilt), 0, -(r3+1)]) cage_section(r);
  }
  // Bend around P, from Q to R
  if (Phi > 0) for (i = [0:bend_steps-1]) hull() {
    translate(P) ry(i*Phi/bend_steps) translate(Q-P) ry(tilt) cage_section(r);
    translate(P) ry((i+1)*Phi/bend_steps) translate(Q-P) ry(tilt) cage_section(r);
  }
  // Dome
  translate(R) ry(Phi+tilt) intersection() {
    sphere(r);
    translate([-r, -r, 0]) cube([2*r, 2*r, r]);
  }
}

// A thin disc of the cage cross-section, in the XY plane
module cage_section(r) {
  cylinder(r=r, h=0.01, center=true);
}

// Flat cap: the cage ring grown upward into a wall, closed by a plate with holes
module flat_cap() {
  wall_h = max(flat_wall_height, 2*r3);
  // Wall: the cage ring with a rectangular section, same edge radius as the base ring
  dz(-r3+wall_h/2) profile_torus(R1+r1, 2*r3, wall_h, base_ring_roundness*r2/r3);
  // Top plate, flush with the top of the wall
  dz(-r3+wall_h-flat_plate_thickness) difference() {
    cylinder(r=R1+r1, h=flat_plate_thickness);
    // Holes start above the bridge layer when it is on, otherwise they go right through
    hole_start = flat_bridge_layer ? flat_bridge_layer_thickness : -1;
    dz(hole_start) {
      if (flat_center_hole > 0) cylinder(d=flat_center_hole, h=flat_plate_thickness-hole_start+1);
      if (flat_hole_count > 0) for (i = [0:flat_hole_count-1]) rz(i*360/flat_hole_count) dx(flat_hole_radius) cylinder(d=flat_hole_diameter, h=flat_plate_thickness-hole_start+1);
    }
  }
}

module cage_bar_segments() {
  for (theta = [step/2:step:360-step/2]) {
    // Straight segment begins at a point along the base ring, and ends at a point a distance R1 from point Q
    straightSegStart = rz([R1+r1, 0, 0], theta);
    straightSegEnd = Q + ry(straightSegStart, tilt);
    curveSegEnd = ry(straightSegEnd-P, Phi)+P;
    
    // make a cylinder between straightSegStart and straightSegEnd
    segAngle = 90-atan2(straightSegEnd.z - straightSegStart.z, straightSegEnd.x - straightSegStart.x);
    segLength = norm(straightSegEnd - straightSegStart);
    translate(straightSegStart) ry(segAngle) cylinder(r=r1, h=segLength);
    
    // Make a torus between straightSegEnd and curveSegEnd, if necessary
    if (Phi>0) {
      // First, find the angle between the ends of the curve
      vec1 = [straightSegEnd.x, 0, straightSegEnd.z]-P;
      vec2 = [curveSegEnd.x, 0, curveSegEnd.z]-P;
      curveAngle = acos(dot(vec1, vec2)/(norm(vec1)*norm(vec2)));
      curveRad = norm(vec1);
      translate(straightSegEnd) ry(-180+tilt) dx(-curveRad) rx(90) torus(curveRad, r1, -curveAngle, rounded=true);
    }
  }
}

module glans_cap() {
  // First, ensure the slit width is within the bounds of the cage geometry
  real_slit_width = max(min(slit_width, cage_diameter), 0.1);
  translate(R) ry(Phi+tilt) {
    // Ring around base of glans cap
    torus(R1+r1, r1);
    // Calculate the start and end points of the bars that create the front slit
    slitRadius = (R1+r1)*cos(asin(real_slit_width/2/(R1+r1)));
    slitStart = [slitRadius, -real_slit_width/2, 0];
    slitEnd = mx(slitStart);
    
    // Draw slit bars
    dy(-real_slit_width/2) rx(90) torus(slitRadius, r1, 180);
    dy(real_slit_width/2) rx(90) torus(slitRadius, r1, 180);
    
    // Draw each cage bar (minus the part that would enter the slit area)
    for (theta = [step/2:step:180-step/2]) {
      // Do not calculate/draw the bar if the bar begins within the slit area
      if ((R1+r1)*sin(theta) > real_slit_width/2) {
        // Compute arc length of this side bar
        distanceInSlit = (real_slit_width/2)/sin(theta);
        arcLength = acos(distanceInSlit/(R1+r1));
        rz(theta) rx(90) torus(R1+r1, r1, arcLength);
        rz(180+theta) rx(90) torus(R1+r1, r1, arcLength);
      }
    }
  }
}

module cage_lock() {
  // Create the solid arc that interfaces with the mating parts (a flat cap or a solid wall does this job itself)
  if (!flat_top && !solid_wall) mount_arc();
  // Create the flat plane on which the mating parts slide
  mount_flat();
  // Create the cage's piece of the lock
  lock_dovetail_inner();
}

module lock_dovetail_inner() {
  inner_dovetail_length = mount_length/3 - part_margin;
  difference() {
    lock_case_shape(inner_dovetail_length);
    // Ensure the lock body does not enter the cage itself
    dz(-r3) skewxz(tan(tilt)) cylinder(r=R1+r3, h=100, center=true);
    // Cut a cavity for the lock module
    lock_cavity();
  }
}

module lock_dovetail_outer() {
  intersection () {
    difference() {
      union() {
        dy(mount_length/3) lock_case_shape(mount_length/3, outer=true);
        my() dy(mount_length/3) lock_case_shape(mount_length/3, outer=true);
      }
      // Cut a cavity for the lock module
      lock_cavity();
    }
    union() {
       dz(-r3) skewxz(tan(tilt)) dz(-r3) mx() dx(R1+r3+mount_width/2 + part_margin) dy(-mount_length/2) rounded_cube([50, mount_length/3, mount_height*cos(tilt)+2*r3], rounding);
      my() dz(-r3) skewxz(tan(tilt)) dz(-r3) mx() dx(R1+r3+mount_width/2 + part_margin) dy(-mount_length/2) rounded_cube([50, mount_length/3, mount_height*cos(tilt)+2*r3], rounding);
    }
  }
  // Add a connecting block between the lock part and the base ring:
  hull() {
    dz(-2*r3) dy(-mount_length/2) mx() dx(R1+2*r3*sin(tilt)+part_margin) rounded_cube([base_lock_bridge_width, mount_length, r3-part_margin], (r3-part_margin)/2.01);
    dz(-gap) dx(-R1-r3-gap*sin(tilt)) rx(90) cylinder(r=r3/2, h=mount_length, center=true);
    dx(R2+2*r2-R1-r3-r2-gap*sin(tilt)) dz(-gap) rz(165) torus(R2+2*r2, r3/2, 30);
  }
}

// Place the lock: axis along Y, key face toward +Y, recessed lock_key_depth below the case surface
module lock_position() {
  dx(-R1-r3-mount_width/2-lock_lateral) ry(tilt) dz(lock_vertical) dy(mount_length/2-lock_key_depth) rz(90) children();
}

module lock_cavity() {
  lock_position() fusion_lock_cavity(lock_margin, lock_turn, lock_clockwise, ext=lock_key_depth+5);
}

// A hull of four rounded cylinders to create the main lock body. It extends down a bit more for the outer lock piece
module lock_case_shape(length, outer=false) {
  extra = outer ? r3 : 0;
  
  hull() {
    dx(-R1-r3-mount_width/2-lock_case_upper_radius+lock_case_lower_radius) dz(lock_case_lower_radius-r3-extra) rx(90) rounded_cylinder(lock_case_lower_radius, length, rounding, center=true);
    dx(-R1-r3-mount_width/2) dz(mount_height*cos(tilt) - lock_case_upper_radius) rx(90) rounded_cylinder(lock_case_upper_radius, length, rounding, center=true);
    dz(lock_case_lower_radius-r3-extra) rx(90) rounded_cylinder(lock_case_lower_radius, length, rounding, center=true);
    dz(mount_height*cos(tilt)-lock_case_lower_radius) rx(90) rounded_cylinder(lock_case_lower_radius, length, rounding, center=true);
  }
}

module mount_arc(arcLength=60) {
  skewxz(tan(tilt)) {
    rz(180-arcLength/2) {
      rotate_extrude(angle=arcLength) {
        dx(R1) offset(r=rounding) offset(delta=-rounding) square([cage_bar_thickness, mount_height*cos(tilt)]);
      }
      // Put smooth caps on the sides of the mount arc
      dx(R1+r1) rounded_cylinder(r1, mount_height*cos(tilt), rounding);
      rz(arcLength) dx(R1+r1) rounded_cylinder(r1, mount_height*cos(tilt), rounding);
    }
  }
}

module mount_flat() {
  closed = flat_top || solid_wall;
  // On a closed shape the slab reaches in past the wall at its ends, so its sides run straight into the wall;
  // cage() then trims it flush with the inner surface
  inner = closed ? sqrt(max(sq(R1) - sq(mount_length/2), 0)) : R1+r3-mount_width/2;
  dz(-r3) skewxz(tan(tilt)) difference() {
    translate([-R1-r3-mount_width/2, -mount_length/2, 0]) rounded_cube([R1+r3+mount_width/2-inner, mount_length, mount_height*cos(tilt)+r3], rounding);
    // For the barred cage, keep the block outside the cage ring
    if (!closed) cylinder(r=R1+r3, h=100);
  }
}

module base_ring() {
  if (wavy_base) {
    dz(-gap) dx(R2+r2-R1-r1-gap*tan(tilt)) wavy_torus(R2+r2, r2, wave_angle);
  } else {
    dz(-gap) dx(R2+r2-R1-r1-gap*tan(tilt)) profile_torus(R2+r2, 2*r2, 2*r2, base_ring_roundness);
  }
}

module wavy_torus(R, r, pitch) {
  union() {
    translate([-sin(-45)*R*(1-cos(pitch)), 0, -R*sin(-45)*sin(pitch)]) ry(pitch) rz(-45) {
      torus(R, r, 90);
      dx(R) sphere(r);
    }
    translate([0, sin(45)*R*(1-cos(pitch)), -R*sin(45)*sin(pitch)]) rx(pitch) rz(45) {
      torus(R, r, 90);
      dx(R) sphere(r);
    }
    translate([-sin(135)*R*(1-cos(pitch)), 0, -R*sin(135)*sin(-pitch)]) ry(-pitch) rz(135) {
      torus(R, r, 90);
      dx(R) sphere(r);
    }
    translate([0, sin(-135)*R*(1-cos(pitch)), -R*sin(-135)*sin(-pitch)]) rx(-pitch) rz(-135) {
      torus(R, r, 90);
      dx(R) sphere(r);
    }
  }
}
