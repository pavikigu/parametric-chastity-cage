include <handyfunctions.scad>;

module torus(R, r, phi=360, rounded=false, center=false) {
  offset = center ? -phi/2 : 0;
  if (version_num() > 20151231) {
    rz(offset) union() {
      rotate_extrude(convexity=4, angle=phi) {
        difference() {
          dx(R) circle(r);
          projection() mx() yz();
        }
      }
      if (rounded) {
        dx(R) sphere(r);
        rz(phi) dx(R) sphere(r);
      }
    }
  } else {
    echo("Using a deprecated method for torus(); consider updating to OpenSCAD 2016 or newer");
    if (phi <= 180) {
      rz(offset) difference() {
        rotate_extrude(convexity=4) {
          dx(R) circle(r);
        }
        dy(-R-r) cube([3*R+3*r,2*(R+r),3*r], center=true);
        rz(phi-180) dy(-R-r) cube([3*R+3*r,2*(R+r),3*r], center=true);
      }
    } else if (phi <= 360 ) {
      rotate_extrude(convexity=4) {
        dx(R) circle(r);
      }
    } else if (phi < 360) {
      rz(offset) rz(180)
      difference() {
        torus(R,r,360);// full torus
        torus(R,r,360-phi);//partial torus
      }
    }
  }
}

// Cross-section between a square (roundness=0) and a circle (roundness=1) of the same width 2r
module ring_profile(r, roundness) {
  k = max(min(roundness, 1), 0)*r;
  if (k < 0.01) {
    square(2*r, center=true);
  } else {
    hull() for (x = [-1, 1], y = [-1, 1]) translate([x, y]*(r-k)) circle(k);
  }
}

// Torus with a ring_profile() cross-section
module profile_torus(R, r, roundness=1, phi=360) {
  rotate_extrude(convexity=4, angle=phi) translate([R, 0]) ring_profile(r, roundness);
}
