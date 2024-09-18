import controlP5.*;
ControlP5 cp5;

import processing.svg.*;
import java.io.File;
import java.util.HashMap;
import java.io.*;

final int COLOR = 1;
final int BLOCK = 0; // render for block printing

float PPI;
//float kerf = inchesToPixels(0.04);
// width of the smallest dot that you can reliably engrave and print (in inches)
float smallestdot = 0.02;
float smallestpixel;
float cellsize;

// the smallest dimensions of the image
// that preserves proportions (in pixels)
int smallestWidth;
int smallestHeight;

// desired width of the piece in inches
float desiredWidth;

int finalWidthPixels = 0;
int finalHeightPixels = 0;

HashMap<String, Integer> cmykcolors;

String[] cmykpaths = {"y_0", "c_15", "m_75", "k_45"};

float scalefactor;

boolean[] cmykVisible;
CMYKImage cmyk;

CMYKImage cmyk2;

float colwidth = 500;
float colHeight;
PFont font;
ControlFont uifont;

// UI
CheckBox img1layers;

String path_prefix;

int origWidthimg1;
int origHeightimg1;

int visibleImage = 1;

color altyellow = color(242, 132, 29);

void setup() {
  pixelDensity(displayDensity());
  size(800, 800);
  background(255);
  surface.setTitle("THERMOCHROMORPH");
  path_prefix = sketchPath() + "/";

  PPI = 72/displayDensity();

  smallestpixel = inchesToPixels(smallestdot);
  cellsize = ceil(smallestpixel*2);
  desiredWidth = 4.5;

  cmykcolors = new HashMap<String, Integer>();
  cmykcolors.put("alty", altyellow);
  cmykcolors.put("y", color(237, 224, 36));
  cmykcolors.put("c", color(30, 192, 232));
  cmykcolors.put("m", color(255, 87, 219));
  cmykcolors.put("k", 0);

  cmykVisible = new boolean[4];
  for (int i = 0; i < 4; i++) {
    cmykVisible[i] = true;
  }

  cp5 = new ControlP5(this);

  // run cmyk conversion script
  String commandToRun = "./convert_to_cmyk.sh";

  File workingDir = new File(sketchPath(""));
  try {
    Process p = Runtime.getRuntime().exec(commandToRun, null, workingDir);
    p.waitFor();
  }
  catch (Exception e) {
    println("Error running command!");
    println(e);
  }

  delay(400); // give the script some time to generate files
  File cfile = new File(path_prefix+"data/img1/c_15.png");
  File mfile = new File(path_prefix+"data/img1/m_75.png");
  File yfile = new File(path_prefix+"data/img1/y_0.png");
  File kfile = new File(path_prefix+"data/img1/k_45.png");
  println("waiting for CMYK files to generate....");
  while (!(cfile.exists()&&mfile.exists()&&yfile.exists()&&kfile.exists())) {
  }

  font = loadFont("VCROSDMono.vlw");
  uifont = new ControlFont(font);
  uifont.setSize(15);

  cp5.setFont(uifont);
  cp5.setColorForeground(0xffcf466a);
  cp5.setColorBackground(0xff400a18);
  cp5.setColorActive(0xffff5280);

  cmyk = new CMYKImage("img1", cmykpaths);
  cmyk.saveBlocks("img1");

  cmyk2 = new CMYKImage("img2", cmykpaths);
  cmyk2.saveBlocks("img2");

  drawUI();
}

void drawUI() {
  img1layers = cp5.addCheckBox("checkBox")
    .setPosition(30 + finalWidthPixels/3, 250 + finalHeightPixels*(colwidth/finalWidthPixels))
    .setItemsPerRow(4)
    .setSpacingColumn(int(colwidth/6)+5)
    .setImages(loadImage("./UI/hide.png"), loadImage("./UI/hidehover.png"), loadImage("./UI/show.png"))
    .addItem("yellow", 1)
    .addItem("cyan", 1)
    .addItem("magenta", 1)
    .addItem("black", 1)
    .setColorLabel(0)
    .activateAll()
    ;

  cp5.addTextfield("desiredWidthField")
    .setPosition(width*0.8, height*0.3)
    .setSize(50, 30)
    .setLabel("width (in)")
    .setValue("4.5")
    .setAutoClear(false)
    ;
}

void draw() {
  background(255);

  fill(0xff45474a);
  rect(width-200, 0, 200, height);
  PImage original = loadImage("../img"+visibleImage+".png");
  image(original, width-200, 0, 200, (200/float(original.width))*original.height);

  rectMode(CORNER);
  noStroke();
  fill(255);
  rect(40, 90, colwidth, colHeight);

  if (visibleImage == 1) {
    cmyk.updateMeasurements("img1");
    cmyk.display(40, 90, colwidth);
    cmyk.displayBlocks(40, 130 + colHeight, colwidth);

    fill(40);
    textAlign(CENTER);
    textFont(font, 14);
    text( "Image 1 (visible at room temperature)", width*0.35, 30);
  } else {
    cmyk2.updateMeasurements("img2");
    cmyk2.display(40, 90, colwidth);
    cmyk2.displayBlocks(40, 130 + colHeight, colwidth);

    fill(40);
    textAlign(CENTER);
    textFont(font, 14);
    text( "Image 2 (visible at 35°C)", width*0.35, 30);
  }

  stroke(0, 60);
  strokeWeight(1);
  line(40, 70, 40+colwidth, 70);
  line(60+colwidth, 90, 60+colwidth, 90+colHeight);

  fill(0, 170);
  textAlign(LEFT);
  textFont(font, 12);
  text((desiredWidth) + "\"", 40, 65);
  pushMatrix();
  translate(75+colwidth, 90+colHeight);
  rotate(radians(-90));
  text(desiredWidth/pixelsToInches(finalWidthPixels)*pixelsToInches(finalHeightPixels) + "\"", 0, 0);
  popMatrix();

  float gridHeight = colHeight;
  float gridWidth = (colwidth-30)/4 + 10;

  noStroke();
  if (visibleImage == 1) fill(cmykcolors.get("y"));
  else fill(altyellow);
  rectMode(CORNER);
  rect(40, 110 + gridHeight, 15, 15);
  fill(0);
  text("YELLOW", 62, 125 + gridHeight);

  fill(cmykcolors.get("c"));
  rect(40 + gridWidth, 110 + gridHeight, 15, 15);
  fill(0);
  text("CYAN", 62 +gridWidth, 125 + gridHeight);

  fill(cmykcolors.get("m"));
  rect(40 + gridWidth*2, 110 + gridHeight, 15, 15);
  fill(0);
  text("MAGENTA", 62 +gridWidth*2, 125 + gridHeight);

  fill(cmykcolors.get("k"));
  rect(40 + gridWidth*3, 110 + gridHeight, 15, 15);
  fill(0);
  text("BLACK", 62 +gridWidth*3, 125 + gridHeight);
}

void desiredWidthField(String w) {
  desiredWidth = float(w.strip());
  cmyk = new CMYKImage("img1", cmykpaths);
  cmyk.saveBlocks("img1");

  cmyk2 = new CMYKImage("img2", cmykpaths);
  cmyk2.saveBlocks("img2");
}

void keyReleased() {
  if (keyCode == TAB) {
    if (visibleImage == 1) visibleImage= 2;
    else visibleImage = 1;
  }
}

float inchesToPixels(float inches) {
  return inches * PPI;
}

float pixelsToInches(int pix) {
  return pix/PPI;
}
