include <handyfunctions.scad>

// Lock modelled in Fusion 360 (lock_model): a shell (larger cylinder + fin)
// and a core (smaller cylinder + cam) that turns 45 degrees clockwise.
//
// Local coordinates: lock axis is the X axis, the key face (shell end) is at x=0,
// the lock body extends toward -X, fins point toward -Z.
// "Clockwise" is as seen from the key side, looking into the keyhole.

shell_r = 3;            // shell cylinder radius
shell_len = 12.8;       // shell length
shell_fin_w = 2.7;      // shell fin width
shell_fin_d = 7;        // shell fin depth below the axis
core_r = 2.75;          // core cylinder radius
core_len = 18.6;        // total length (key face to the far end of the core)
cam_w = 1.7;            // cam width
cam_d = 6;              // cam depth below the axis
cam_flat = 2.615;       // flat on the core the cam grows from
cam_near_top = 15.0;    // distance from key face to the cam's sloped face, at the top
cam_near_bottom = 15.85;// ...and at the bottom
wedge_top = 3.115;      // small wedge on the shell end, below the core
wedge_far_top = 14.626;
wedge_far_bottom = 15.35;

// Cam cross-section (XZ plane), extruded to cam width and grown by slop
module cam_prism(slop=0) {
  rx(90) linear_extrude(height=cam_w+2*slop, center=true) offset(delta=slop) polygon([
    [-core_len, -cam_d],
    [-cam_near_bottom, -cam_d],
    [-cam_near_top, -cam_flat],
    [-cam_near_top, 0],
    [-core_len, 0]
  ]);
}

// Cavity for the lock. The lock is inserted from the key side (+X), so the
// profile runs out past the key face by `ext`. At the far end, the cam turns
// into a pocket; once turned, the cam can't be pulled back out.
module fusion_lock_cavity(slop=0, turn=45, clockwise=true, ext=5, step=5) {
  dir = clockwise ? -1 : 1;
  union() {
    // Shell cylinder, plus its run-out to the surface
    dx(-shell_len-slop) ry(90) cylinder(r=shell_r+slop, h=shell_len+slop+ext);
    // Shell fin slot
    translate([-shell_len-slop, -shell_fin_w/2-slop, -shell_fin_d-slop]) cube([shell_len+slop+ext, shell_fin_w+2*slop, shell_fin_d+slop]);
    // Core cylinder beyond the shell
    dx(-core_len-slop) ry(90) cylinder(r=core_r+slop, h=core_len-shell_len+2*slop);
    // Channel the cam and the shell's wedge travel through (unturned position)
    translate([-core_len-slop, -cam_w/2-slop, -cam_d-slop]) cube([core_len-shell_len+2*slop, cam_w+2*slop, cam_d+slop]);
    // Pocket swept by the cam as it turns
    for (a = [0:step:turn-step]) hull() {
      rx(dir*a) cam_prism(slop);
      rx(dir*min(a+step, turn)) cam_prism(slop);
    }
  }
}

// The lock itself, for preview. `turn` is the current core angle.
module fusion_lock_body(turn=0, clockwise=true) {
  dir = clockwise ? -1 : 1;
  // Shell
  difference() {
    union() {
      dx(-shell_len) ry(90) cylinder(r=shell_r, h=shell_len);
      translate([-shell_len, -shell_fin_w/2, -shell_fin_d]) cube([shell_len, shell_fin_w, shell_fin_d]);
      rx(90) linear_extrude(height=cam_w, center=true) polygon([
        [-shell_len, -cam_d], [-wedge_far_bottom, -cam_d], [-wedge_far_top, -wedge_top], [-shell_len, -wedge_top]
      ]);
    }
    dx(-shell_len-1) ry(90) cylinder(r=core_r, h=shell_len+2);
  }
  // Core
  rx(dir*turn) {
    dx(-core_len) ry(90) cylinder(r=core_r, h=core_len);
    cam_prism();
  }
}
