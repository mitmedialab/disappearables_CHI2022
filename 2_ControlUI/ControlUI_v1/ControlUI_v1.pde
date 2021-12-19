import peasy.PeasyCam;
PeasyCam cam;

int appFrameRate = 60;

boolean serialEnable =false;

int maxMotorSpeed = 115;

int toneTest = 0;
int toneLength = 10;

int controlCubeSwitching = 0;

void setup() {
  size(1900, 1050, P3D);
  //fullScreen(P3D);
  blendMode(BLEND);
  noStroke();
  smooth();

  cam = new PeasyCam(this, 400);
  cam.setDistance(800);

  setupStageParameter();
  setupCSV();

  gui();


  setupOsc();
  setupCube();

  frameRate(appFrameRate);
  textSize(10);

  if (serialEnable)
    serialSetup();

  joyStickSetup();

  if (pongEnable) {
    pongSetup();
  }
}


void draw() {
  serverReceive();
  

  for (int i = 0; i < nCubes; i++) {
    cubes[i].setStageCoordinate();
  }
  
  
 //// //test data
 // cubes[0].x = slopeMatOriginX +30;
 // cubes[0].y = slopeMatOriginY +100;
 //// cubes[0].floor= 2;
 // cubes[0].isLost = false;
  
  
 // cubes[1].x = slopeMatOriginX +210;
 // cubes[1].y = slopeMatOriginY +30;
 //// cubes[1].floor= 2;
 // cubes[1].isLost = false;

  if (keyPressed && key == ' ') {
    cam.setMouseControlled(true);
  } else {
    cam.setMouseControlled(false);
  }  

  background(20);

  renderStage();

  getMouseforCanvas();
  cam.beginHUD();
  cp5.draw();

  if (pongEnable) {

    playPong();
    pongDraw();
  }

  cam.endHUD();


  serverSend();


  if (controlEnable) {
    for (int i = 0; i < nCubes; i++) {
      moveTo(i, (int)cubes[i].targetx, (int)cubes[i].targety, 35, 10);
    }
  }
}


void keyPressed() {

  if (key == 's') {
    saveTargetPosCSV();
  } else if (key =='c') {
    loadControlCSV("plan_4x6output.csv");
    controlEnable = true;
    currentTimeStamp=0;
    currentRow = 0;
    addFrame();
  } else if (key =='d') {
    loadControlCSV("plan_4x6output.csv");
    controlEnable = true;
    currentRow = controlRowNum-1;
    currentTimeStamp = maxTimeStamp;
    setTargetFromEnd() ;
    reduceFrame();
  }

  if (keyCode == DOWN) {
    reduceFrame();
  } else if (keyCode == UP) {
    addFrame();
  } else if (keyCode == LEFT) {
    motorControl(0, -100, 100, 50);
  } else if (keyCode == RIGHT) {
    motorControl(0, 100, -100, 50);
  }

  if (key == 't') {
    saveTargetPosCSVManual();
  } 

  if (key == 'r') {
    controlEnable = false;

    for (int i = 0; i < nCubes; i++){
      pose(i);
      rotateTo(i, 90, 20, 10);
    }
  } 

  //if (key =='p') {
  //  pongEnable = true;

  //  startedTime = millis();
  //}
  //else if (key == ' ') {
  //  pongPause = !pongPause;

  //  startedTime = millis();
  //  movie.jump(0);
  //} else if (key == 'r') {
  //  currentFrame = 0;
  //  startedVideo = false;
  //}

  switch(key) {
  case '4': // move one pin up
    playSound(controlCubeSwitching, 47, 255, 10); //Move Pin Up

    break;
  case '5': // move one pin down
    playSound(controlCubeSwitching, 58, 255, 10); //Move Pin Down
    break;

  case '6':  // move all pins up
    for (int i = 0; i < nCubes; i++) {
      playSound(i, 47, 255, 10); //Move Pin Up
    }

    break;
  case '7':  // move all pins down
    for (int i = 0; i < nCubes; i++) {
      playSound(i, 58, 255, 10); //Move Pin Up
    }
    break;

  case 'z':
    controlCubeSwitching++;
    if (controlCubeSwitching==nCubes) {
      controlCubeSwitching = 0;
    }
    break;
  case 'l':
    // loads the saved layout
    ks.load("keystone2.xml");
    break;
  case 'k':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;
  case 'j':
    // saves the layout
    ks.save("keystone2.xml");
    break;
  }
}

void mousePressed() {

  if (onCanvas) {
    mousePressedOnCanvas();
  }
}

void mouseDragged() {
  if (draggingPortal) {
    portalFloor[draggedPortal] = CanvasToMatVec(new PVector(mx_, my_));
  }

  if (draggingWallPoint) {
    wallPoint[draggedWallPoint] = CanvasToMatVec(new PVector(mx_, my_));
  }
}

void mouseReleased() {
  draggingPortal = false;
}
