/**
 * A far-from-optimal puzzle sketch.
 * 
 * Press the buttons to shuffle or solve the puzzle.
 * The solving algorithm is A*, with Manhattan Distance
 * as the heuristic. It works:
 * - OK in most situations with a 3x3 puzzle
 * - Slowly if the blank piece is on the top left position
 *   of a 3x3 puzzle
 * - Acceptably in most situations with a 4x4 puzzle
 * - Awful in about 10% of situations with a 4x4 puzzle
 * - Almost not at all with a 5x5 puzzle.
 */

/**
 * This defines the canvas size. All puzzles are square.
 * This parameter should be divided evenly by PIECE_COUNT.
 * @type {Number}
 */
const PUZZLE_HEIGHT = 390;


/**
 * The number of pieces vertically or horizontally along
 * an edge of the puzzle. The actual number of pieces on the
 * playing board will be the square of this number - 1.
 * This number should divide PUZZLE_HEIGHT evenly.
 * @type {Number}
 */
const PIECE_COUNT = 3;

/**
 * Height of the buttons along the bottom of the canvas.
 * @type {Number}
 */
const BTN_HEIGHT = 40;

/**
 * Height of an individual puzzle piece in pixels.
 * @type {Number}
 */
const tileHeight = PUZZLE_HEIGHT / PIECE_COUNT;

/**
 * Reference to the puzzle image.
 * @type {p5.Image}
 */
let img;

/**
 * Number of shuffling moves to be made.
 * When this parameter is > 0, the board will try to move
 * one piece of the puzzle at random, then decrease this value by 1.
 * @type {Number}
 */
let shuffling = 0;


/**
 * Node to display on the board.
 * When this value is not null, this node will be displayed on the board
 * for a few frames. Once the frameDelay is up, this Node's child will
 * be displayed, and the children will be traversed all the way until
 * a leaf.
 * @type {Node}
 */
let solveSequence = null;
let frameDelay = 0;

/**
 * Container for the puzzle pieces.
 * @type {Tile[]}
 */
let tiles = [];


function preload() {
  img = loadImage('rainbow_heart.png');
}


function setup() {
  createCanvas(PUZZLE_HEIGHT, PUZZLE_HEIGHT + BTN_HEIGHT);  
  
  /* chop up the image into puzzle pieces */
  img.resize(PUZZLE_HEIGHT, PUZZLE_HEIGHT);
  
  let edgeCount = 0;
  let sx = 0;
  let sy = 0;
  const w = tileHeight;
  
  let i = 0;
  for (i = 0; i < (PIECE_COUNT ** 2) - 1; i++) {

    const segment = createImage(tileHeight, tileHeight);
    segment.copy(img, sx, sy, w, w, 0, 0, w, w);
    tiles.push(new Tile(tileHeight, segment, i));

    edgeCount++;

    if (edgeCount < PIECE_COUNT) {
      // move rightward along the same row
      sx += tileHeight;
    } else {
      // move to the next row (like a carriage return)
      edgeCount = 0;
      sx = 0;
      sy += tileHeight;
    }
  }

  // bottom right tile
  tiles.push(new EmptyTile(tileHeight, null, i));
}

function draw() {
  background(220);

  /* ----------- Draw the current state of the board ----------- */
  let edgeCount = 0;
  let x = 0;
  let y = 0;

  tiles.forEach((tile, i) => {
    push();
    {
      translate(x, y);
      tile.draw();
      edgeCount++;


      if (edgeCount < PIECE_COUNT) {
        // move rightward along the same row
        x += tileHeight;
      } else {
        // move to the next row (like a carriage return)
        edgeCount = 0;
        x = 0;
        y += tileHeight;
      }
    }
    pop();
  });

  /* ---------- Calculate the next state of the board ---------- */
  
  if (shuffling > 0) {
    const mvs = tiles.map(x => x.canMove(tiles)).filter(x => x);
    const index = floor(random(0, mvs.length));
    const mv = mvs[index];
    swap(tiles, mv.from, mv.to);
    shuffling --;

  } else if (solveSequence && frameDelay === 0) {
    tiles = solveSequence.sequence.map(x => x.clone());
    solveSequence = solveSequence.child;
    frameDelay = 20;
  } else if (solveSequence && frameDelay > 0) {
    frameDelay --;
  }

  /* ------------------------- Buttons ------------------------- */

  push();
    translate(0, height- BTN_HEIGHT);
    fill(0,0,255,100);
    rect(0, 0, width/2, BTN_HEIGHT)
    stroke(0);
    textAlign(CENTER);
    text("SOLVE", width/4, BTN_HEIGHT * 3/5);
  pop();
  push();
    translate(width/2, height- BTN_HEIGHT);
    fill(255,0,0,100);
    rect(0, 0, width/2, BTN_HEIGHT)
    stroke(0);
    textAlign(CENTER);
    text("SHUFFLE", width/4, BTN_HEIGHT * 3/5);
  pop();


}

/**
 * Returns the index of the tile that was clicked on
 * so that it can be found inside the tiles array
 */
function findTile(x, y) {
  const col = floor(x / tileHeight);
  const row = floor(y / tileHeight);
  return (PIECE_COUNT * row) + col;
}

function mousePressed() {
  if (shuffling > 0 || solveSequence) {
    return;
  }

  if (mouseX < width && mouseX > 0 && mouseY > 0 && mouseY < height - BTN_HEIGHT) {
    const index = findTile(mouseX, mouseY);
    const tile = tiles[index];
    const canmove = tile.canMove(tiles);
    if (canmove) {
      swap(tiles, canmove.from, canmove.to);
    }
  }

  if (mouseX > 0 && 
      mouseX < width/2 &&
      mouseY > height - BTN_HEIGHT && 
      mouseY < height) {

        solve();
    }

  if (mouseX > width/2 && 
      mouseX < width &&
      mouseY > height - BTN_HEIGHT && 
      mouseY < height) {
     
        shuffling = 50;
    }
}

function solve() {
  const solver = new Solver(tiles, PIECE_COUNT);
  let node = solver.solve();
  while (node.parent) {
    node.parent.child = node;
    node = node.parent;
  }
  solveSequence = node;

}

function swap(arr, a, b) {
  const x = arr[a];
  arr[a] = arr[b];
  arr[b] = x;
  
  arr[a].currentPos = a;
  arr[b].currentPos = b;
}