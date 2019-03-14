import java.util.List;

public class Matrix {
  
  private ArrayList<Vector> columns = new ArrayList<Vector>();
  
  public Matrix(List<Vector> columns) {
    // columns.forEach(c -> this.columns.add(c.clone()));
    for (Vector c : columns) {
      this.columns.add(c.clone());
    }
  }
  public int colCount() {
    return columns.size();
  }
  public int rowCount() {
    return columns.get(0).size();
  }
  public Vector getColumn(int index) {
    return columns.get(index);
  }
  public ArrayList<Vector> getColumns() {
    return columns;
  }
  public ArrayList<Vector> getColumns(int start, int end) {
    return new ArrayList<Vector>(columns.subList(start, end));
  }
  public Vector getRow(int index) {
    double[] row = new double[this.colCount()];
    
    for (int c = 0; c < this.colCount(); c++) {
      row[c] = this.columns.get(c).get(index);
    }
    
    return new Vector(row);
  }
  public double getAt(int row, int column) {
    return this.columns.get(column).get(row);
  }
  public void setAt(int row, int column, double value) {
    this.columns.get(column).set(row, value);
  }
  public Matrix transpose() {
    ArrayList<Vector> rows = new ArrayList<Vector>(this.rowCount());

    for (int i = 0; i < this.rowCount(); i++) {
      rows.add(this.getRow(i));
    }
    
    return new Matrix(rows);
  }
  public Vector transformVector(Vector v) {
    double[] values = new double[this.rowCount()];

    Vector row;
    for (int r = 0; r < this.rowCount(); r ++) {
      row = this.getRow(r);
      values[r] = row.dot(v);
    }
    
    return new Vector(values);
  }
  /**
   * Perform a matrix multiplication AB = C
   * @param B
   * @return C
   */
  public Matrix multiply(Matrix B) {

    ArrayList<Vector> cColumns = new ArrayList<Vector>(B.colCount());

    double[] cCol;

    for (int bCol = 0; bCol < B.colCount(); bCol++) {
      
      cCol = new double[this.rowCount()];

      // take each row of A, and get the dot product
      // with the current column of B.
      // Store those values in cCol, which now holds the
      // values for one of the columns of the output matrix
      for (int aRow = 0; aRow < this.rowCount(); aRow++) {
        Vector currentRow = this.getRow(aRow);
        cCol[aRow] = currentRow.dot(B.getColumn(bCol));
      }
      
      cColumns.add(new Vector(cCol));
    }
    
    return new Matrix(cColumns);
  }
  /**
   * Returns an identity matrix of the same size
   * as the existing matrix. Must be a square matrix!
   * @return
   */
  public Matrix getIdentity() {
    ArrayList<Vector> vectors = new ArrayList<Vector>();
    double[] vals;
    for (int c = 0; c < this.colCount(); c++) {
      vals = new double[this.colCount()];
      vals[c] = 1;
      vectors.add(new Vector(vals));
    }
    return new Matrix(vectors);
  }
  public void swapRows(int a, int b) {
    for (Vector column : columns) {
      column.swap(a, b);
    }
  }
  /**
   * Computes the Gauss transform matrix by which the
   * current matrix needs to be multiplied in order
   * to zero out the given column.
   * @param col - If multiplying this matrix by
   * the matrix that results from this function, all elements
   * along column col will be zeroes, with the exception of
   * the element at row == col, which will be a 1.
   * @return
   */
  public Matrix getGaussTransform(int col) {
    ArrayList<Vector> rows = new ArrayList<Vector>(this.rowCount());
    for (int r = 0; r < this.rowCount(); r++) {
      rows.add(this.getRow(r));
    }
    
    double baseFactor = rows.get(col).get(col);
    if (baseFactor == 0.0) {
      // oh no!
    }
    
    for (int i = 0; i < rows.size(); i++) {
      // i == col marks a diagonal.
      // On this row, everything to the right
      // of col will be set to 0
      if (i == col) {
        for (int j = 0; j < rows.get(i).size(); j++) {
          if (j==i) {
            rows.get(i).set(j, 1);
          } else {
            rows.get(i).set(j, 0);
          }
        }

      } else {
        for (int j = 0; j < rows.get(i).size(); j++) {
          if (i == j) {
            rows.get(i).set(j, 1);
          } else if (j == col) {
            double tbr = rows.get(i).get(col);
            rows.get(i).set(j, -1*tbr/baseFactor);
          } else {
            rows.get(i).set(j, 0);
          }
        }
      }
    }
    
    ArrayList<Vector> columns = new ArrayList<Vector>();
    double[] colValues;

    for (int currentCol = 0; currentCol < rows.size(); currentCol ++) { //<>//

      colValues = new double[rows.size()];

      for (int j = 0; j < rows.size(); j++) {

        colValues[j] = rows.get(j).get(currentCol);

      }

      columns.add(new Vector(colValues));

    }
    
    return new Matrix(columns);
  }
  
