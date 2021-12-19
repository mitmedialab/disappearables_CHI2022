// toio mat Unit => 1260mm = 912, 1188mm = 862
//  420mm = 304, 558mm = 410
// 1:0.7238 | 1.3815:1
// toio width: 31.8mm : 23 | height 26mm : 18.8
// UnderStage Height: 103.5mm: 75


int stageWidthMax = 912;
int stageDepthMax = 862;

// Size of Stage Width, Stage Depth
int stageWidth = 0;
int stageDepth = 0;


// if 3D printer Exhists 
boolean _3DP = false; 

int _3DPrinterPosX = 0;
int _3DPrinterPosY = 0;
int _3DPrinterDir = 1;


//Wall and Portal Wall
float entryOffset = 20; //

PVector wallPoint[] = new PVector[10];
PVector portalWallVec[] = new PVector[10];
int portalWallatWallNum[] = new int[10];
int portalWallNum = 0;
int portalWallWidth[] = new int[10];
int wallPointNum = 0;

int portalWallAS[] = new int[10];

int portalWallBaseWidth = 60;

PVector portalWallFrontPoint[] = new PVector[10];
PVector portalWallBackPoint[] = new PVector[10];

PVector portalWallEdgeL[] = new PVector[10];
PVector portalWallEdgeR[] = new PVector[10];



//UnderStage and Portal Floor
PVector portalFloor[] = new PVector[10];
int portalFloorNum = 0;
int portalFloorSize = 59; // = 81mm
int portalFloorSlopeDir[] = new int[10];

int portalFloorType[] = new int[10]; //0: slope / 1: lift
int portalFloorAS[] = new int[10];

PVector portalFloorFrontPoint[] = new PVector[10];
PVector portalFloorBackPoint[] = new PVector[10];

float slopeLength = 130;

//UnderStage Wall 

PVector under_wallPoint[] = new PVector[10];
int under_wallPointNum = 0;


//Pillar
int pillarNum = 0;
PVector pillar[] = new PVector[50];
int pillarSize = int(25 * 1.3815);

boolean UnderStage = false;
int underStageHeight = 75; //103.5mm

//Color
color PortalColor =  color(100, 100, 200);
color BackColor =  color(100, 200, 100);
color FrontColor =  color(200, 100, 100);

color EdgeColor =  color(100, 200, 200);

color pillarColor = color (255);

color MainStageColor =  color(200, 230);
color BackStageColor =  color(80);


void setupStageParameter() {

  for (int i = 0; i < 10; i++) {
    wallPoint[i]= new PVector(0, 0);// set(0,0);
    under_wallPoint[i]= new PVector(0, 0);// set(0,0);
  }

  textSize(40);
}
//PVector wallEnd= new PVector(0, 0);

void updateStageParameters() {
  stageWidth = (int)stageSizeSlider.getArrayValue()[0];
  stageDepth = (int)stageSizeSlider.getArrayValue()[1];

  if (_3DP) {
    _3DPrinterPosX = (int)_3DP_CoordSlider.getArrayValue()[0];
    _3DPrinterPosY = (int)_3DP_CoordSlider.getArrayValue()[1];
  }


  if (key== 's' ) { //SNAP to mat 
    int matWidth = stageWidthMax/3;
    for (int i = 1; i < 4; i++) {
      if (stageWidth > matWidth * (i-0.5) &&  stageWidth < matWidth * (i+0.5)) {
        stageWidth = matWidth * i;
      }
    }


    int matDepth = stageDepthMax/4;
    for (int i = 1; i < 5; i++) {
      if (stageDepth > matDepth * (i-0.5) &&  stageDepth < matDepth * (i+0.5)) {
        stageDepth = matDepth * i;
      }
    }

    stageSizeSlider.setValue(stageWidth, stageDepth);
  }


  for (int i = 0; i< portalFloorNum; i++) {

    updateFloorPortalPoints(i);
  }
}

