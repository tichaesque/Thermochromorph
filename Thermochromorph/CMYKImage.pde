class CMYKImage {
  ColorLayer[] cmykImage;

  public CMYKImage(String imgName, String[] cmykpaths) {
    cmykImage = new ColorLayer[4];

    scalefactor = 0;
    finalWidthPixels = 0;
    finalHeightPixels = 0;
    updateMeasurements(imgName);

    for (String channel : cmykpaths) {
      PImage img = loadImage(imgName + "/" + channel + ".png");

      String colorName = channel.split("_")[0];
      //if (imgName.equals("img2") && colorName.equals("y")) colorName = "alty"; 
      float rotation = float(channel.split("_")[1]);

      ColorLayer layer = new ColorLayer(img, rotation, colorName);

      if (colorName.equals("y") || colorName.equals("alty")) {
        cmykImage[0] = layer;
      } else if (colorName.equals("c")) {
        cmykImage[1] = layer;
      } else if (colorName.equals("m")) {
        cmykImage[2] = layer;
      } else if (colorName.equals("k")) {
        cmykImage[3] = layer;
      }
    }
  }

  public void display(float x, float y, float w) {
    //beginRecord(SVG, "./head.svg");
    blendMode(MULTIPLY);
    pushMatrix();
    float sc = w/finalWidthPixels;
    scale(sc);

    translate(x/sc + finalWidthPixels/2, y/sc + finalHeightPixels/2);


    for (int i = 0; i < cmykImage.length; i++) {
      if (img1layers.getState(i)) cmykImage[i].display();
    }

    popMatrix();
    //endRecord();
  }

  public void displayBlocks(float x, float y, float w) {
    rectMode(CENTER);
    blendMode(BLEND);
    float sc = w/(finalWidthPixels*4 + 30);
    float offsetx = 0;
    pushMatrix();
    scale(sc);
    translate(x/sc + finalWidthPixels/2, y/sc + finalHeightPixels/2);

    for (ColorLayer layer : cmykImage) {
      pushMatrix();
      translate(offsetx, 0);
      stroke(255, 0, 0);
      strokeWeight(0.0001);
      fill(0);
      rect(0, 0, finalWidthPixels, finalHeightPixels);

      stroke(255, 0, 0);
      strokeWeight(0.0001);
      noFill();
      rect(0, 0, finalWidthPixels, finalHeightPixels);

      layer.displayBlock();
      offsetx += finalWidthPixels + 10;
      popMatrix();
    }

    popMatrix();
  }

  // TODO: use PGraphics instead
  public void saveBlocks(String imgName) {

    for (ColorLayer layer : cmykImage) {
      beginRecord(SVG, "./print/"+imgName+ "_" +layer.colname+".svg");
      pushMatrix();
      
      stroke(255, 0, 0);
      strokeWeight(0.0001);
      fill(0);
      rect(0, 0, finalWidthPixels, finalHeightPixels);

      stroke(255, 0, 0);
      strokeWeight(0.0001);
      noFill();
      rect(0, 0, finalWidthPixels, finalHeightPixels);

      translate(finalWidthPixels/2, finalHeightPixels/2);
      layer.displayBlock();
      popMatrix();
      endRecord();
    }
  }

  void updateMeasurements(String imgName) {
    PImage img = loadImage("../"+imgName+".png");
    origWidthimg1 = img.width;
    origHeightimg1 = img.height;

    int gcd = gcd(origWidthimg1, origHeightimg1);
    smallestWidth = origWidthimg1/gcd;
    smallestHeight = origHeightimg1/gcd;
    
    scalefactor = inchesToPixels(desiredWidth)/float(origWidthimg1);
    finalWidthPixels = ceil(inchesToPixels(desiredWidth));
    finalHeightPixels = ceil(origHeightimg1*scalefactor);
    colHeight = finalHeightPixels*(colwidth/finalWidthPixels);
    
    if(colHeight > 500) {
      colHeight = 500; 
      colwidth = finalWidthPixels*(colHeight/finalHeightPixels);
    }
  }

  int gcd(int p, int q) {
    if (q == 0) return p;
    else return gcd(q, p % q);
  }
}
