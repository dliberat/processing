class RunDijkstra implements Scene {
  
  ArrayList<Node> completed;
  ArrayList<Node> queue;
  
  Node currentNode;
  Iterator<Map.Entry<Node, Float>> edgeIterator;
  
  public RunDijkstra() {
  }
  
  @Override
  void init() {
    
    frameRate(15);

    queue = (ArrayList)G.clone();
    completed = new ArrayList<Node>(queue.size());

    start.min_weight = 0;
    
    Collections.sort(queue);
  }
  
  @Override
  void draw() {

    background(230);
    
    String txt;
    currentNode = queue.get(0);
    
    // evaluateNextNode sets this back to null each time
    // it finishes checking a node.
    if (edgeIterator == null) {
      edgeIterator = currentNode.edges.entrySet().iterator();
    }
      
    if (currentNode.min_weight != Float.POSITIVE_INFINITY) {

      txt = evaluateNextNode();

    } else {

      txt = "Could not find route.";
      noLoop();

    }
    
    renderGraph();
    renderStatusBar(txt);
  }
  
  private String evaluateNextNode() {
    
    String txt = "Searching for shortest path...";
    
    if (edgeIterator.hasNext()) {
      Map.Entry<Node, Float> e = edgeIterator.next();
      
      Node edge = e.getKey();

      float weight = e.getValue() + currentNode.min_weight;

      if (!completed.contains(edge) && weight < edge.min_weight) {

        edge.min_weight = weight;
        edge.path = (ArrayList)currentNode.path.clone();
        edge.path.add(currentNode);
        
      }

    } else {
      // We've looked at all the nodes connected to 'currentNode'.

      // Check termination condition
      if (currentNode == end) {
        currentNode.path.add(end);
        noLoop();
        txt = this.generateStatusMsg(currentNode.path, currentNode.min_weight);
      }
      
      // Update the priority queue
      completed.add(currentNode);
      queue.remove(0);
      Collections.sort(queue);
      
      // Allow the algorithm to move to the next available
      // node in the priority queue
      edgeIterator = null;

    }
      
     return txt;
  }
  
  private void renderGraph() {
    
    /* Render edges */
    for (Node n : G) {
      
      // If the node that is currently being evaluated
      // has node 'n' in its shortest-distance path to
      // the starting node, override the default edge color
      Node overrideA = null;
      Node overrideB = null;
      
      int indx = currentNode.path.indexOf(n);
      if (indx > 0) {
         overrideA = currentNode.path.get(indx - 1);
      }
      if (indx > -1 && indx < currentNode.path.size() - 1) {
        overrideB = currentNode.path.get(indx + 1);
      }

      n.drawEdges(overrideA, overrideB);
    }

    /* Overlay circles with labels above edges */
    for (Node n : G) {
      n.draw();
    }
  }
  
  private void renderStatusBar(String txt) {
    fill(17, 30, 108);
    rect(0, height-STATUS_BAR_H, width, height);
    textAlign(CENTER);
    fill(255);
    textSize(12);
    text(txt, width/2, height - 10);
  }
  
  /**
   * Generates a string to display in the status bar
   * once the final solution has been found
   */
  private String generateStatusMsg(ArrayList<Node> path, float weight) {

      StringBuilder sb = new StringBuilder("Found shortest weighted path: ");
      
      for (int v = 0; v < path.size(); v++) {
        sb.append(path.get(v).label);
        if (v < path.size() - 1) {
          sb.append(">");
        }
      }
      
      DecimalFormat format = new DecimalFormat("##.0");
      sb.append(" [W=" + format.format(weight) + "]");
      return sb.toString();

  }

  void handleClick() {
    
  }
}
