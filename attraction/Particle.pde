class Particle
{
  PVector previous;
  PVector position;
  PVector velocity;
  PVector acceleration;
  Color clr;
  PVector nearestAttractorDistance;
  
  Particle(int x, int y)
  {
    nearestAttractorDistance = new PVector();
    position = new PVector(x, y);
    previous = new PVector(x, y);
    velocity = new PVector(random(-0.5,0.5), random(-0.5, 0.5));
    acceleration = new PVector();
    clr = new Color();
  }

  void update()
  {
    velocity.add(acceleration);
    velocity.limit(Gravity.terminal_vel);
    position.add(velocity);

    // Instantaneous acceleration should not
    // accumulate over frames. Thus we reset it.
    acceleration.mult(0);
  }
  
  void show()
  {
    int rd = (int)map(nearestAttractorDistance.mag(), 0, width * 0.75, 0, 255);
    int grn = (int)map(nearestAttractorDistance.mag(), 0, width * 0.75, 255, 0);
    setColor(rd, grn, 0, 40);
    stroke(clr.r, clr.g, clr.b, clr.a);
    strokeWeight(1);
    line(position.x, position.y, previous.x, previous.y);

    previous.y = position.y;
    previous.x = position.x;
    
    nearestAttractorDistance.mult(0);
  }
  
  void attractedBy(PVector attractor)
  {
    // Vector pointing from the particle's position to the attractor
    PVector force = PVector.sub(attractor, position);

    float distance = force.mag();
    // Remember the distance from the nearest attractor.
    // This vector gets used to give the particle a color
    if (distance > nearestAttractorDistance.mag())
    {
      nearestAttractorDistance = force.copy();
    }

    // If we don't constrain distance, particle behavior gets unpredictable
    // when they are too near an attractor.
    distance = constrain(distance, Gravity.min_distance, Gravity.max_distance);

    float magnitude = Gravity.G / (distance * distance);
    force.setMag(magnitude);
    
    // force is attractive by default, but Gravity can be modified
    // so that the attractors will repel particles if they are too near.
    if (distance <= Gravity.repulsion_distance)
    {
      force.mult(Gravity.repulsion_factor);
    }
    
    acceleration.add(force);
  }
  
  void setColor(int r, int g, int b, int a)
  {
    clr = new Color(r, g, b, a);
  }
}
