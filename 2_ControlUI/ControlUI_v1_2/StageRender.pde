// toio mat Unit => 1260mm = 912, 1188mm = 862
//  420mm = 304, 558mm = 410
// 1:0.7238 | 1.3815:1
// toio width: 31.8mm : 23 | height 26mm : 18.8
// UnderStage Height: 103.5mm: 75

boolean _3DP = false;



int stageWidth = 608;
int stageDepth = 430;

static int stageWidthMax = 912;
static int stageDepthMax = 862;

int singleMatWidth = stageWidthMax/3;
int singleMatDepth = stageDepthMax/4;


//Wall and Portal Wall
float entryOffset = 20;

PVector wallPoint[] = new PVector[10];
PVector portalWallVec[] = new PVector[10];
int portalWallatWallNum[] = new int[10];
int portalWallNum = 0;
int portalWallWidth[] = new int[10];
int wallPointNum = 0;

int under_wallPointNum = 0;
PVector under_wallPoint[] = new PVector[10];


int portalWallActivePassive[] = new int[10];


int portalWallBaseWidth = 60;

PVector portalWallFrontPoint[] = new PVector[10];
PVector portalWallBackPoint[] = new PVector[10];

PVector portalWallEdgeL[] = new PVector[10];
PVector portalWallEdgeR[] = new PVector[10];


//UnderStage and Portal Floor
PVector portalFloor[] = new PVector[10];
int portalFloorNum = 0;
int portalFloorSize = 59; //81
int portalFloorType[] = new int[10];
int portalFloorAS[] = new int[10];
int portalFloorSlopeDir[] = new int[10];

int portalFloorActivePassive[] = new int[10];

PVector portalFloorFrontPoint[] = new PVector[10];
PVector portalFloorBackPoint[] = new PVector[10];

float slopeLength = 130;


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

color pillarColor = color (255);

color MainStageColor =  color(200, 230);
color BackStageColor =  color(80);



void setupStageParameter() {

  for (int i = 0; i < 10; i++) {
    wallPoint[i]= new PVector(0, 0);// set(0,0);
    under_wallPoint[i] = new PVector(0, 0);
  }

  textSize(40);
}


void renderStage() {
  pushMatrix();
  rotateX(radians(45));

  //lights();
  if (UnderStage) {
    drawUnderStage();
  }

  pushMatrix();
  translate(-stageWidth/2, -stageDepth/2, 2);

  drawAxis();

  renderToios();

  drawPortalWall();
  drawPortalFloor();

  //3D Printer-base Floor
  draw3DPBase();

  drawWall();

  if (UnderStage) {
    drawUnderWall();
  }

  drawPillar();

  drawDestOrigin();
  
  renderToios();
  popMatrix();
  drawMainStage();
  popMatrix();
}


