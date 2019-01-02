public class Cycloid
{
  // circle radii
  int bigRad;
  int smallRad;
  int ratio;
  
  // points on the curve traced by the smaller circle
  ArrayList<PVector> curve = new ArrayList<PVector>();
  
  // false = hypocycloid = smaller circle inside bigger one
  boolean is_epicycloid;
  
  // smaller circle direction. 1 = clockwise. -1 = counterclockwise
  int rotation = 1;
  
  public Cycloid(int size, int ratio, boolean is_epi, boolean clockwise)
  {
    bigRad = size;
    smallRad = size/ratio;
    this.ratio = ratio;

    is_epicycloid = is_epi;

    if (!clockwise)
    {
      rotation = -1;
    }
  }
  
  public void update(float angle, boolean drawLine)
  {
    strokeWeight(1);
    big_circle();
    small_circle(angle, drawLine);
    
    stroke(0, 0, 255);
    strokeWeight(2);
    noFill();
    PVector last = curve.get(0);
    for (PVector v : curve)
    {
      line(last.x, last.y, v.x, v.y);
      last = v;
    }
  }

  private void big_circle()
  {
    stroke(0);
    noFill();
    ellipse(0, 0, bigRad*2, bigRad*2);
  }
  
  private void small_circle(float angle, boolean drawLineFlag)
  {
    pushMatrix();
    PVector cp = center_point(angle);
    translate(cp.x, cp.y);
    stroke(0);
    ellipse(0, 0, smallRad * 2, smallRad * 2);
  
    // outer point.
    PVector op = new PVector(0, 0 - smallRad);
    stroke(255, 0, 0);
    fill(255, 0, 0);
    
    // rotation speed
    int rs = is_epicycloid ? ratio + 1 : ratio - 1;
  
    op.rotate(radians(angle * rs * rotation));
    ellipse(op.x, op.y, 2, 2);
    
    stroke(100, 100, 100, 100);
    line(0, 0, op.x, op.y);
    popMatrix();
    
    if (drawLineFlag)
    {
      curve.add(cp.add(op));    
    } 
  }

  private PVector center_point(float angle)
  {
    // center point of the smaller circle
    float yPos = is_epicycloid ? 0 - bigRad - smallRad : smallRad - bigRad;
    PVector p = new PVector(0, yPos);
    p.rotate(radians(angle));
    return p;
  }
}