void updateFloorPortalPoints(int i) {
  if (portalFloorSlopeDir[i] == 0) {
    portalFloorFrontPoint[i] = new PVector (0, 0);
    portalFloorBackPoint[i] = new PVector (0, 0);
  } else {
    float theta = (portalFloorSlopeDir[i]-2)*PI/2 ;

    float x1 = portalFloor[i].x + cos(theta)*(portalFloorSize/2 + entryOffset);
    float y1 = portalFloor[i].y + sin(theta)*(portalFloorSize/2 + entryOffset);

    float x2 = portalFloor[i].x + cos(theta+PI)*(entryOffset + slopeLength);
    float y2 = portalFloor[i].y + sin(theta+PI)*(entryOffset + slopeLength);

    portalFloorFrontPoint[i] = new PVector (x1, y1);
    portalFloorBackPoint[i] = new PVector (x2, y2);
  }
}

void renderStage() {
  pushMatrix();
  rotateX(radians(45));

  //lights();
  if (UnderStage) {
    drawUnderStage();
  }

  drawMainStage();

  pushMatrix();
  translate(-stageWidth/2, -stageDepth/2, 2);

  drawAxis();

  ////Render toio////
  renderToio(50, 40, 32);

  drawPortalWall();
  drawPortalFloor();

  //3D Printer-base Floor
  draw3DPBase();


  drawWall();
  
  if (UnderStage) {
    drawUnderWall();
  }
  
  //rawUnderWall();

  drawPillar();

  popMatrix();

  popMatrix();
}


void drawMainStage() {
  noStroke();
  fill(MainStageColor);

  PShape s = createShape();
  s.beginShape();

  // Exterior part of shape
  s.vertex(-stageWidth/2, -stageDepth/2);
  s.vertex(stageWidth/2, -stageDepth/2);
  s.vertex(stageWidth/2, stageDepth/2);
  s.vertex(-stageWidth/2, stageDepth/2);
  s.vertex(-stageWidth/2, -stageDepth/2);

  // Interior part of shape
  for (int i =0; i < portalFloorNum; i++) {
    float x_ = portalFloor[i].x -stageWidth/2;
    float y_ = portalFloor[i].y -stageDepth/2;

    s.beginContour();
    s.vertex(x_-portalFloorSize/2, y_-portalFloorSize/2);
    s.vertex(x_-portalFloorSize/2, y_+portalFloorSize/2);
    s.vertex(x_+portalFloorSize/2, y_+portalFloorSize/2);
    s.vertex(x_+portalFloorSize/2, y_-portalFloorSize/2);
    s.endContour();
  }

  // Finishing off shape
  s.endShape();

  shape(s);

  pushMatrix();
  translate(-stageWidth/2, -stageDepth/2, 2);
  stroke(255, 30);
  for (int i = 0; i < 3; i++) {
    line(stageWidthMax/3 * (i+1), 0, stageWidthMax/3 * (i+1), stageDepthMax);
  }
  for (int i = 0; i < 4; i++) {
    line(stageWidthMax, stageDepthMax/4 * (i+1), 0, stageDepthMax/4 * (i+1));
  }

  fill(255, 20);

  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 4; j++) {
      int matID = 1 + (j) + i*4;
      text("#" + matID, stageWidthMax/3 * (i), stageDepthMax/4 * (j)+50);
    }
  }


  popMatrix();
}

void drawWall() {
  for (int i = 0; i<wallPointNum-1; i++) {
    fill(255, 180);
    noStroke();
    pushMatrix();


    beginShape();
    vertex(wallPoint[i].x, wallPoint[i].y, 0);


    for (int j=0; j < portalWallNum; j++) {
      boolean flip = false;
      if (portalWallatWallNum[j] == i) {//which wall is the portal on?

        PVector ddp = new PVector(0, 0);

        float dist = dist(wallPoint[i].x, wallPoint[i].y, wallPoint[i+1].x, wallPoint[i+1].y);
        for (int k = 0; k < dist; k++) {
          float xx = map(k, 0, dist, wallPoint[i].x, wallPoint[i+1].x);
          float yy = map(k, 0, dist, wallPoint[i].y, wallPoint[i+1].y);

          float dd = dist(xx, yy, portalWallVec[j].x, portalWallVec[j].y);
          float dddd = dist(ddp.x, ddp.y, xx, yy);//

          if (int(dd) - (portalWallWidth[j]/2) < 2   && !flip && dddd > portalWallWidth[j]-1) {
            vertex(xx, yy, 0);
            vertex(xx, yy, 60);
            ddp = new PVector(xx, yy);
            flip = !flip;
          } else if (int(dd) - (portalWallWidth[j]/2) < 2  && flip && dddd > portalWallWidth[j]-1) {
            vertex(xx, yy, 60);
            vertex(xx, yy, 0);
            ddp = new PVector(xx, yy);
            flip = !flip;
          }
        }
      }
    }

    vertex(wallPoint[i+1].x, wallPoint[i+1].y, 0);

    vertex(wallPoint[i+1].x, wallPoint[i+1].y, 200);
    vertex(wallPoint[i].x, wallPoint[i].y, 200);
    endShape(CLOSE);

    popMatrix();
  }
}

