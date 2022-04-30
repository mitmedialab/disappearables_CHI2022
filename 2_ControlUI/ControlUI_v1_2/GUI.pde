import controlP5.*;
ControlP5 cp5;
import java.util.*;
import java.io.InputStreamReader;
import java.nio.file.Path;
import java.nio.file.Paths;

Accordion accordionMain;
Canvas toioInputCanvas;
float inputCanvasScale = 0.55;

RadioButton r1;
Bang b;

Canvas stageCanvas;
boolean disableInputCanvas = false;

List fileList;
ScrollableList files;

//int canvasWidth = 320;
//int canvasHeight = 300;

int canvasWidth = (int)(stageWidthMax * inputCanvasScale);
int canvasHeight = (int)(stageDepthMax *inputCanvasScale);

String movementPlan = "";
Textlabel planLabel;
Textlabel currTimeLabel;
int currTime = 0;

int GUIBaseWidth = 600;
int GUIPosX = 10;
int GUIPosY = 10;


//boolean draggingPortal = false;
//int draggedPortal = 0;

//boolean draggingWallPoint = false;
//int draggedWallPoint = 0;

boolean draggingOriginDest = false;
String draggedOriginorDest = "Origin";
int draggedOriginDest = 0;


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

  Group g4 = cp5.addGroup("PlanPlay")
    .setBackgroundColor(color(0, 64))
    .setBackgroundHeight(160)
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

  r1 = cp5.addRadioButton("radioButton")
    .setPosition(canvasWidth+30, 20)
    .setSize(20, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(1)
    .setSpacingRow(10)
    .addItem("Orig", 1)
    .addItem("Dest", 2)
    .activate(0)
    .moveTo(g2)
    ;

  b = cp5.addBang("bang")
    .setPosition(canvasWidth+30, 120)
    .setSize(40, 20)
    .setTriggerEvent(Bang.RELEASE)
    .setLabel("SAVE_ODDATA")
    .moveTo(g2)
    ;



  stageCanvas = new MyStageCanvas();
  //stageCanvas.pre(); // use
  stageCanvas.post(); //to draw on top of existing controllers.
  g3.addCanvas(stageCanvas);


  // g4 components 
  //stageLabel = cp5.addTextlabel("stage","Stage:",100,150).setPosition(0, 50).moveTo(g4);
  planLabel = cp5.addTextlabel("plan","Plan:",100,150).setPosition(20, 140).moveTo(g4);
  currTimeLabel = cp5.addTextlabel("time","Timestep:",100,150).setPosition(20, 90).moveTo(g4);
  
  //cp5.addBang("LOAD STAGE TO PLAN")
  //  .setPosition(0, 0)
  //  .setSize(80, 20)
  //  .moveTo(g4)
  //  .plugTo(this, "loadStage");
  //;  
    
  cp5.addBang("LOAD PLAN")
    .setPosition(20, 20)
    .setSize(80, 20)
    .moveTo(g4)
    .plugTo(this, "loadPlan");
  ;
  
  cp5.addBang("PLAN PATHS")
    .setPosition(110, 20)
    .setSize(80, 20)
    .moveTo(g4)
    .plugTo(this, "planPath");
    ;
  ;  
  
  cp5.addBang("LOAD PATHS")
    .setPosition(200, 20)
    .setSize(80, 20)
    .moveTo(g4)
    .plugTo(this, "loadPath");
    ;
  ;  
  
  cp5.addBang("SHOW/HIDE TOIOS")
    .setPosition(290, 20)
    .setSize(80, 20)
    .moveTo(g4)
    .plugTo(this, "triggerCube");
    ;
  ; 
  
  cp5.addBang("SHOW ANIMATION")
    .setPosition(380, 20)
    .setSize(80, 20)
    .moveTo(g4)
    .plugTo(this, "threadShowPaths");
    ;
  ;  
  
  cp5.addBang("NEXT STEP")
    .setPosition(110, 80)
    .setSize(80, 20)
    .moveTo(g4)
    .plugTo(this, "nextStep");
    ;
  ; 
  
  cp5.addBang("PREV STEP")
    .setPosition(200, 80)
    .setSize(80, 20)
    .moveTo(g4)
    .plugTo(this, "prevStep");
    ;
  ; 
  
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

  accordionMain.open(0, 1,3);

  // use Accordion.MULTI to allow multiple group
  // to be open at a time.
  accordionMain.setCollapseMode(Accordion.MULTI);
  
}

