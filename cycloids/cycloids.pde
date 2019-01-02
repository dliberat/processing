boolean draw_flg = true;

// switch third arg to false for hypocycloids
Cycloid half = new Cycloid(60, 2, true, true);
Cycloid third = new Cycloid(60, 3, true, true);
Cycloid quarter = new Cycloid(60, 4, true, true);
Cycloid fifth = new Cycloid(60, 5, true, true);

void setup()
{
  size(800, 250);
}

void draw()
{
  background(255);

  // angle of rotation at the current frame
  float angle = frameCount % 360;
  
  translate(110, height/2);
  half.update(angle, draw_flg);
  
  translate(200, 0);
  third.update(angle, draw_flg);
  
  translate(200, 0);
  quarter.update(angle, draw_flg);
  
  translate(180, 0);
  fifth.update(angle, draw_flg);
  
  // stop adding points to the curves
  // once the entire curve is drawn
  // (stops arrays from growing without bound)
  draw_flg = frameCount < 361;
}
