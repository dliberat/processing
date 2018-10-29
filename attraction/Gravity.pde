class Gravity
{
  static final float G = 30;
  static final float terminal_vel = 6.0;
  
  /* Max and min distances (in pixels) to be
  used when calculating forces. This means that
  for particles that are moving away from an
  attractor, the force that acts on the particle
  will not continually diminish as it gets further
  and further away, but rather stay constant.
  
  Similarly, particles that get too close to their
  attractors will not get an exponentially increased
  jolt of acceleration.
  */
  static final float max_distance = 100.0;
  static final float min_distance = 20.0;
  
  /* Parameters used to control the force with
  which attractors repel any particles that
  get too close. With the repulsion factor
  set to 1, no repulsion takes place.
  
  Negative factors will cause repulsion.
  Positive factors will cause increased attraction.
  */
  static final int repulsion_distance = 20;
  static final float repulsion_factor = 1;
}
