Table pongTable;
PVector pongCoord[];
PVector smallPongCoord[][];

int virtualWidth = 1214;
int virtualDepth = 425;

float pongPlaySpeed = 0.3;
float currentFrame = 0;

boolean pongEnable = false;

boolean pongPause = true ;

import processing.video.*;

import deadpixel.keystone.*;

Keystone ks;
CornerPinSurface surface;
PGraphics offscreen; //

Movie movie;


int videoStartOffset = 5600;
int startedTime = 0;
boolean startedVideo = false;

void pongSetup() {
  pongTable = loadTable("pongCoord.csv", "header");


  int controlRowNum = pongTable.getRowCount();
  pongCoord = new PVector[controlRowNum];
  smallPongCoord = new PVector [3][controlRowNum];

  for (int i = 0; i < controlRowNum-1; i++) {
    TableRow row = pongTable.getRow(i);
    pongCoord[i] = new PVector(row.getFloat("Large_X"), row.getFloat("Large_Y"));
    smallPongCoord[0][i] = new PVector(row.getFloat("Small_0X"), row.getFloat("Small_0Y"));
    smallPongCoord[1][i] = new PVector(row.getFloat("Small_1X"), row.getFloat("Small_1Y"));
    smallPongCoord[2][i] = new PVector(row.getFloat("Small_2X"), row.getFloat("Small_2Y"));
  }

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(960, 720, 20);

  offscreen = createGraphics(960, 720, P3D);


  movie = new Movie(this, "lauren_pong.mp4");
  movie.play();

  if (movie.available() == true) {
    movie.read();
  }
}

void movieEvent(Movie m) {
  m.read();
}



void playPong() {
  // println(millis()-startedTime);
  if (millis() - startedTime > videoStartOffset && !startedVideo) {
    currentFrame = 0;
    startedVideo = true;
  }

  boolean Side = true; // switch sides here
  int borderOffset = 20;

  if (!pongPause) {
    if (Side) {
      int threshold = virtualWidth / 2 + borderOffset;

      if (pongCoord[(int)currentFrame].x < threshold ) {
        cubes[1].targetx = borderOffset;
        cubes[1].targety = 100 + 70*(3);
      } else {
        cubes[1].targetx = pongCoord[(int)currentFrame].x - virtualWidth/2;
        cubes[1].targety = pongCoord[(int)currentFrame].y;
      }

      for (int i = 0; i< 3; i++) {
        if (smallPongCoord[i][(int)currentFrame].x < threshold ) {
          cubes[2+i].targetx = borderOffset;
          cubes[2+i].targety = 50 + 70*(i);
        } else {
          cubes[2+i].targetx = smallPongCoord[i][(int)currentFrame].x - virtualWidth/2;
          cubes[2+i].targety = smallPongCoord[i][(int)currentFrame].y;
        }
      }
    } else {
      int threshold = virtualWidth / 2 - borderOffset;

      if (pongCoord[(int)currentFrame].x > threshold ) {
        cubes[1].targetx = borderOffset;
        cubes[1].targety = 85;
      } else {
        cubes[1].targetx = virtualWidth/2 - pongCoord[(int)currentFrame].x;
        cubes[1].targety = virtualDepth - pongCoord[(int)currentFrame].y;
      }

      for (int i = 0; i< 3; i++) {
        if (smallPongCoord[i][(int)currentFrame].x > threshold ) {
          cubes[2+i].targetx = borderOffset;
          cubes[2+i].targety = 139 + 70*(i+1);
        } else {
          cubes[2+i].targetx = virtualWidth/2 - smallPongCoord[i][(int)currentFrame].x;
          cubes[2+i].targety = virtualDepth - smallPongCoord[i][(int)currentFrame].y;
        }
      }
    }
    //println(currentFrame);
    for (int i = 1; i<5; i++) {
      moveTo(i, (int)cubes[i].targetx, (int)cubes[i].targety, 60, 20);
    }
    if (startedVideo) {
      currentFrame += pongPlaySpeed;
    }
  }
}

void pongDraw() {
  pushMatrix();
  translate (0, 0, -2);
  drawApp(offscreen);

  surface.render(offscreen);

  popMatrix();
}

void drawApp (PGraphics pG) {
  pG.beginDraw();
  pG.background(255, 0, 0);
  pG.imageMode(CENTER);
  float scale = 1.51;
  pG.image(movie, offscreen.width/2-20, offscreen.height/2-100, movie.width*scale*1.05, movie.height*scale*0.9);
  //pG.textSize(40);
  //pG.text(millis() - startedTime + ", " + currentFrame, 10, 200);
  pG.endDraw();
}
