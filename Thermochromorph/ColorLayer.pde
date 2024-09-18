/*
Adapted from https://tabreturn.github.io/code/processing/python/2019/02/09/processing.py_in_ten_lessons-6.3-_halftones.html
 */

class ColorLayer {
  float rotation;
  ArrayList<Pixel> pixelArray;
  color col;
  int mode;
  String colname;

  public ColorLayer(PImage img, float rotation_, String colname_) {
    pixelArray = new ArrayList<Pixel>();
    rotation = rotation_;
    colname = colname_;
    col = cmykcolors.get(colname);

    constructFromImage(img);
  }

  public void display() {
    pushMatrix();
    rotate(radians(rotation));

    fill(col);
    for (Pixel pix : pixelArray) {
      pix.display();
    }

    popMatrix();
  }

  public void displayBlock() {
    pushMatrix();
    rotate(-radians(rotation));
    scale(-1, 1);
    fill(255);
    for (Pixel pix : pixelArray) {
      pix.display();
    }

    popMatrix();
  }

  void constructFromImage(PImage img) {
    img.loadPixels();

    int origWidth = img.width;
    int origHeight = img.height;

    float newWidth = scalefactor*origWidth;
    float newHeight = scalefactor*origHeight;

    int coltotal = ceil(newWidth/cellsize);
    float oldcellsize = origWidth*cellsize/newWidth;

    int rowtotal = ceil(newHeight/cellsize);

    for (int row = 0; row < rowtotal; row++) {
      int y = int(row*cellsize) + int(cellsize/2);
      int oldy = int(row*oldcellsize) + int(oldcellsize/2);

      for (int col = 0; col < coltotal; col++) {

        // x,y position in pixels
        int x = int(col*cellsize) + int(cellsize/2);
        int oldx = int(col*oldcellsize) + int(oldcellsize/2);

        try {
          int idx = oldy * img.width + oldx;
          color pixel = img.pixels[idx];

          float b = 255-brightness(pixel);
          float amp = map(b, 0, 255, smallestpixel, 1.1*cellsize);

          if (b > 0) {
            addPixel(x-newWidth/2, y-newHeight/2, amp);
          }
        }

        catch (Exception e) {
          // sometimes we get out of bounds errors with the indexing but we can ignore them
        }
      }
    }
  }

  void addPixel(float x, float y, float size) {
    pixelArray.add(new Pixel(x, y, size));
  }
}
