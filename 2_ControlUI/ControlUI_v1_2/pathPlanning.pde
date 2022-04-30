int numRobot = 10;

PVector currentPos[] =  new PVector[numRobot];

// paths loaded from file will be stored in this variable.
Vector<Vector<PVector>> loadedPaths = new Vector<Vector<PVector>>();
int maxTime = 0;

String selectODMode = "Origin"; //

color origColor = color(100, 255, 255);
color destColor = color(255, 100, 100);

void setSampleOriginDestData(){
    // 2x5?

  int corner = 30;
  int spacing = 50;

  numRobot = 10;

  for (int i = 0; i < 5; i++) {
    currentPos[i] = new PVector (corner + i*spacing, 3*stageDepthMax/4 );
  }

  for (int i = 5; i < 10; i++) {
    currentPos[i] = new PVector (2 * stageWidthMax/3 - corner - (i-5)*spacing, 3*stageDepthMax/4);
  }


  PVector targetPos[] =  new PVector[numRobot];


  int row = 2;
  int col = 5;

  int spacingX = 75;
  int spacingY = 75;
  PVector origin = new PVector (150, stageDepthMax/2 - 120);
  for (int i = 0; i < numRobot; i++) {
    //5*6 position

    int r = i%col;
    int c = i/col;
    targetPos[i] = new PVector (origin.x + spacingX * r, origin.y + spacingY * c);
    cubes[i].targetx = targetPos[i].x;
    cubes[i].targety = targetPos[i].y;
    moveTo(i, (int)cubes[i].targetx, (int)cubes[i].targety, 100, 50);

    //println(i, "r:", r, "c:", c);
  }


  // 4x6 _ Three WALL

  /*
  int corner = 50;
   int spacing = 95;
   
   numRobot = 24;
   
   for (int i = 0; i < numRobot/3; i++) {
   currentPos[i] = new PVector (corner, stageDepth - corner - i*spacing);
   }
   
   for (int i = numRobot/3; i < 2*numRobot/3; i++) {
   currentPos[i] = new PVector (corner + (0.5+i-numRobot/3)*spacing, corner);
   }
   
   for (int i = 2* numRobot/3; i < numRobot; i++) {
   currentPos[i] = new PVector (stageWidth - corner, corner + (1+i-2*numRobot/3)*spacing);
   }
   
   PVector targetPos[] =  new PVector[numRobot];
   
   
   int row = 6;
   int col = 4;
   
   int spacingX = 95;
   int spacingY = 85;
   PVector origin = new PVector (300, 400);
   for (int i = 0; i < numRobot; i++) {
   //5*6 position
   
   int r = i%col;
   int c = i/col;
   targetPos[i] = new PVector (origin.x + spacingX * r, origin.y + spacingY * c);
   cubes[i].targetx = targetPos[i].x;
   cubes[i].targety = targetPos[i].y;
   moveTo(i, (int)cubes[i].targetx, (int)cubes[i].targety, 100, 50);
   
   //println(i, "r:", r, "c:", c);
   }
   
   */
}
