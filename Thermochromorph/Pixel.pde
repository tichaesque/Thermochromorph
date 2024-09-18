class Pixel {
  // position
  float x;
  float y; 
  float size; 
  
  public Pixel(float x_, float y_, float size_) {
    x = x_; 
    y = y_; 
    size = size_; 
  }
  
  public void display() {
    noStroke(); 
    ellipse(x, y, size, size);
  }
}
