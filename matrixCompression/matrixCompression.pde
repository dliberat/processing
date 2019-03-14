/**
  * MATRIX COMPRESSION
  *
  * This sketch shows a simple and inefficient method of compressing an image
  * by projecting the full image onto a subspace whose bases are a subset
  * of pixel columns from the original image.
  */

PImage raw;
PImage compressed;

/**
  * The proportion of columns from the original image
  * to use as a basis for the subspace onto which we
  * project the full image.
  * Higher numbers mean higher compression.
  * Avoid setting this lower than 3 because the processing
  * time increases exponentially.
  */
final int COMP_FACTOR = 4;


public void setup() {
  size(768, 288);

  raw = loadImage("elephants.jpg");

  compressed = projectionCompression(raw, COMP_FACTOR);
}


public void draw() {
  background(0);

  image(raw, 0, 0);
  image(compressed, 384, 0);
  noLoop();
}

/**
  * Compress an image by projecting each column of pixels onto the column space
  * of a subset of its pixel columns. The compressed image is then rebuilt 
  * and returned as a PImage object.
  *
  * This function is inefficient in its implementation, and it
  * has to calculate inverse matrices, so it will run extremely slowly.
  * Avoid setting the compression factor (n) below 3.
  *
  * @param original - Original image to compress
  * @param n - Compression factor
  */
private PImage projectionCompression(PImage original, int n) {
  
  // Choose columns of pixels to form the subspace
  // onto which we will project the entire image.
  // More columns means a higher-dimensional subspace,
  // and therefore better fidelity in the projection
  ArrayList<Vector> subSpaceVs = new ArrayList<Vector>();

  for (int w = 0; w < original.width; w+=n) {

    Vector cv = new Vector(getPixelColumn(original, w));
    subSpaceVs.add(cv);

  }

  Matrix A = new Matrix(subSpaceVs);

  // Convert all the pixels of the image into
  // a Matrix object so we can manipulate it more easily
  Matrix B = pImage2Matrix(original);

  // To project B onto the column space of A we pass it
  // through the matrix A (AtA)^-1 At
  // but here we're actually going to stop just before the
  // final step so we get a smaller matrix out of it.
  Matrix At = A.transpose();
  Matrix AtAinv = At.multiply(A).invert();
  Matrix AtAinvAtB = AtAinv.multiply(At.multiply(B));
  
  // The original matrix B contained information about
  // this many total points (ie. pixels)
  int rawDataPoints = original.width * original.height;
  
  // Our compressed image, contained in the two matrices
  // A and AtAinvAtB, contains this many total data points
  int compressedDataPoints = (AtAinvAtB.colCount() * AtAinvAtB.rowCount()) + (A.rowCount() * A.colCount());
  
  println("Original: \t\t" + rawDataPoints);
  println("Compressed:\t" + compressedDataPoints);
  
  // When we want to decompress the image, we simply pass in the
  // temporary matrix through the final step in the projection process.
  Matrix P = A.multiply(AtAinvAtB);
  
  return matrix2pimg(P, original.width, original.height);
}


/**
  * Returns the grayscale values of the image's pixels
  * represented as a Matrix object.
  */
private Matrix pImage2Matrix(PImage img) {
  ArrayList<Vector> imgColumns = new ArrayList<Vector>(img.width);
  for (int i = 0; i < img.width; i++) {
    imgColumns.add(new Vector(getPixelColumn(img, i)));
  }
  return new Matrix(imgColumns);
}

/**
 * Grab a selected column of pixels from the image.
 */
private double[] getPixelColumn(PImage img, int column) {
  double[] pixelCol = new double[img.height];

  for (int y = 0; y < img.height; y++) {
    double px = gray(img.pixels[column + (y * img.width)]);
    pixelCol[y] = px;
  }
  
  return pixelCol;
}

/**
  * Get the grayscale value of a pixel
  */
private double gray(int value) {
  return max((value >> 16) & 0xff, (value >> 8) & 0xff, value &0xff);
}

/**
  * Convert the grayscale values on a matrix to a PImage object.
  */
private PImage matrix2pimg(Matrix p, int w, int h) {

  double[] reconstructedValues = new double[w*h];
  int index = 0;
  
  for (int y = 0; y < h; y++) {
    for (Vector col : p.columns) {
       reconstructedValues[index] = col.get(y);
       index++;
     }
  }

  PImage decomp = new PImage(w, h);
  decomp.loadPixels();
    for (int x = 0; x < reconstructedValues.length; x++) {
      decomp.pixels[x] = color((int)reconstructedValues[x]);
    }
  decomp.updatePixels();
  
  return decomp;
}