void drawMainStage() {
  noStroke();
  fill(MainStageColor, 200);

  PShape s = createShape();
  s.beginShape();

  // Exterior part of shape
  s.vertex(-stageWidth/2, -stageDepth/2);
  s.vertex(stageWidth/2, -stageDepth/2);
  s.vertex(stageWidth/2, stageDepth/2);
  s.vertex(-stageWidth/2, stageDepth/2);
  s.vertex(-stageWidth/2, -stageDepth/2);

  // Interior part of shape
  for (int i = 0; i < portalFloorNum; i++) {

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


void drawUnderWall() {
  pushMatrix();
  translate(0, 0, -underStageHeight);
  for (int i = 0; i<under_wallPointNum-1; i++) {
    fill(255, 100);
    noStroke();
    pushMatrix();

    //println(i);
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
  }
}

void drawPortalFloor() {


  noFill();
  rectMode(CENTER);
  for (int i = 0; i< portalFloorNum; i++) {
    stroke(PortalColor);
    noFill();
    rect(portalFloor[i].x, portalFloor[i].y, portalFloorSize, portalFloorSize);

    if (portalFloorSlopeDir[i] != 0) {
      stroke(FrontColor);
      ellipse(portalFloorFrontPoint[i].x, portalFloorFrontPoint[i].y, 10, 10);
    }

    textSize(20);
    fill(200, 100);
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
  int _3DPWidth = 200;
  int _3DPDepth = 200;
  if (_3DP) {
    pushMatrix();
    fill(100, 100, 200, 200);
    rect(_3DPWidth/2, -_3DPDepth/2, _3DPWidth, _3DPDepth);
    popMatrix();
  }
}


void renderToios() {
  
  for (int i = 0; i< numRobot; i++) {
    // println(i, cubes[i].isLost, cubes[i].floor, UnderStage);
    if (!cubes[i].isLost) {
      if (cubes[i].floor == 0) { // ground floor
        drawToio(cubes[i].stageX, cubes[i].stageY, cubes[i].deg);

        if (cubes[i].moveTo) {
          drawTarget(cubes[i].targetx, cubes[i].targety);
          //drawTarget(currentPos[i].x, currentPos[i].y);

          strokeWeight(1);
          stroke(50, 50, 50);
          line(cubes[i].stageX, cubes[i].stageY, 2, cubes[i].targetx, cubes[i].targety, 2);
        }
      } else if (cubes[i].floor == -1) { // under ground floor
        pushMatrix();
        translate(0, 0, -underStageHeight);
        drawToio(cubes[i].stageX, cubes[i].stageY, cubes[i].deg);
        popMatrix();
      } else if (cubes[i].floor == 2 && UnderStage) { // On Slope
        pushMatrix();

        // int slopePosX[]; int slopePosY[];
        // int slopeDir[];
        // int cubes[i].portalID

        int pID = cubes[i].portalID;


        if ( -1 < pID && pID < slopeNum) {
          //println(pID);
          translate(portalFloor[pID].x, portalFloor[pID].y);

          rotateZ((portalFloorSlopeDir[pID]-1)*PI/2);

          translate(-portalFloorSize/2, -portalFloorSize/2);

          float as = atan2(-underStageHeight, slopeLength + portalFloorSize/2);
          rotateX(as);
          translate(cubes[i].stageX, cubes[i].stageY);

          drawToio(0, 0, cubes[i].deg);
        }


        popMatrix();
      }
    }
  }
}

void drawToio(float x, float y, float deg) {
  pushMatrix();
  stroke(200);
  strokeWeight(1);

  fill(255);
  translate(x, y, 10);
  rotate(radians(deg));
  box(toioSize, toioSize, 20);
  stroke(255, 0, 0);
  strokeWeight(2);
 // line(toioSize/2, 0, 10, toioSize/2+5, 0, 10);
  popMatrix();
}

void drawTarget(float x, float y) {
  pushMatrix();
  stroke(0);
  strokeWeight(1);
  fill(255, 0, 0);

  translate(x, y, 2);
  ellipse(0, 0, 7, 7);
  popMatrix();
}

void drawDestOrigin() {
  for (int i = 0; i < numRobot; i++) {
    // draw target points / Destinations
    //pushMatrix();
    //translate(cubes[i].targetx, cubes[i].targety);
    //noFill();
    //stroke(255, 100, 100);
    //strokeWeight(2);
    //line(-5, -5, 5, 5);
    //line(5, -5, -5, 5);
    //// ellipse(0, 0, 10, 10);

    //fill(255, 100, 100);
    //textSize(20);
    //text("Dest", 2, -25);
    //text("#"+i, 2, -10);
    //noFill();

    //popMatrix();
    
    drawODonStage((int)cubes[i].targetx, (int)cubes[i].targety, destColor, i, "Dest");


    //draw current Position / Origin.
    if (currentPos[i] != null) {
      drawODonStage((int)currentPos[i].x, (int)currentPos[i].y, origColor, i, "Orig");
      
      //pushMatrix();

      //translate(currentPos[i].x, currentPos[i].y);
      //noFill();
      //stroke(100, 255, 255);
      //strokeWeight(2);
      //line(-5, -5, 5, 5);
      //line(5, -5, -5, 5);

      //fill(100, 255, 255);
      //textSize(20);
      //text("Orig", 2, -25);
      //text("#"+i, 2, -10);
      //noFill();

      //popMatrix();
    }
  }
}


void drawODonStage(int x, int y, color c, int id, String tag) {



  stroke(c);
  fill(c);
  //first check if the toio is on slope, elevator, 3DP
  boolean flag = false;

  int portalID = 0;
  int floor = 0;
  int stageX = 0, stageY = 0;

  if (slopeNum>0 && UnderStage) {
    for (int i = 0; i<slopeNum; i++) {
      // singleMatWidth / singleMatDepth
      // slopeMatOriginX, slopeMatOriginY


      //println(i, x, y);
      if (slopeMatOriginX +  i* (singleMatWidth/6) < x && x< slopeMatOriginX +  (i+1)* (singleMatWidth/6) && slopeMatOriginY < y) {
        portalID = i;

        floor = 2;

        stageX = x - (slopeMatOriginX +  i* (singleMatWidth/6));
        stageY = y - slopeMatOriginY;
        println(i, stageX, stageY);

        flag = true;
      }
    }
  } else if (elevNum>0 && UnderStage) {
    floor = 3;
  } else if (_3DP) {
  }
  if (flag == false) {
    if (x < stageWidth && y < stageDepth) {
      floor = 0;
      stageX = x;
      stageY = y;
    } else if (UnderStage && x < stageWidth && (stageDepth <= y & y < stageDepth*2)) {
      floor = -1;
      stageX = x;
      stageY = y - stageDepth;
    }
  }

  if (floor == 0) { // ground floor
    drawCross(stageX, stageY, id, tag);
  } else if (floor == -1) { // under ground floor
    pushMatrix();
    translate(0, 0, -underStageHeight);
    drawCross(stageX, stageY, id, tag);
    popMatrix();
  } else if (floor == 2 && UnderStage) { // On Slope
    pushMatrix();

    if ( -1 < portalID && portalID < slopeNum) {
      //println(pID);
      translate(portalFloor[portalID].x, portalFloor[portalID].y);

      rotateZ((portalFloorSlopeDir[portalID]-1)*PI/2);

      translate(-portalFloorSize/2, -portalFloorSize/2, 1);

      float as = atan2(-underStageHeight, slopeLength + portalFloorSize/2);
      rotateX(as);
      drawCross(stageX, stageY, id, tag);
    }


    popMatrix();
  }
}

void drawCross(int x, int y, int id, String tag) {
  pushMatrix();
  translate(x,y);
  line(-5, -5, 5, 5);
  line(5, -5, -5, 5);
  textSize(20);
  text(tag, 2, -25);
  text("#"+id, 2, -10);
  popMatrix();
}
