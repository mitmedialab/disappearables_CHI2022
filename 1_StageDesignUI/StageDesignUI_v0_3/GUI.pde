import controlP5.*;
ControlP5 cp5;
import java.util.*;


Accordion accordionMain;
Accordion accordionPortal;

Slider2D stageSizeSlider;
RadioButton editModeRadio;
Canvas stageCanvas;
List fileList;
ScrollableList files;

Slider2D _3DP_CoordSlider;

int canvasWidth = 320;
int canvasHeight = 300;

int GUIBaseWidth = 340;
int GUIPosX = 10;
int GUIPosY = 10;

int editMode = 1; //1: wall,  2: portal_Wall, 3:portal_Floor, 4:underground_wall

boolean draggingPortal = false;
int draggedPortal = 0;

boolean draggingWallPoint = false;
int draggedWallPoint = 0;

String movementPlan = "";

void gui() {

  cp5 = new ControlP5(this);
  cp5.setAutoDraw(false);

  // group number 1, contains 2 bangs
  Group g1 = cp5.addGroup("BasicStage")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(370)
    ;

  // group number 2, contains a bang and a slider
  Group g2 = cp5.addGroup("EditStage")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(360)
    ;

  // group number 3, contains a bang and a slider
  Group g3 = cp5.addGroup("DataList")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(160)
    ;

  // group number 4, loads a plan.
  Group g4 = cp5.addGroup("PlanList")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(160)
    ;

  // Bang b = 
  cp5.addBang("LOAD PLAN")
    .setPosition(0, 0)
    .setSize(80, 20)
    .moveTo(g4)
    .plugTo(this, "loadCSV");
  ;
  
  // Bang b = 
  cp5.addBang("PLAY PLAN")
    .setPosition(90, 0)
    .setSize(80, 20)
    .moveTo(g4)
    ;
  ;  

  fileList = Arrays.asList(filenames);

  files = cp5.addScrollableList("filelist")
    .setPosition(10, 10)
    .setSize(300, 120)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItems(fileList)
    .moveTo(g3)
    .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    ;



  stageSizeSlider = cp5.addSlider2D("StageSize")
    .setPosition(10, 10)
    .setSize(canvasWidth, canvasHeight)
    .setMinMax(0, 0, stageWidthMax, stageDepthMax)
    .setValue(500, 500)
    .moveTo(g1)
    //.disableCrosshair()
    ;

  cp5.addToggle("UnderStage")
    .setPosition(10, 330)
    .setSize(50, 20)
    .moveTo(g1)
    ;

  cp5.addToggle("_3DP")
    .setPosition(80, 330)
    .setSize(50, 20)
    .moveTo(g1)
    ;

  cp5.addTextfield("FileName")
    .setPosition(180, 330)
    .setSize(120, 20)
    .setFocus(true)
    .moveTo(g1)
    ;


  cp5.addBang("SAVE")
    .setPosition(310, 330)
    .setSize(20, 20)
    .moveTo(g1)
    ;

  editModeRadio = cp5.addRadioButton("radioButton")
    .setPosition(10, 10)
    .setSize(16, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(5)
    .setSpacingColumn(37)
    .addItem("WALL", 0)
    .addItem("PORT_W", 1)
    .addItem("PORT_F", 2)
    .addItem("PILLAR", 3)
    .addItem("WALL_U", 4)
    .moveTo(g2)
    ;

  // Bang b = 
  cp5.addBang("clear")
    .setPosition(290, 10)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setSize(40, 20)
    .moveTo(g2)
    .plugTo(this, "clearStageEdit");
  ;

  stageCanvas = new MyCanvas();
  //stageCanvas.pre(); // use 
  stageCanvas.post(); //to draw on top of existing controllers.
  g2.addCanvas(stageCanvas);

  // create a new accordion
  // add g1, g2, and g2 to the accordion.
  accordionMain = cp5.addAccordion("acc")
    .setPosition(GUIPosX, GUIPosY)
    .setWidth(GUIBaseWidth)
    .addItem(g1)
    .addItem(g2)
    .addItem(g3)
    .addItem(g4)
    ;

  accordionMain.open(0, 1, 2);

  // use Accordion.MULTI to allow multiple group 
  // to be open at a time.
  accordionMain.setCollapseMode(Accordion.MULTI);

  editModeRadio.activate(0);
  editMode = 0;


  accordionPortal = cp5.addAccordion("acc2")
    .setPosition(GUIPosX + GUIBaseWidth, GUIPosY)
    .setWidth(GUIBaseWidth-100)
    .setMinItemHeight(70)
    ;

  accordionPortal.setCollapseMode(Accordion.MULTI);
}




class MyCanvas extends Canvas {
  public void setup(PGraphics pg) {
  }  

  public void draw(PGraphics pg) {
    // renders a square with randomly changing colors
    // make changes here.
    pg.pushMatrix();
    pg.smooth();
    pg.translate(10, 50);
    pg.fill(200);

    float ww = map(stageWidth, 0, stageWidthMax, 0, canvasWidth);
    float dd = map(stageDepth, 0, stageDepthMax, 0, canvasHeight);
    pg.rect(0, 0, ww, dd);


    pg.ellipseMode(CENTER);
    pg.rectMode(CENTER);
    


    pg.stroke(255, 255, 255);
    pg.strokeWeight(5);
    pg.noFill();
    for (int i = 0; i<wallPointNum-1; i++) {
      pg.line(MatToCanvasVec(wallPoint[i]).x, MatToCanvasVec(wallPoint[i]).y, MatToCanvasVec(wallPoint[i+1]).x, MatToCanvasVec(wallPoint[i+1]).y );
    }
    
    pg.stroke(0, 0, 0, 200);
    for (int i = 0; i<under_wallPointNum-1; i++) {
      pg.line(MatToCanvasVec(under_wallPoint[i]).x, MatToCanvasVec(under_wallPoint[i]).y, MatToCanvasVec(under_wallPoint[i+1]).x, MatToCanvasVec(under_wallPoint[i+1]).y );
    }

    pg.stroke(255, 0, 0, 100);
    pg.strokeWeight(2);
    for (int i = 0; i<wallPointNum; i++) {
      pg.ellipse(MatToCanvasVec(wallPoint[i]).x, MatToCanvasVec(wallPoint[i]).y, 7, 7);
    }
    
    pg.stroke(255, 0, 0, 50);
    pg.strokeWeight(2);
    for (int i = 0; i<under_wallPointNum; i++) {
      pg.ellipse(MatToCanvasVec(under_wallPoint[i]).x, MatToCanvasVec(under_wallPoint[i]).y, 7, 7);
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
    
    if (onCanvas) {
      pg.fill(200, 0, 0);
      pg.ellipse(mx_, my_, 5, 5);
      
      pg.textSize(12);
      PVector coord = new PVector (mx_, my_);
      //CanvasToMatVec()
      coord = CanvasToMatVec(coord);
      pg.text("(" + (int)coord.x + ", " + (int)coord.y + ")", mx_+2, my_-2);
    }



    pg.popMatrix();

    pg.rectMode(CORNER);
  }
}

int mx_ = 0;
int my_ = 0;

boolean onCanvas = false;

void getMouseforCanvas() {

  int xx = mouseX -20;
  int yy = mouseY -450;

  if ( (0 <= xx && xx < canvasWidth) &&  (0 <= yy && yy < canvasHeight)) {
    mx_ = xx;
    my_ = yy;
    onCanvas = true;
  } else {
    onCanvas = false;
  }
}


void mousePressedOnCanvas() {

  if (editMode==0) {//CREATE WALL


    PVector mouseVec = CanvasToMatVec(new PVector(mx_, my_));

    draggingWallPoint = false;
    draggedWallPoint = 0;
    int draggingRange = 10;
    for (int i = 0; i < wallPointNum; i++) {
      if (dist(mouseVec.x, mouseVec.y, wallPoint[i].x, wallPoint[i].y)<draggingRange) {
        draggingWallPoint = true;
        draggedWallPoint = i;
      }
    }

    if (!draggingWallPoint) { // add new wall point
      wallPoint[wallPointNum].set(CanvasToMatVec(new PVector(mx_, my_))); 
      wallPointNum++;
    } else {
    }
  } else if (editMode==1) { // CREATE PORTAL ON WALL
    if (wallPointNum > 1) {
      PVector minV = new PVector(0, 0);
      float minDist = 300;

      PVector mouseVec = CanvasToMatVec(new PVector(mx_, my_));

      float a_ = 0;

      for (int i = 0; i < wallPointNum-1; i++) {
        float dist = dist(wallPoint[i].x, wallPoint[i].y, wallPoint[i+1].x, wallPoint[i+1].y);
        for (int j = 0; j < dist; j++) {
          float xx = map(j, 0, dist, wallPoint[i].x, wallPoint[i+1].x);
          float yy = map(j, 0, dist, wallPoint[i].y, wallPoint[i+1].y);

          float dd = dist(xx, yy, mouseVec.x, mouseVec.y);

          if (dd<minDist) {
            a_ = atan2((wallPoint[i+1].y - wallPoint[i].y), (wallPoint[i+1].x - wallPoint[i].x))+PI/2;
            minDist = dd;
            minV = new PVector(xx, yy);
            portalWallatWallNum[portalWallNum] = i;
          }
        }
      }

      portalWallVec[portalWallNum] = minV;

      //get Back and Front point, and EdgeLR


      portalWallFrontPoint[portalWallNum] = new PVector(minV.x + cos(a_)*entryOffset, minV.y + sin(a_)*entryOffset);
      portalWallBackPoint[portalWallNum] = new PVector(minV.x - cos(a_)*entryOffset, minV.y - sin(a_)*entryOffset);
      portalWallWidth[portalWallNum] = portalWallBaseWidth;
      portalWallEdgeL[portalWallNum] = new PVector(minV.x + cos(a_+radians(90))*portalWallWidth[portalWallNum]/2, minV.y + sin(a_+radians(90))*portalWallWidth[portalWallNum]/2);
      portalWallEdgeR[portalWallNum] = new PVector(minV.x + cos(a_+radians(-90))*portalWallWidth[portalWallNum]/2, minV.y + sin(a_+radians(-90))*portalWallWidth[portalWallNum]/2);

      addPortalWallGUI(portalWallNum);

      portalWallNum++;
    }
  } else if (editMode==2) { //CREATE PORTAL ON FLOOR

    draggingPortal = false;
    draggedPortal = 0;
    float xx = CanvasToMatVec(new PVector(mx_, my_)).x;
    float yy = CanvasToMatVec(new PVector(mx_, my_)).y;

    for (int i = 0; i< portalFloorNum; i++) {
      if (portalFloor[i].x - portalFloorSize/2 < xx && portalFloor[i].x + portalFloorSize/2 > xx &&
        portalFloor[i].y - portalFloorSize/2 < yy && portalFloor[i].y + portalFloorSize/2 > yy) {
        draggingPortal = true;
        draggedPortal = i;
      }
    }

    if (!draggingPortal) {
      portalFloor[portalFloorNum]= CanvasToMatVec(new PVector(mx_, my_)); 
      addPortalFloorGUI(portalFloorNum);

      portalFloorNum++;
    }
  } else if (editMode==3) { //CREATE PILLARS
    draggingPortal = false;
    draggedPortal = 0;
    float xx = CanvasToMatVec(new PVector(mx_, my_)).x;
    float yy = CanvasToMatVec(new PVector(mx_, my_)).y;

    for (int i = 0; i< pillarNum; i++) {
      if (pillar[i].x - pillarSize/2 < xx && pillar[i].x + pillarSize/2 > xx &&
        pillar[i].y - pillarSize/2 < yy && pillar[i].y + pillarSize/2 > yy) {
        draggingPortal = true;
        draggedPortal = i;
      }
    }

    if (!draggingPortal) {
      pillar[pillarNum]= CanvasToMatVec(new PVector(mx_, my_)); 
      println(pillar[pillarNum]);
      //addPortalFloorGUI(portalFloorNum);
      pillarNum++;
    }
  } else if (editMode==4) {//CREATE UNDERGROUND WALL


    PVector mouseVec = CanvasToMatVec(new PVector(mx_, my_));

    draggingWallPoint = false;
    draggedWallPoint = 0;
    int draggingRange = 10;
    for (int i = 0; i < under_wallPointNum; i++) {
      if (dist(mouseVec.x, mouseVec.y, under_wallPoint[i].x, under_wallPoint[i].y)<draggingRange) {
        draggingWallPoint = true;
        draggedWallPoint = i;
      }
    }

    if (!draggingWallPoint) { // add new wall point
      under_wallPoint[under_wallPointNum].set(CanvasToMatVec(new PVector(mx_, my_))); 
      under_wallPointNum++;
    } else {
    }
  }
}

void setupAccordionPortal() {
  accordionPortal = cp5.addAccordion("acc2")
    .setPosition(GUIPosX + GUIBaseWidth, GUIPosY)
    .setWidth(GUIBaseWidth-100)
    .setMinItemHeight(70)
    ;

  for (int i = 0; i< portalWallNum; i++) {
    addPortalWallGUI(i);
  }

  for (int i = 0; i< portalFloorNum; i++) {
    addPortalFloorGUI(i);
  }
}


void clearStageEdit() {
  if (editMode == 0) {
    wallPointNum=0;
    portalWallNum=0;
  } else if (editMode == 1) {
    portalWallNum=0;

    accordionPortal.remove();
    setupAccordionPortal();


    //accordionPortal.setCollapseMode(Accordion.MULTI);
  } else if (editMode == 2) {
    portalFloorNum=0;

    accordionPortal.remove();
    setupAccordionPortal();
  } else if (editMode == 3) {
  } else if (editMode == 4) {
    under_wallPointNum=0;
  }
}

// funcitons for loading and playing a plan.
void loadCSV(){
  selectInput("Select a plan file to process:", "fileSelected");
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    movementPlan = selection.getAbsolutePath();
  }
}

void radioButton(int a) {
  editMode = a;
  //println("radio button = " + a);
}

// ADD GUI //

void addPortalWallGUI(int i) {
  Group portal = cp5.addGroup("PortalWall#" + i)
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(70)
    ;


  cp5.addRadioButton("Wall_AorS_#"+i)
    .setPosition(10, 10)
    .setSize(20, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(2)
    .setSpacingColumn(40)
    .addItem("STATIC_W"+i, 0)
    .addItem("ACTIVE_W"+i, 1)
    .moveTo(portal)
    ;


  // static buttons
  cp5.addSlider("PortalWallWidth#" + i)
    .setPosition(10, 40)
    .setSize(100, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setRange(40, 200)
    .setValue(portalWallBaseWidth)
    .moveTo(portal)
    ;

  // active buttons

  accordionPortal.addItem(portal);
}

void addPortalFloorGUI(int i ) {
  Group portal = cp5.addGroup("PortalFloor#" + i)
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(50)
    ;

  cp5.addRadioButton("Floor_Type_"+i)
    .setPosition(10, 10)
    .setSize(20, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(2)
    .setSpacingColumn(30)
    .addItem("SLOPE"+i, 0)
    .addItem("LIFT"+i, 1)
    .moveTo(portal)
    ;

  cp5.addRadioButton("Floor_AorS_"+i)
    .setPosition(120, 10)
    .setSize(20, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(2)
    .setSpacingColumn(30)
    .addItem("STATIC_F"+i, 0)
    .addItem("ACTIVE_F"+i, 1)
    .moveTo(portal)
    ;

  // static buttons
  cp5.addRadioButton("Floor_Dir_"+i)
    .setPosition(10, 40)
    .setSize(20, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(4)
    .setSpacingColumn(30)
    .addItem("N_"+i, 1)
    .addItem("E_"+i, 2)
    .addItem("S_"+i, 3)
    .addItem("W_"+i, 4)
    .moveTo(portal)
    ;

  // active buttons
  accordionPortal.addItem(portal);
}

void controlEvent(ControlEvent theEvent) {

  if (theEvent.getName().startsWith("Floor_Dir_")) {
    for (int i = 0; i< portalFloorNum; i++) {
      if (theEvent.getName().equals("Floor_Dir_"+i)) {
        portalFloorSlopeDir[i] = int(theEvent.getValue());
        portalFloorSlopeDir[i] = max(portalFloorSlopeDir[i], 0);
      }
    }
  } else if (theEvent.getName().startsWith("Floor_AorS_")) {
    for (int i = 0; i< portalFloorNum; i++) {
      if (theEvent.getName().equals("Floor_AorS_"+i)) {
        portalFloorAS[i] = int(theEvent.getValue());
        portalFloorAS[i] = max(portalFloorAS[i], 0);
      }
    }
  } else if (theEvent.getName().startsWith("Floor_Type_")) {
    for (int i = 0; i< portalFloorNum; i++) {
      if (theEvent.getName().equals("Floor_Type_"+i)) {
        portalFloorType[i] = int(theEvent.getValue());
        portalFloorType[i] = max(portalFloorType[i], 0);
        println("portalFloorType", portalFloorType[i], i);
      }
    }
  } else if (theEvent.getName().startsWith("PortalWallWidth")) {
    for (int i = 0; i< portalWallNum; i++) {
      if (theEvent.getName().equals("PortalWallWidth#"+i)) {
        portalWallWidth[i] = int(theEvent.getValue());

        float a_ = 0;
        a_ = atan2((wallPoint[portalWallatWallNum[portalWallatWallNum[i]]+1].y - wallPoint[portalWallatWallNum[portalWallatWallNum[i]]].y), 
          (wallPoint[portalWallatWallNum[portalWallatWallNum[i]]+1].x - wallPoint[portalWallatWallNum[portalWallatWallNum[i]]].x))+PI/2;

        portalWallEdgeL[i].set(portalWallVec[i].x + cos(a_+radians(90))*portalWallWidth[i]/2, portalWallVec[i].y + sin(a_+radians(90))*portalWallWidth[i]/2);
        portalWallEdgeR[i].set(portalWallVec[i].x + cos(a_+radians(-90))*portalWallWidth[i]/2, portalWallVec[i].y + sin(a_+radians(-90))*portalWallWidth[i]/2);
      }
    }
  } else if (theEvent.getName().startsWith("Wall_AorS_")) {
    for (int i = 0; i< portalFloorNum; i++) {
      if (theEvent.getName().equals("Wall_AorS_"+i)) {
        portalWallAS[i] = int(theEvent.getValue());
        portalWallAS[i] = max(portalFloorAS[i], 0);
      }
    }
  } else if (theEvent.getName().equals("_3DP")) {
    println(int(theEvent.getValue()));
    if (int(theEvent.getValue())==1) { // turned on 3DP

      Group portal = cp5.addGroup("3DP_Coordinate")
        .setBackgroundColor(color(0, 64))
        .setBackgroundHeight(270)
        ;

      _3DP_CoordSlider = cp5.addSlider2D("3DP_coord")
        .setPosition(10, 10)
        .setSize(210, 210)
        .setMinMax(0, 0, stageWidthMax, stageDepthMax)
        .setValue(0, 0)
        .moveTo(portal)
        //.disableCrosshair()
        ;

      cp5.addRadioButton("3DP_Dir")
        .setPosition(10, 240)
        .setSize(20, 20)
        .setColorForeground(color(120))
        .setColorActive(color(255))
        .setColorLabel(color(255))
        .setItemsPerRow(4)
        .setSpacingColumn(20)
        .addItem("N", 1)
        .addItem("E", 2)
        .addItem("S", 3)
        .addItem("W", 4)
        .moveTo(portal)
        ;

      accordionPortal.addItem(portal);
    } else if(int(theEvent.getValue())==0) {
      
      
    }
  } else if (theEvent.getName().equals("3DP_Dir")) {
    _3DPrinterDir = int(theEvent.getValue());
    _3DPrinterDir = max(_3DPrinterDir, 0);
  } else if (theEvent.getName().equals("SAVE")) {
    saveCSV();
    println("SAVE PRESEED");
  } else if (theEvent.getName().equals("filelist")) {

    loadCSV(int(theEvent.getValue()));
  }


  println("Name: " + theEvent.getName(), "Value: " + theEvent.getValue());
  //println(int(theEvent.getValue()));
}
