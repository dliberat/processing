class Node implements Comparable<Node> {

  // Draw size
  final int RADIUS = 12;

  // Arbitrary name for the node 
  String label;

  // Keys: Other nodes to which this node has an edge
  // Values: Weight of the edge
  HashMap<Node, Float> edges = new HashMap<Node, Float>();
  
  // Used to keep track of which edges have been drawn so that two nodes 
  // that have edges to one another don't draw the same edge multiple times.
  // This will need to be rethought if switching to a directed graph.
  HashMap<Node, Boolean> edgeDrawnFlags = new HashMap<Node, Boolean>();

  // Best weighted distance between the current node and the start node in the search
  float min_weight = Float.POSITIVE_INFINITY;
  
  // Path from the start node to the current node corresponding to 'min_weight'
  ArrayList<Node> path = new ArrayList<Node>();

  // Display colors
  color fillColor = color(255);
  color startSelectedColor = color(150, 150, 255);
  color endSelectedColor = color(150, 255, 150);
  
  // (x,y) location on canvas
  PVector coords;

  public Node(String label, PVector coords) {
    this.label = label;
    this.coords = coords;
  }
  
  @Override
  public String toString() {
    return this.label;
  }
  
  @Override
  public int compareTo(Node other) {
    if (min_weight < other.min_weight) {
      return -1;
    } else if (min_weight == other.min_weight) {
      return 0;
    } else {
      return 1;
    }
  }

  public float dist(Node other) {
    return coords.dist(other.coords);
  }

  public void addEdge(Node other, float weight) {
    if (!edges.containsKey(other)) {
      edges.put(other, weight);
    
      // this makes every edge bidirectional
      if (!other.edges.containsKey(this)) {
        other.edges.put(this, weight);
      }
    }
  }
  
 /**
  * Draws outgoing edges from this node, unless the connected
  * node has draw that edge first.
  * @param overrideA - Specifies a target node which, if an edge is
  * to be drawn to that node, the edge should be drawn using the override color
  * instead of the default colors specified in WEIGHT_PALETTE.
  * @param overrideB - Specifies a second target node which, if an edge is
  * to be drawn to that node, the edge should be drawn using the override color
  * instead of the default colors specified in WEIGHT_PALETTE.
  */
 public void drawEdges(Node overrideA, Node overrideB) {
   for (Node n : edges.keySet()) {
     if (!n.edgeDrawnFlags.containsKey(this)) {
       
       int w;
       if (MAX_WEIGHT - MIN_WEIGHT > 0) {
         w = (int)map(edges.get(n), MIN_WEIGHT, MAX_WEIGHT, 0, WEIGHT_PALETTE.length - 1);
       } else {
         // Necessary in case all weights are set to be equal (MAX_WEIGHT = MIN_WEIGHT)
         w = 0;
       }

       if (n == overrideA || n == overrideB) {
         stroke(0, 200, 0);
       } else {
         stroke(WEIGHT_PALETTE[w]);
       }

       strokeWeight(2);
       line(coords.x, coords.y, n.coords.x, n.coords.y);
       this.edgeDrawnFlags.put(n, true);
     }
   }
 }
  /**
   * Overloaded drawEdges method for scenes that never use color overrides.
   */
  public void drawEdges(){
   this.drawEdges(null, null);
 }

 public void draw() {
   
   stroke(33);
   if (start == this) {
     fill(startSelectedColor);
   } else if (end == this) {
     fill(endSelectedColor);
   } else {
     fill(fillColor);
   }
   ellipse(coords.x, coords.y, RADIUS*2, RADIUS*2);

   fill(33);
   textAlign(CENTER);
   textSize(10);
   text(label, coords.x, coords.y + 3);
 }
}
