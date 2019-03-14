public class Vector {
  private double[] values;
  
  public Vector(double[] values) {

    // clone
    this.values = new double[values.length];
    for (int i = 0; i < values.length; i++) {
      this.values[i] = values[i];
    } 
  }
  
  public double get(int index) {
    return values[index];
  }
  public void set(int index, double value) {
    values[index] = value;
  }
  public int size() {
    return this.values.length;
  }
  
  public double dot(Vector other) {
    double val = 0.0;
    for (int i = 0; i < this.size(); i++) {
      val += this.get(i) * other.get(i);
    }
    
    return val;
  }
  
  public Vector clone() {
    return new Vector(values);
  }
  
  public void scale(double factor) {
    for (int i = 0; i < values.length; i++) {
      values[i] = values[i] * factor;
    }
  }
  
  public void swap(int a, int b) {
    double tmp = values[a];
    values[a] = values[b];
    values[b] = tmp;
  }
}
