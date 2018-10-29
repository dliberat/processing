/**
  * Graphic art generated with particles and attractive forces.
  * Inspired by https://www.youtube.com/watch?v=OAcXnzRNiCY
  */

ArrayList<PVector> attractors;
Particle[] particles;

void setup()
{
  size(400, 400);

  attractors = new ArrayList<PVector>();
  attractors.add(new PVector(100, 250));
  attractors.add(new PVector(300, 250));
  attractors.add(new PVector(200, 100));
  
  particles = new Particle[500];
  for (int i = 0; i < particles.length; i++)
  {
    particles[i] = new Particle(200, 200);
  }
  
  background(20);  
}

void draw()
{
  for (Particle particle : particles)
  {
    for (PVector attractor : attractors)
    {
      particle.attractedBy(attractor);
    }
    particle.update();
    particle.show();
  }
}

/**
  * Add attractors to the canvas by clicking.
  */
void mousePressed()
{
  attractors.add(new PVector(mouseX, mouseY));
}