// funcitons for loading and playing a plan.
void loadPlan(){
  selectInput("Select a plan file to process:", "planSelected");
}

void nextStep(){
  currTime += 1;
  drawToioCurrConfig(currTime);
  currTimeLabel.setText("Timestep:"+currTime);
}



void prevStep(){
  currTime -= 1;
  drawToioCurrConfig(currTime);
  currTimeLabel.setText("Timestep:"+currTime);
}

void planSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    movementPlan = selection.getAbsolutePath();
    planLabel.setText("Plan:"+movementPlan);
    loadODPosCSV();
  }
}

void planPath(){
  saveODPosCSV(sketchPath("")+"CBS_planner/current_agent.csv");
  
  try{
    Process p = Runtime.getRuntime().exec(sketchPath("")+"CBS_planner/planner",null, new File(sketchPath("")+"CBS_planner/"));
    p.waitFor();
    BufferedReader reader=new BufferedReader( new InputStreamReader(p.getInputStream()));
    String s; 
    while ((s = reader.readLine()) != null){
        System.out.println(s);
    } 
    println("Finished Planning!");
  }catch(Exception e){print(e);}
}

void loadPath(){
  loadPaths();
  currTime = 0; 
  //renderToios();
  drawToioCurrConfig(currTime);
  currTimeLabel.setText("Timestep:"+currTime);
}

void triggerCube(){
  for (int i = 0; i< nCubes; i++){cubes[i].isLost=!cubes[i].isLost;}
}


void threadShowPaths(){
  thread("showContinuousPath");
}

void showContinuousPath(){
  
  // set all toios to start locations.
  for(int i = 0; i< nCubes; i++){
    int floorValue = (int)loadedPaths.get(i).get(0).z;
    int xValue = (int)loadedPaths.get(i).get(0).x;
    int yValue = (int)loadedPaths.get(i).get(0).y;
    if(floorValue == -1){
      yValue += stageDepth;
    }
    
    cubes[i].x = xValue;
    cubes[i].y = yValue;    
    cubes[i].floor = floorValue;
  }
  
  for(int ts=1; ts<=maxTime; ts++){
    //println(ts, maxTime);
    
    Vector<PVector> nextLocations = new Vector<PVector>();
    
    for(int i = 0; i< nCubes; i++){
      if(ts>=loadedPaths.get(i).size()){
        nextLocations.add(loadedPaths.get(i).lastElement());
      }
      else{
        nextLocations.add(loadedPaths.get(i).get(ts));
      }
    }
    
    boolean reachNextLocations = false;
    while(!reachNextLocations){
      
      reachNextLocations = true;
      for(int i=0; i<nCubes; i++){
        PVector nextLoc = nextLocations.get(i);
       
        //println(nextLoc, cubes[i].x, cubes[i].y, cubes[i].floor);
        if(cubes[i].floor!=nextLoc.z){
          cubes[i].floor = (int)nextLoc.z;
          cubes[i].x = (int)nextLoc.x;
          cubes[i].y = (int)nextLoc.y;
          if(nextLoc.z == -1){
            cubes[i].y += stageDepth;
            
          }
          
          continue;
        }
        
        int nextLocY = (int)nextLoc.y;
        if(nextLoc.z == -1){
          nextLocY += stageDepth;
        }

        
        if(cubes[i].x < nextLoc.x){
          cubes[i].x+=1;
          continue;
        }
        else if(cubes[i].x > nextLoc.x){
          cubes[i].x-=1;
          continue;
        }
        else if(cubes[i].y < nextLocY){
          cubes[i].y+=1;
          continue;
        }
        else if(cubes[i].y > nextLocY){
          cubes[i].y-=1;
          continue;
        }
        
      }
      
      for(int i=0; i<nCubes; i++){
        PVector nextLoc = nextLocations.get(i);
        
        int nextLocY = (int)nextLoc.y;
        if(nextLoc.z == -1){
          nextLocY += stageDepth;
        }
        
        if(cubes[i].floor != nextLoc.z || cubes[i].x != nextLoc.x || cubes[i].y != nextLocY){
          reachNextLocations = false;
          continue;
        }
      }

      delay(10); // animation speed.
    }
    
  }
}

