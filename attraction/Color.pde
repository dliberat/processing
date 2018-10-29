/**
  * A simple Color class so that we can pass colors
  * as arguments to functions. Processing probably
  * has something like this available natively,
  * but this will do for our purposes here.
  */
class Color
{
  int r;
  int g;
  int b;
  int a;
  
  Color(int r, int g, int b, int a)
  {
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
  }
 
 Color()
 {
   r = 255;
   g = 255;
   b = 255;
   a = 255;
 } 
}
