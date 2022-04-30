String[] filenames;

String dirPath; // This has been changed. No need to write the full path here.

String stageDesignDirPath;

int currentFileNum = 0;

void setupCSV() {
  dirPath = sketchPath("")+"data/csv/";
  stageDesignDirPath  = sketchPath("")+"../../1_StageDesignUI/StageDesignUI_v1_0/data/csv/";
  loadFileNames();
}

void savePlanerMap(){
  PrintWriter mapFile = createWriter("CBS_planner/current_stage.txt");
  
  int underStageBoolToInt = 0;
  if(UnderStage){
    underStageBoolToInt = 1;
  }
  mapFile.println(stageWidth +","+ stageDepth + "," + wallPointNum + "," + portalWallNum +"," 
  + underStageBoolToInt + "," + under_wallPointNum + "," + portalFloorNum);
  for (int i = 0; i < wallPointNum-1; i++) {
    mapFile.println(wallPoint[i].x + "," + wallPoint[i].y + "," + wallPoint[i+1].x + "," + wallPoint[i+1].y);
  }
  
  for (int i = 0; i < portalWallNum; i++) {
    
    mapFile.println(portalWallVec[i].x + "," + portalWallVec[i].y 
                        + "," + portalWallEdgeL[i].x + "," + portalWallEdgeL[i].y
                        + "," + portalWallEdgeR[i].x + "," + portalWallEdgeR[i].y +"," +portalWallWidth[i]);
   
  }
  
  for (int i = 0; i < under_wallPointNum-1; i++) {
    mapFile.println(under_wallPoint[i].x + "," + under_wallPoint[i].y + "," 
    + under_wallPoint[i+1].x + "," + under_wallPoint[i+1].y);
  }
  

  for (int i = 0; i < portalFloorNum; i++) {
    
    mapFile.println(portalFloor[i].x + "," + portalFloor[i].y + "," + portalFloorFrontPoint[i].x +"," + portalFloorFrontPoint[i].y
    + "," + portalFloorBackPoint[i].x +","+ portalFloorBackPoint[i].y +","+portalFloorSlopeDir[i]);
    
  }

  mapFile.flush();
  mapFile.close();
  
}

void loadStageCSV(int ii) {
  Table table;

  table = loadTable(stageDesignDirPath + filenames[ii], "header");


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
  
  savePlanerMap();
}



void loadFileNames() {
  String path = stageDesignDirPath;


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


void saveODPosCSV(String filePath) {
  Table table;
  table = new Table();
  //table.addColumn("filename");
  //table.setString(0, "filename", filenames[currentFileNum]);

  table.addColumn("currentPosX");
  table.addColumn("currentPosY");
 //table.addColumn("currentDeg");

  table.addColumn("targetPosX");
  table.addColumn("targetPosY");

  for (int i = 0; i< numRobot; i++) {
    table.setInt(i, "currentPosX", (int)currentPos[i].x);
    table.setInt(i, "currentPosY", (int)currentPos[i].y);
    //table.setInt(i, "currentDeg", cubes[i].deg);
    //table.setInt(i, "currentPosX", cubes[i].x);
    //table.setInt(i, "currentPosY", cubes[i].y);
    //table.setInt(i, "currentDeg", cubes[i].deg);

    table.setInt(i, "targetPosX", (int)cubes[i].targetx);
    table.setInt(i, "targetPosY", (int)cubes[i].targety);
  }


  saveTable(table, filePath);
  
  println("SAVED CSV - FILENAME: controlCommand", filenames[currentFileNum], ".csv");
}


void loadODPosCSV(){
  Table table;

  table = loadTable(movementPlan, "header");


  TableRow firstRow = table.getRow(0);
  
  for(int i = 0; i<nCubes; i++){
    currentPos[i].x = table.getRow(i).getInt("currentPosX");
    currentPos[i].y = table.getRow(i).getInt("currentPosY");
    
    cubes[i].targetx = table.getRow(i).getInt("targetPosX");
    cubes[i].targety = table.getRow(i).getInt("targetPosY");

  }

}

void loadPaths(){
   loadedPaths = new Vector<Vector<PVector>>();
   BufferedReader reader = createReader("CBS_planner/paths.txt");
   String line;
   maxTime=0;
   
   
   for(int i=0; i<numRobot; i++){
     try{
       line = reader.readLine();
       
     }catch (IOException e) {
      e.printStackTrace();
      line = null;
      break;
     }
     
     String[] coordinates = line.split(" ");
     int timesteps = 0;
     Vector<PVector> path = new Vector<PVector>();
     for(String s: coordinates){
       String[] xyz = s.split(",");
       //println(int(xy[0]));
       //println(int(xy[1]));
       int floor_value = -100;
       if(int(xyz[2]) == 0){
         floor_value = -1;
       }else{
         floor_value = 0;
       }
       path.add(new PVector(int(xyz[0]),int(xyz[1]), int(floor_value)));
       timesteps += 1;
     }
     
     loadedPaths.add(path);
     println(loadedPaths);
     if(timesteps>maxTime){ 
       maxTime = timesteps;
     }
   }

   
   
   
   
}
