//public int MAT_WIDTH = 890;//500;
//public int MAT_HEIGHT = 840;//440;

int toioSize = 23;



void rawInputDisplay(PGraphics pg) {



  pg.pushMatrix();
  pg.fill(255);
  pg.textSize(20);
  //pg.translate(10,10);
  pg.text("FPS = " + frameRate, 30, 25);//Displays how many clients have connected to the server


  pg.translate(30, 30);
  pg.stroke(255);
  pg.noFill();
  pg.rect(0, 0, stageWidthMax, stageDepthMax);





  for (int i = 0; i < 3; i++) {
    pg.line(stageWidthMax/3 * (i+1), 0, stageWidthMax/3 * (i+1), stageDepthMax);
  }
  for (int i = 0; i < 4; i++) {
    pg.line(stageWidthMax, stageDepthMax/4 * (i+1), 0, stageDepthMax/4 * (i+1));
  }

  pg.textSize(25);
  pg.strokeWeight(3);
  pg.stroke(255, 100, 100);
  pg.rect(0, 0, stageWidth-1, stageDepth-1);
  pg.fill(255, 100, 100, 250);
  pg.text("TopStage: X=0, Y=0, W =" + stageWidth + ", D=" + stageDepth, 5, 22);


  if (UnderStage) {
    pg.stroke(100, 255, 100);
    pg.noFill();
    pg.rect(0, stageDepth, stageWidth-1, stageDepth-1);

    pg.fill(100, 255, 100, 250);

    pg.text("UnderStage: X=0, Y="+stageDepth+", W =" + stageWidth + ", D=" + stageDepth, 5, stageDepth+22);
  }

  pg.fill(255, 50);
  pg.textSize(30);
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 4; j++) {
      int matID = 1 + (j) + i*4;
      pg.text("#" + matID, stageWidthMax/3 * (i)+10, stageDepthMax/4 * (j)+40);
    }
    if (UnderStage && i == 2) {
      for (int k = 0; k < 6-1; k ++) {
        int xx =stageWidthMax/3 * i + (stageWidthMax/3)/6 * (k+1);
        pg.stroke(200, 100);
        pg.line(xx, 0, xx, stageDepthMax);
      }
    }
  }


  //draw the cubes
  for (int i = 0; i < cubes.length; ++i) {
    pg.pushMatrix();
    pg.translate(cubes[i].x, cubes[i].y);

    int alpha = 255;
    if (cubes[i].isLost) {
      alpha = 50;
    }

    pg.fill(0, 255, 255, alpha);
    pg.textSize(20);
    pg.text("#"+i + " ["+cubes[i].x+", "+cubes[i].y+"]", 10, -10);
    pg.noFill();

    pg.rotate(cubes[i].deg * PI/180);



    if (cubes[i].buttonState) {
      pg.stroke(0, 255, 255, alpha);
    } else {
      pg.stroke(255, alpha);
    }
    pg.rect(-toioSize/2, -toioSize/2, toioSize, toioSize);
    //pg.rect(0, -5, 20, 10);

    pg.stroke(255, 0, 0, alpha);
    pg.line(0, 0, toioSize/2+2, 0);
    //pg.line(5, -5, -5, 5);

    pg.popMatrix();

    pg.pushMatrix();


    
    if(selectODMode == "Destination"){
      alpha = 255;
    } else{
      alpha = 150;
    }

    // draw target points / Destinations
    pg.translate(cubes[i].targetx, cubes[i].targety);
    pg.noFill();
    pg.stroke(255, 100, 100, alpha);
    pg.strokeWeight(2);
    pg.line(-5, -5, 5, 5);
    pg.line(5, -5, -5, 5);
    // pg.ellipse(0, 0, 10, 10);

    pg.fill(255, 100, 100, alpha);
    pg.textSize(20);
    pg.text("Dest", 2, -25);
    pg.text("#"+i, 2, -10);
    pg.noFill();

    pg.popMatrix();


    //draw current Position / Origin.
    
    if(selectODMode == "Origin"){
      alpha = 255;
    } else{
      alpha = 150;
    }

    if (currentPos[i] != null) {
      pg.pushMatrix();

      pg.translate(currentPos[i].x, currentPos[i].y);
      pg.noFill();
      pg.stroke(100, 255, 255, alpha);
      pg.strokeWeight(2);
      pg.line(-5, -5, 5, 5);
      pg.line(5, -5, -5, 5);

      pg.fill(100, 255, 255, alpha);
      pg.textSize(20);
      pg.text("Orig", 2, -25);
      pg.text("#"+i, 2, -10);
      pg.noFill();

      pg.popMatrix();
    }
  }

  pg.noStroke();

  pg.popMatrix();
}

void displayDebug(PGraphics pg) {

  background(0);
  stroke(255);

  fill(255);
  textSize(12);
  text("FPS = " + frameRate, 10, height-10);//Displays how many clients have connected to the server

  //draw the "mat"
  noFill();
  rect(0, 0, stageWidthMax, stageDepthMax);

  //draw the cubes
  for (int i = 0; i < cubes.length; ++i) {
    pushMatrix();
    translate(cubes[i].x, cubes[i].y);

    int alpha = 255;
    if (cubes[i].isLost) {
      alpha = 50;
    }

    fill(0, 255, 255, alpha);
    text("#"+i + " ["+cubes[i].x+", "+cubes[i].y+"]", 10, -10);
    noFill();

    rotate(cubes[i].deg * PI/180);

    if (cubes[i].buttonState) {
      stroke(0, 255, 255, alpha);
    } else {
      stroke(255, alpha);
    }
    rect(-11, -11, 22, 22);
    rect(0, -5, 20, 10);

    stroke(255, 0, 0, alpha);
    line(-5, -5, 5, 5);
    line(5, -5, -5, 5);

    popMatrix();
  }
}
