class Node {
  constructor(seq, sideLength) {
    /**
     * State of the board
     * @type {Node[]}
     */
    this.sequence = seq;

    /**
     * Alias for the global PIECE_COUNT.
     * @type {Number}
     */
    this.sideLength = sideLength;

    /**
     * Distance (in board moves) from the starting (shuffled)
     * condition for a puzzle that is to be solved.
     * @type {Number}
     */
    this.g = 0;

    /**
     * Previous board state.
     * @type {Node}
     */
    this.parent = null;

    /**
     * Next board state to move to when solving the puzzle.
     * @type {Node}
     */
    this.child = null;
  }

  /**
   * Generates an array of Nodes representing all the board
   * states that can be reached within 1 move of the current
   * board state.
   */
  neighbors() {
    const neighs = [];
    
    this.sequence
      .map(x => x.canMove(this.sequence))
      .filter(x => x)
      .forEach(mv => 
        neighs.push(this.createNeighorClone(mv.from, mv.to)));

     return neighs;
  }
  
  /**
   * True if this Node represents a board arrangement that is
   * in the correct initial order.
   */
  isSolved() {
    for (let i = 0; i < this.sequence.length; i++) {
      if (this.sequence[i].initpos !== this.sequence[i].currentPos) {
        return false;
      }
    }
    return true;
  }
  
  createNeighorClone(a, b) {
    const c = this.sequence.map(x => x.clone());
    const x = c[a];
    c[a] = c[b];
    c[b] = x;
    c[a].currentPos = a;
    c[b].currentPos = b;
    const n = new Node(c, this.sideLength);
    n.parent = this;
    return n;
  }
  
  /**
   * Checks if this node and another node represent equivalent
   * arrangements of the board tiles.
   * @param {Node} node 
   */
  equals(node) {
    const initpos = x => x.initpos;

    return this.sequence
               .map(initpos)
               .join('') === node.sequence.map(initpos).join('');
  }
  
    
  /**
   * Heuristic function. Calculates the sum of the distances
   * of each tile from its original starting position.
   */
  h() {
    const sl = this.sideLength;
    return this.sequence
               .map(x => x.distanceFromHome(sl))
               .reduce((a, b) => a+b, 0);    
  }
  
  toString() {
    return `Node: ${this.sequence.map(x=>x.initpos).join('')}`
  }
}
