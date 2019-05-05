class SetStartNode implements Scene {
  
  @Override
  void init() {
  }
  
  @Override
  void draw() {
    background(230);
  
  fill(17, 30, 108);
    rect(0, height-STATUS_BAR_H, width, height);
    textAlign(CENTER);
    fill(255);
    textSize(14);
    text("Select a source node.", width/2, height - 10);
  
    for (Node n : G) {
      n.drawEdges();
    }
    for (Node n : G) {
      n.draw();
    }
  }
  
  void handleClick() {
    PVector pos = new PVector(mouseX, mouseY);
    for (Node n : G) {
      if (pos.dist(n.coords) <= n.RADIUS) {
        start = n;
        next_scene();
        break;
      }
    }
  }
}