void drawPortalWall() {
  noFill();
  ellipseMode(CENTER);
  for (int i = 0; i< portalWallNum; i++) {
    stroke(PortalColor);
    ellipse(portalWallVec[i].x, portalWallVec[i].y, 30, 30);

    stroke(FrontColor);
    ellipse(portalWallFrontPoint[i].x, portalWallFrontPoint[i].y, 10, 10);

    stroke(BackColor);
    ellipse(portalWallBackPoint[i].x, portalWallBackPoint[i].y, 10, 10);


    stroke(EdgeColor);
    ellipse(portalWallEdgeL[i].x, portalWallEdgeL[i].y, 10, 10);
    ellipse(portalWallEdgeR[i].x, portalWallEdgeR[i].y, 10, 10);
  }
}

void drawPortalFloor() {


  noFill();
  rectMode(CENTER);
  for (int i = 0; i< portalFloorNum; i++) {
    stroke(PortalColor);
    noFill();
    rect(portalFloor[i].x, portalFloor[i].y, portalFloorSize, portalFloorSize);

    if (portalFloorSlopeDir[i] != 0) { //
      stroke(FrontColor);
      ellipse(portalFloorFrontPoint[i].x, portalFloorFrontPoint[i].y, 10, 10);
    }
    
    textSize(20);
    fill(200,100);
    textAlign(CENTER);
    text("P" + i, portalFloor[i].x, portalFloor[i].y);
    textAlign(LEFT);

    if (UnderStage) {
      stroke(PortalColor, 100);
      pushMatrix();
      translate(0, 0, -underStageHeight); 
      rect(portalFloor[i].x, portalFloor[i].y, portalFloorSize, portalFloorSize);

      if (portalFloorSlopeDir[i] != 0) {
        stroke(BackColor);
        ellipse(portalFloorBackPoint[i].x, portalFloorBackPoint[i].y, 10, 10);
        println(i, portalFloorBackPoint[i].x, portalFloorBackPoint[i].y);
      }
      popMatrix();
    }


    if (portalFloorSlopeDir[i] != 0) {
      pushMatrix();
      translate(portalFloor[i].x, portalFloor[i].y);
      //draw slope
      noStroke();
      fill((BackStageColor+MainStageColor)/2);
      rotateZ((portalFloorSlopeDir[i]-1)*PI/2);


      if (portalFloorType[i] == 0) { // slope?

        PShape s = createShape();
        s.beginShape();
        // Exterior part of shape
        s.vertex(-portalFloorSize/2, -portalFloorSize/2, 0);
        s.vertex(-portalFloorSize/2, slopeLength, -underStageHeight);
        s.vertex(portalFloorSize/2, slopeLength, -underStageHeight);
        s.vertex(portalFloorSize/2, -portalFloorSize/2, 0);
        s.vertex(-portalFloorSize/2, -portalFloorSize/2, 0);
        s.endShape();

        shape(s);
      } else { // Lift

        PShape ss = createShape();
        ss.beginShape();
        // Exterior part of shape
        ss.vertex(-portalFloorSize/2, portalFloorSize/2, -underStageHeight + 20);
        ss.vertex(-portalFloorSize/2, slopeLength, -underStageHeight);
        ss.vertex(portalFloorSize/2, slopeLength, -underStageHeight);
        ss.vertex(portalFloorSize/2, portalFloorSize/2, -underStageHeight + 20);
        ss.vertex(-portalFloorSize/2, portalFloorSize/2, -underStageHeight + 20);
        ss.endShape();
        shape(ss);

        fill(MainStageColor);
        PShape s = createShape();
        s.beginShape();
        // Exterior part of shape
        s.vertex(-portalFloorSize/2, -portalFloorSize/2, -underStageHeight + 20);
        s.vertex(-portalFloorSize/2, portalFloorSize/2, -underStageHeight + 20);
        s.vertex(portalFloorSize/2, portalFloorSize/2, -underStageHeight + 20);
        s.vertex(portalFloorSize/2, -portalFloorSize/2, -underStageHeight + 20);
        s.vertex(-portalFloorSize/2, -portalFloorSize/2, -underStageHeight + 20);
        s.endShape();

        shape(s);
      }


      popMatrix();
    }
  }
}

