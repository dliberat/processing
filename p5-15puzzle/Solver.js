/* 
@todo
This algo might give more efficient, optimal solutions
https://en.wikipedia.org/wiki/Iterative_deepening_A*

This distance metric might find a solution more quickly
(but would need to be adapted for sizes other than 4x4)
http://www.ic-net.or.jp/home/takaken/nt/slide/solve15.html

*/

/**
 * JavaScript array + sort function = Poor programmer's priority queue
 * @param {Node} x 
 * @param {Node} y 
 */
const qSort = ((x, y) => (x.g + x.h()) - (y.g + y.h()));

class Solver {
  constructor(tiles, sideLength) {
    this.queue = [];
    this.completed = [];

    const clone = tiles.map(x => x.clone());
    const n = new Node(clone, sideLength);
    this.queue.push(n);
  }


  /**
   * A* implementation
   */
  solve() {

    
    while (this.queue.length > 0) {
      
      const n = this.queue.shift();

      // goal condition is at the top of the priority queue.
      // Algorithm terminates here
      if (n.isSolved()) {
        return n;
      }

      const neighbors = n.neighbors()
                        .filter(x => !this.isComplete(x)); // don't backtrack

      
      for (let j = 0; j < neighbors.length; j++) {
        neighbors[j].g++; // Distance metric
        this.enqueueNeighbor(neighbors[j]);
      }

      this.completed.push(n);

      this.queue.sort(qSort);
    }
  }

  enqueueNeighbor(neighbor) {
    let isAlreadyQueued = false;

    for (let j = 0; j < this.queue.length; j++) {
      const node = this.queue[j];

      if (node.equals(neighbor)) {
        // if the current node already exists in the queue,
        // but this way of getting there is faster, then
        // we replace the existing one with this better version.
        // otherwise, we can just throw out the new version since
        // it's not an improvement.
        if (neighbor.g < node.g) {
          this.queue[j] = neighbor;
        }

        isAlreadyQueued = true;
        break;
      }
    }

    if (!isAlreadyQueued) {
      this.queue.push(neighbor);
    }
  }

  /**
   * Tests if a node has already had all its children put into
   * the queue (and therefore does not need to be checked again.)
   * Note that this is different from the isSolved() method 
   * of an individual Node, which instead checks if that Node is
   * a solution to the puzzle.
   * @param {Node} node 
   */
  isComplete(node) {
    for (let n of this.completed) {
      if (n.equals(node)) {
        return true;
      }
    }
    return false;
  }

}