  public Matrix invert() {

    // Create an appended system, with the identity matrix on the right hand side
    Matrix I = this.getIdentity();
    ArrayList<Vector> appendedColumns = new ArrayList<Vector>(this.colCount()*2);
    
    for (Vector column : this.columns) {
      appendedColumns.add(column.clone());
    }
    for (int i = 0; i < this.colCount(); i++) {
      appendedColumns.add(I.getColumn(i).clone());
    }
    
    Matrix appendedMatrix = new Matrix(appendedColumns);
    
    for (int column = 0; column < this.colCount(); column++) {
      
      // swap rows if the current row would cause a division by zero
      int nextNonZeroRow = findNextNonZeroRow(column, column-1);
      
      if (nextNonZeroRow < 0) {
        // all remaining rows have zeroes on the given column.
        // Algorithm must terminate. Inverse cannot be computed.
        return appendedMatrix;
      } else if (nextNonZeroRow == column) {
        // no row swapping needed
      } else {
        appendedMatrix.swapRows(column, nextNonZeroRow);
      }

      Matrix gt = appendedMatrix.getGaussTransform(column);
      appendedMatrix = gt.multiply(appendedMatrix);
    }
    
    // The left hand side of the matrix is now in a state
    // such that each column (on the left-hand, original side)
    // only has a single value. If we divide each row by that
    // value, it will result in that value being reduced
    // to 1, and the right hand ("appended") side of the matrix
    // will contain the inverse of the original matrix
    
    for (int row = 0; row < appendedMatrix.rowCount(); row++) {
      double factor = appendedMatrix.getRow(row).get(row);
      
      if (factor == 0.0) {
        
        println("Gaussian elimination did not remove all zeroes from the diagonal.");
      } else {
      
        for (Vector column : appendedMatrix.columns) {
          // get the value for the current row in this column
          double currentValue = column.get(row);
          column.set(row, currentValue/factor);
        }

      }
    }

    // the left side of the matrix is now an identity matrix
    // The right hand side is therefore the inverse
    
    List<Vector> invertedCols = appendedMatrix.getColumns(this.rowCount(), this.rowCount() * 2);
    
    return new Matrix(invertedCols);
  }
  
  public void debugPrint() {
    for (int i = 0; i < this.rowCount(); i++) {
      Vector row = this.getRow(i);
      String txt = "";
      for (int j = 0; j < row.size(); j++) {
        txt += row.get(j) + ", ";
      }
      
      println(txt);
    }
  }
  
  /**
    * Return the index of the next row whose value at the
    * specified column is nonzero. If all rows below the
    * current row are 0, then the return value is -1.
    */
  private int findNextNonZeroRow(int col, int currentRow) {
    Vector c = this.getColumn(col);
    for (int i = currentRow + 1; i < c.size(); i++) {
      if (c.get(i) != 0.0) {
        return i;
      }
    }
    
    return -1;
  }
  
}
