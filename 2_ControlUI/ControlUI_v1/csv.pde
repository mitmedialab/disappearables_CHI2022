String[] filenames;
String dirPath; // This has been changed. No need to write the full path here.

int currentFileNum = 0;

void setupCSV() {
  dirPath = sketchPath("")+"data/csv/";
  loadFileNames();
}



void loadStageCSV(int ii) {
  Table table;

  table = loadTable(dirPath + filenames[ii], "header");


  TableRow firstRow = table.getRow(0);


  stageWidth = firstRow.getInt("stageWidth");

  stageDepth = firstRow.getInt("stageDepth");


  UnderStage = boolean(firstRow.getInt("UnderStage"));
  _3DP = boolean(firstRow.getInt("3DP"));


  if (_3DP) {
    _3DPrinterPosX = firstRow.getInt("_3DPrinterPosX");
    _3DPrinterPosY = firstRow.getInt("_3DPrinterPosY");
    _3DPrinterDir = firstRow.getInt("_3DPrinterDir");
  }


  wallPointNum = firstRow.getInt("wallPointNum");
  for (int i = 0; i < wallPointNum; i++) {
    TableRow row = table.getRow(i);
    wallPoint[i].set(row.getFloat("wallPointX"), row.getFloat("wallPointY"));
  }



  under_wallPointNum = firstRow.getInt("under_wallPointNum");
  //println(under_wallPointNum);
  for (int i = 0; i < under_wallPointNum; i++) {
    TableRow row = table.getRow(i);
    //println(i, row.getFloat("under_wallPointX"), row.getFloat("under_wallPointY"));
    under_wallPoint[i].set(row.getFloat("under_wallPointX"), row.getFloat("under_wallPointY"));
  }



  portalWallNum = firstRow.getInt("portalWallNum");
  for (int i = 0; i < portalWallNum; i++) {
    TableRow row = table.getRow(i);

    portalWallVec[i] = new PVector(row.getFloat("portalWallVecX"), row.getFloat("portalWallVecY"));
    portalWallFrontPoint[i]= new PVector(row.getFloat("portalWallFrontPointX"), row.getFloat("portalWallFrontPointY"));
    portalWallBackPoint[i]= new PVector(row.getFloat("portalWallBackPointX"), row.getFloat("portalWallBackPointY"));
    portalWallEdgeL[i]= new PVector(row.getFloat("portalWallEdgeLX"), row.getFloat("portalWallEdgeLY"));
    portalWallEdgeR[i]= new PVector(row.getFloat("portalWallEdgeRX"), row.getFloat("portalWallEdgeRY"));
    portalWallWidth[i] = row.getInt("portalWallWidth");
    portalWallatWallNum[i] = row.getInt("portalWallatWallNum");
  }

  portalFloorNum = firstRow.getInt("portalFloorNum");
  slopeNum = portalFloorNum; // temp

  for (int i = 0; i < portalFloorNum; i++) {
    TableRow row = table.getRow(i);
    portalFloor[i]= new PVector(row.getFloat("portalFloorX"), row.getFloat("portalFloorY"));
    portalFloorFrontPoint[i]= new PVector(row.getFloat("portalFloorFrontPointX"), row.getFloat("portalFloorFrontPointY"));
    portalFloorBackPoint[i]= new PVector(row.getFloat("portalFloorBackPointX"), row.getFloat("portalFloorBackPointY"));
    portalFloorType[i]  = row.getInt("portalFloorType");
    portalFloorAS[i] = row.getInt("portalFloorAS");
    portalFloorSlopeDir[i] = row.getInt("portalFloorSlopeDir");

    println(i, portalFloor[i].x, portalFloor[i].y);
    //slopePosX[i] = int(portalFloor[i].x);
    //println(portalFloor[i].x);
    // slopePosY[i] = (int)portalFloor[i].y;
  }

  pillarNum = firstRow.getInt("pillarNum");

  for (int i = 0; i < pillarNum; i++) {
    TableRow row = table.getRow(i);
    pillar[i]= new PVector(row.getFloat("pillarX"), row.getFloat("pillarY"));
  }
}



void loadFileNames() {
  String path = dirPath;


  println("Listing all filenames in a directory: ");
  filenames = listFileNames(path);
  printArray(filenames);
}

// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

void saveTargetPosCSV() {
  Table table;
  table = new Table();
  table.addColumn("filename");
  table.setString(0, "filename", filenames[currentFileNum]);

  table.addColumn("currentPosX");
  table.addColumn("currentPosY");
  table.addColumn("currentDeg");

  table.addColumn("targetPosX");
  table.addColumn("targetPosY");

  for (int i = 0; i< nCubes; i++) {
    table.setInt(i, "currentPosX", cubes[i].x);
    table.setInt(i, "currentPosY", cubes[i].y);
    table.setInt(i, "currentDeg", cubes[i].deg);

    table.setInt(i, "targetPosX", (int)cubes[i].targetx);
    table.setInt(i, "targetPosY", (int)cubes[i].targety);
  }


  saveTable(table, "data/csv/control_" + filenames[currentFileNum] + ".csv");

  println("SAVED CSV - FILENAME: controlCommand", filenames[currentFileNum], ".csv");
}

int numRobot = 10;

PVector currentPos[] =  new PVector[numRobot];
void saveTargetPosCSVManual() {
  // 2x5?
  numRobot = 10;

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

  Table table;
  table = new Table();
  table.addColumn("filename");
  table.setString(0, "filename", filenames[currentFileNum]);

  table.addColumn("currentPosX");
  table.addColumn("currentPosY");
  table.addColumn("currentDeg");

  table.addColumn("targetPosX");
  table.addColumn("targetPosY");

  for (int i = 0; i< numRobot; i++) {
    table.setInt(i, "currentPosX", (int)currentPos[i].x);
    table.setInt(i, "currentPosY", (int)currentPos[i].y);
    table.setInt(i, "currentDeg", 0);

    table.setInt(i, "targetPosX", (int)targetPos[i].x);
    table.setInt(i, "targetPosY", (int)targetPos[i].y);
  }

  println(filenames[currentFileNum]);
  saveTable(table, "data/csv/control_" + filenames[1]);

  println("SAVED CSV - FILENAME: controlCommand", filenames[1], ".csv");
}