void drawAxis() {
  strokeWeight(2);
  stroke(255, 0, 0);
  line(0, 0, 0, 1000, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 1000, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 1000);
}

void drawUnderStage() {

  noStroke();
  pushMatrix();
  translate(0, 0, -underStageHeight);
  fill(BackStageColor);
  rect(0, 0, stageWidth, stageDepth);
  
  popMatrix();
  
}


void drawUnderWall() {
  pushMatrix();
  translate(0, 0, -underStageHeight);
  for (int i = 0; i<under_wallPointNum-1; i++) {
    fill(255, 100);
    noStroke();
    pushMatrix();


    beginShape();
    vertex(under_wallPoint[i].x, under_wallPoint[i].y, 0);
    vertex(under_wallPoint[i+1].x, under_wallPoint[i+1].y, 0);

    vertex(under_wallPoint[i+1].x, under_wallPoint[i+1].y, 10);
    vertex(under_wallPoint[i].x, under_wallPoint[i].y, 10);
    endShape(CLOSE);

    popMatrix();
  }
  popMatrix();
}

void drawPillar() {
  pushMatrix();
  translate(0, 0, -underStageHeight/2-4);
  fill(pillarColor);
  noStroke();
  for (int i = 0; i< pillarNum; i++) {
    pushMatrix();
    translate(pillar[i].x, pillar[i].y);
    box(pillarSize, pillarSize, underStageHeight);
    popMatrix();
  }
  popMatrix();
}


void draw3DPBase() {
  int _3DPWidth = bedWidth;
  int _3DPDepth = bedDepth;
  if (_3DP) {
    pushMatrix();
    translate(_3DPrinterPosX,_3DPrinterPosY);
    noStroke();
    fill(150, 150, 200, 200);

    //rect(bedslopeWidth/2, -bedslopeDepth/2, bedslopeWidth, bedslopeDepth);


    rotateZ((_3DPrinterDir-1)*PI/2);



    PShape s = createShape();
    s.beginShape();
    // Exterior part of shape
    s.vertex(-bedslopeWidth/2, 0, 0);
    s.vertex(-bedslopeWidth/2, -bedslopeDepth, _3DPrintHeight);
    s.vertex(bedslopeWidth/2, -bedslopeDepth, _3DPrintHeight);
    s.vertex(bedslopeWidth/2, 0, 0);
    s.vertex(-bedslopeWidth/2, 0, 0);
    s.endShape();

    shape(s);

    translate(0, -bedslopeDepth, _3DPrintHeight);
    //rect(_3DPWidth/2, -_3DPDepth/2, _3DPWidth, _3DPDepth);
    rect(0, -_3DPDepth/2, _3DPWidth, _3DPDepth);

    popMatrix();
  }
}

void renderToio(int x, float y, float deg) {
  pushMatrix();
  stroke(200);
  strokeWeight(1);

  fill(255);
  translate(x, y, 10);
  rotate(radians(deg));
  box(23, 23, 19);
  stroke(255, 0, 0);
  strokeWeight(2);
  line(13, 0, 10, 5, 0, 10);
  popMatrix();
}