// draw the configurations of toios given a timestep.
void drawToioCurrConfig(int ts){
  
  for (int i = 0; i< nCubes; i++){
    
    if(ts>=loadedPaths.get(i).size()){
      int floorValue = (int)loadedPaths.get(i).lastElement().z;
      int xValue = (int)loadedPaths.get(i).lastElement().x;
      int yValue = (int)loadedPaths.get(i).lastElement().y;
      if(floorValue == -1){
        yValue += stageDepth;
      }
      
      cubes[i].x = xValue;
      cubes[i].y = yValue;
      cubes[i].floor = floorValue;
    }
    else{
      int floorValue = (int)loadedPaths.get(i).get(ts).z;
      int xValue = (int)loadedPaths.get(i).get(ts).x;
      int yValue = (int)loadedPaths.get(i).get(ts).y;
      if(floorValue == -1){
        yValue += stageDepth;
      }
      
      cubes[i].x = xValue;
      cubes[i].y = yValue;    
      cubes[i].floor = floorValue;
    }
    //println(i,cubes[i].x,cubes[i].y,cubes[i].floor);
  }
  
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
    if (!disableInputCanvas) {
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

  if ( (0 <= xx && xx < stageWidthMax) &&  (0 <= yy && yy < stageDepthMax)) {
    mx_ = xx;
    my_ = yy;
    onCanvas = true;
  } else {
    onCanvas = false;
  }
}


void mousePressedOnCanvas() {

  //set target point based on key number
  //if (keyPressed) {
  //  //println("HEY", char(key), int(char(key)), int(char(1)));
  //  for (int i = 0; i< nCubes; i++) {
  //    if (int(key) == i + 48) {
  //      cubes[i].targetx = mx_/inputCanvasScale;
  //      cubes[i].targety = my_/inputCanvasScale;

  //    //  println("yes", cubes[i].targetx, cubes[i].targety, i);
  //    }
  //  }
  //}



  float xx = CanvasToMatVec(new PVector(mx_, my_)).x ;
  float yy = CanvasToMatVec(new PVector(mx_, my_)).y ;

  // println(mx_, my_,xx, yy, cubes[0].targetx, cubes[0].targety);
  int offsetDrag = 10;
  for (int i = 0; i< cubes.length; i++) {
    if (selectODMode == "Destination") {
      if (cubes[i].targetx - offsetDrag < xx && cubes[i].targetx + offsetDrag > xx &&
        cubes[i].targety - offsetDrag < yy && cubes[i].targety + offsetDrag > yy) {
        draggingOriginDest = true;
        draggedOriginorDest = "Destination";
        draggedOriginDest = i;

        //  println("dragging Dest");
      }
    } else if (selectODMode == "Origin") {

      if (currentPos[i].x - offsetDrag < xx && currentPos[i].x + offsetDrag > xx &&
        currentPos[i].y - offsetDrag < yy && currentPos[i].y + offsetDrag > yy) {
        draggingOriginDest = true;
        draggedOriginorDest = "Origin";
        draggedOriginDest = i;
      }
    }
  }
}



void controlEvent(ControlEvent theEvent) {

  if (theEvent.getName().equals("filelist")) {

    loadStageCSV(int(theEvent.getValue()));
    currentFileNum = int(theEvent.getValue());
  }

  if (theEvent.isFrom(r1)) {
    if (theEvent.getValue()==1) {
      selectODMode = "Origin";
    } else if (theEvent.getValue()==2) {
      selectODMode = "Destination";
    };
    //println(selectODMode);
  }

  if (theEvent.getController().getName().equals("bang")) {
    saveODPosCSV("data/csv/ODPoint_" + filenames[currentFileNum] + ".csv");
  }
}
