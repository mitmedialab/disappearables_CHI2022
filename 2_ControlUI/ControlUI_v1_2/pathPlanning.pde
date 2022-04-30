int numRobot = nCubes;

PVector currentPos[] =  new PVector[numRobot];
PVector targetPos[] =  new PVector[numRobot];

// paths loaded from file will be stored in this variable.
Vector<Vector<PVector>> loadedPaths = new Vector<Vector<PVector>>();
int maxTime = 0;

String selectODMode = "Origin"; //

color origColor = color(100, 255, 255);
color destColor = color(255, 100, 100);

void setSampleOriginDestData() {
  // 2x5?



  int corner = 40;
  int spacing = 75;
  // int row = 2;
  int col = 8;

  for (int i = 0; i < numRobot; i++) {
    int r = i%col;
    int c = i/col;
    currentPos[i] = new PVector (corner + r*spacing, corner  + spacing *c);

    targetPos[i] = new PVector (corner + spacing * r, stageDepthMax/2+20 + spacing * c);
    cubes[i].targetx = targetPos[i].x;
    cubes[i].targety = targetPos[i].y;
    //moveTo(i, (int)cubes[i].targetx, (int)cubes[i].targety, 100, 50);

    //println(i, "r:", r, "c:", c);
  }
}
