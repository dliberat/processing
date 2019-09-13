class Tile {
  
  constructor(h, content, initpos) {
    this.h = h;
    this.content = content;
    this.initpos = initpos;
    this.currentPos = initpos;
  }
  
  clone() {
    const t = new Tile(this.h, this.content, this.initpos);
    t.currentPos = this.currentPos;
    return t;
  }
  
  draw() {
    stroke(0);
    noFill();
    image(this.content, 0, 0);
    rect(0, 0, this.h, this.h);
  }
  
  canMove(tiles) {
    const currentPos = this.currentPos;
    
    let empty = -1;
    for (let i = 0; i < tiles.length; i++) {
      if (tiles[i].initpos === tiles.length -1) {
        empty = i;
        break;
      }
    }

    const larger = max(empty, currentPos);
    const diff = abs(empty-currentPos);
    const areVertical = diff === PIECE_COUNT;
    
    // if the indices are off by 1 and the larger piece is on the left-hand side 
    // of the board, the two pieces are on different rows
    const areHoriz = (diff === 1) && (larger % PIECE_COUNT !== 0);
    
    if (areVertical || areHoriz) {
      return {
        from: currentPos,
        to: empty,
      };
    } else {
      return false;
    }
  }

  /**
   * Manhattan distance from the tile's initial location
   */
  distanceFromHome(pc) {
    const home = this.initpos;
    const currentPos = this.currentPos;
   
    const cur_row = floor(currentPos / pc);
    const cur_col = currentPos - (cur_row * pc);
    
    const home_row = floor(home / pc);
    const home_col = home - (home_row * pc);

    const d = abs(home_row - cur_row) + abs(home_col - cur_col);
    return d;
  }
}

class EmptyTile extends Tile {
  draw() {
    stroke(0);
    fill(0, 150);
    rect(0, 0, this.h, this.h);
  }
  canMove() {
    return false;
  }
  clone() {
    const t = new EmptyTile(this.h, this.content, this.initpos);
    t.currentPos = this.currentPos;
    return t;
  }
}