import controlP5.*;
ControlP5 cp5;
import java.util.*;


Accordion accordionMain;
Canvas toioInputCanvas;
float inputCanvasScale = 0.55;

Canvas stageCanvas;
boolean disableInputCanvas = false;

List fileList;
ScrollableList files;

int canvasWidth = 320;
int canvasHeight = 300;

int GUIBaseWidth = 600;
int GUIPosX = 10;
int GUIPosY = 10;


boolean draggingPortal = false;
int draggedPortal = 0;

boolean draggingWallPoint = false;
int draggedWallPoint = 0;


void gui() {

  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);


  // group number 2, contains a bang and a slider
  Group g1 = cp5.addGroup("DataList")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(120)
    ;

  // group number 2, contains a bang and a slider
  Group g2 = cp5.addGroup("InputCanvas")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(500)
    ;

  Group g3 = cp5.addGroup("StageCanvas")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(500)
    ;

  ////

  fileList = Arrays.asList(filenames);

  files = cp5.addScrollableList("filelist")
    .setPosition(10, 10)
    .setSize(300, 80)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItems(fileList)
    .moveTo(g1)
    .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    ;

  toioInputCanvas = new MytoioInputCanvas();
  //stageCanvas.pre(); // use 
  toioInputCanvas.post(); //to draw on top of existing controllers.
  g2.addCanvas(toioInputCanvas);


  stageCanvas = new MyStageCanvas();
  //stageCanvas.pre(); // use 
  stageCanvas.post(); //to draw on top of existing controllers.
  g3.addCanvas(stageCanvas);




  // create a new accordion
  // add g1, g2, and g2 to the accordion.
  accordionMain = cp5.addAccordion("acc")
    .setPosition(GUIPosX, GUIPosY)
    .setWidth(GUIBaseWidth)
    .addItem(g1)
    .addItem(g2)
    .addItem(g3)
    ;

  accordionMain.open(0, 1);

  // use Accordion.MULTI to allow multiple group 
  // to be open at a time.
  accordionMain.setCollapseMode(Accordion.MULTI);
}



class MytoioInputCanvas extends Canvas {
  public void setup(PGraphics pg) {
  }  

  public void draw(PGraphics pg) {
    // renders a square with randomly changing colors
    // make changes here.
    //pg.background(0);
    pg.pushMatrix();
    pg.scale(inputCanvasScale);
    if(!disableInputCanvas){
    rawInputDisplay(pg);
    }

    pg.popMatrix();
  }
}



class MyStageCanvas extends Canvas {
  public void setup(PGraphics pg) {
  }  

  public void draw(PGraphics pg) {
    // renders a square with randomly changing colors
    // make changes here.

    pg.pushMatrix();
    pg.smooth();
    pg.translate(10, 10);
    pg.fill(200);

    float ww = map(stageWidth, 0, stageWidthMax, 0, canvasWidth);
    float dd = map(stageDepth, 0, stageDepthMax, 0, canvasHeight);
    pg.rect(0, 0, ww, dd);


    pg.ellipseMode(CENTER);
    pg.rectMode(CENTER);
    if (onCanvas) {
      pg.fill(200, 0, 0);
      pg.ellipse(mx_, my_, 5, 5);
    }


    pg.stroke(255, 255, 255);
    pg.strokeWeight(5);
    pg.noFill();
    for (int i = 0; i<wallPointNum-1; i++) {
      pg.line(MatToCanvasVec(wallPoint[i]).x, MatToCanvasVec(wallPoint[i]).y, MatToCanvasVec(wallPoint[i+1]).x, MatToCanvasVec(wallPoint[i+1]).y );
    }

    pg.stroke(255, 0, 0, 100);
    pg.strokeWeight(2);
    for (int i = 0; i<wallPointNum; i++) {
      pg.ellipse(MatToCanvasVec(wallPoint[i]).x, MatToCanvasVec(wallPoint[i]).y, 7, 7);
    }

    pg.noStroke();




    pg.noFill();
    for (int i =0; i<portalWallNum; i++) {
      pg.stroke(PortalColor);
      pg.strokeWeight(2);
      pg.ellipse(MatToCanvasVec(portalWallVec[i]).x, MatToCanvasVec(portalWallVec[i]).y, 10, 10);
      //pg.line(wall);
      pg.noStroke();
    }


    for (int i =0; i<portalFloorNum; i++) {
      pg.stroke(PortalColor);
      pg.strokeWeight(2);
      pg.fill(100);
      pg.rect(MatToCanvasVec(portalFloor[i]).x, MatToCanvasVec(portalFloor[i]).y, MatToCanvasIntW(portalFloorSize), MatToCanvasIntD(portalFloorSize));

      //pg.line(wall);
      pg.noStroke();
    }


    for (int i =0; i<pillarNum; i++) {
      //pg.stroke(pillarColor);
      pg.noStroke();
      pg.fill(pillarColor);
      pg.rect(MatToCanvasVec(pillar[i]).x, MatToCanvasVec(pillar[i]).y, MatToCanvasIntW(pillarSize), MatToCanvasIntD(pillarSize));

      //pg.line(wall);
      pg.noStroke();
    }



    pg.popMatrix();

    pg.rectMode(CORNER);
  }
}

int mx_ = 0;
int my_ = 0;

boolean onCanvas = false;

void getMouseforCanvas() {

  int xx = mouseX -25;
  int yy = mouseY -167;

  if ( (0 <= xx && xx < stageWidthMax * inputCanvasScale) &&  (0 <= yy && yy < stageDepthMax * inputCanvasScale)) {
    mx_ = xx;
    my_ = yy;
    onCanvas = true;
  } else {
    onCanvas = false;
  }
}


void mousePressedOnCanvas() {
  if (keyPressed) {
    //println("HEY", char(key), int(char(key)), int(char(1)));
    for (int i = 0; i< nCubes; i++) {
      if (int(key) == i + 48) {
        cubes[i].targetx = mx_/inputCanvasScale;
        cubes[i].targety = my_/inputCanvasScale;

      //  println("yes", cubes[i].targetx, cubes[i].targety, i);
      }
    }
  }
}



void controlEvent(ControlEvent theEvent) {

  if (theEvent.getName().equals("filelist")) {

    loadStageCSV(int(theEvent.getValue()));
  }


  println("Name: " + theEvent.getName(), "Value: " + theEvent.getValue());
  //println(int(theEvent.getValue()));
}
