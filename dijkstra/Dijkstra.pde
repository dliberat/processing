import java.util.Collections;
import java.util.Map;
import java.util.Iterator;
import java.text.DecimalFormat;

/*  ------------------------------ GRAPH PARAMETERS ------------------------------ */

/* How many nodes to generate */
final int NODE_COUNT = 80;

/*
How far apart to space the nodes. The placement algorithm will make a best
attempt to adhere to this, but will give up trying after MAX_TRY_COUNT attempts.
*/
final int NODE_SPACING = 60;

/* How much time to spend trying to get optimal separation between nodes. */
final int MAX_TRY_COUNT = 40;

/* Minimum and maximum number of edges for each node */
final int MIN_EDGES = 1;
final int MAX_EDGES = 4;

/* Minimum and maximum weight for each edge. */
final int MIN_WEIGHT = 1;
final int MAX_WEIGHT = 5;

/* The entire graph */
ArrayList<Node> G;

/* Start and destination points for the search. */
Node start;
Node end;

/*  ------------------------------ VISUAL PARAMETERS ------------------------------ */

/* Margin between nodes and edge of canvas */
final int MARGIN = 20;

/* Height of status bar along the bottom. */
final int STATUS_BAR_H = 24;

/* Colors for edges. Lower indices represent lower weights. */
final color WEIGHT_PALETTE[] = { #bab3f2, #b0a4d8, #8900AF, #7C0059, #30000C };

/* Scenes shown on the canvas. Each scene allows for different types of interaction. */
final Scene[] scenes = {
  new SetStartNode(),   // User can select starting node 
  new SetEndNode(),     // User can select destination node
  new RunDijkstra(),    // CPU computes shortest distance and displays result
};

/* Keeps track of which scene is currently being displayed. */
int current_scene = 0;

/**
 * Processing setup function
 */
void setup() {
  size(800, 600);

  // create a random graph
  G = generateNodes(NODE_COUNT, MAX_TRY_COUNT);
  linkNodes(G);
}

/**
 * Draw loop.
 */
void draw() {
  scenes[current_scene].draw();
}

/**
 * Event handler
 */
void mouseClicked() {
  scenes[current_scene].handleClick();
}

/**
 * Selects the next scene to display on the canvas.
 */
void next_scene() {
  current_scene++;
  scenes[current_scene].init();
}

/**
 * Generates between MIN_EDGES and MAX_EDGES random edges for a graph.
 * Preference for edge creation is given to nodes that are physically
 * closer together on the canvas (Euclidian distance) in order to
 * produce a nicer visual effect.
 */
public void linkNodes(ArrayList<Node> nodes) {

  // Outer loop. Try to add edges to every single node in nodes.
  for (int outer = 0; outer < nodes.size(); outer++) {

    Node n = nodes.get(outer);
    
    // if this node has already been linked to by other nodes,
    // it may not have any space for additional edges.
    if (n.edges.size() >= MAX_EDGES) {
      continue;
    }
    
    // How many more edges should we tack on to the current node?
    final int real_max = MAX_EDGES - n.edges.size();
    final int edgeCount = (int)random(MIN_EDGES, real_max);

    // Use this array to collect the nearest proximity nodes
    final Node[] nearest = new Node[edgeCount];

    // Use this array to memoize the distances to each node in 'nearest',
    final float[] distances = new float[edgeCount];
    for (int i = 0; i < distances.length; i++) {
      distances[i] = Float.POSITIVE_INFINITY;
    }

    // Look through all the remaining nodes (outer+1). Any nodes that came
    // before the current node have already been assigned edges, so there's no
    // need to add any more to them.
    for (int inner = outer+1; inner < nodes.size(); inner++) {
      Node m = nodes.get(inner);

      // do not add edges to yourself, or to nodes that are maxed out.
      if (n == m || m.edges.size() >= MAX_EDGES) {
        continue;
      }

      final float d = n.dist(m);

      // Check if node m is nearer to the current node n than
      // any of the other nodes in the 'nearest' array. If so, replace it.
      int farthestIndex = 0;
      for (int i = 1; i < nearest.length; i++) {
        if (d < distances[i]) {
          farthestIndex = i;
        }
      }
      if (d < distances[farthestIndex]) {
         nearest[farthestIndex] = m;
         distances[farthestIndex] = d;
       }
      
    }

    // at this point, nearest[] should contain the 'edgeCount' nearest
    // nodes to the current node 'n'.
    for (Node m : nearest) {
      if (m != null) {
        final float edgeWeight = random(MIN_WEIGHT, MAX_WEIGHT+1);
        n.addEdge(m, edgeWeight);
      }
    }
  }
}

/**
 * Randomly generate nodes for a graph.
 * Makes maxTryCount attempts to keep the nodes separated by NODE_SPACING pixels.
 * If that fails, it makes maxTryCount attempts to keep the nodes sparated
 * by half that distance.
 * After that, it gives up and places the next node anywhere at random.
 */
ArrayList<Node> generateNodes(int count, int maxTryCount) {
  
  boolean isSecondAttempt = false;
  
  final ArrayList<Node> nodes = new ArrayList<Node>(count);
  
  for (int i = 0; i < count; i++) {
    int trycount = 0;

    outerLoop: while (true) {
      final PVector coords = new PVector(
                  random(MARGIN, width-MARGIN),
                  random(MARGIN, height-MARGIN-STATUS_BAR_H)
                 );
    
      if (trycount < maxTryCount) {
        for (Node n : nodes) {
          if (coords.dist(n.coords) < NODE_SPACING) {
            trycount++;
            
            if (!isSecondAttempt && trycount >= maxTryCount) {
              trycount = maxTryCount/2;
              isSecondAttempt = true;
            }
            
            continue outerLoop;
          }
        }
      }
      
      nodes.add(new Node("" + i, coords));
      break;
    }
  }
  
  return nodes;
}
