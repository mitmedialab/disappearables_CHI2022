String[] filenames;

// change this to your own path
String dirPath = System.getProperty("user.home") + "/Documents/GitHub/disappearables_CHI2022/1_StageDesignUI/StageDesignUI_v0_3/data/csv/";  // CHANGE THIS FOR YOUR DIRECTORY

void setupCSV() {
  loadFileNames();
}

void savePlanerMap(){
  PrintWriter mapFile = createWriter(dirPath+cp5.get(Textfield.class, "FileName").getText()+".txt");
  mapFile.println(stageWidthMax +","+ stageDepthMax + "," + wallPointNum + "," + portalWallNum);
  for (int i = 0; i < wallPointNum-1; i++) {
    mapFile.println(wallPoint[i].x + "," + wallPoint[i].y + "," + wallPoint[i+1].x + "," + wallPoint[i+1].y);
  }
  
  for (int i = 0; i < portalWallNum; i++) {
    
    mapFile.println(portalWallVec[i].x + "," + portalWallVec[i].y 
                        + "," + portalWallEdgeL[i].x + "," + portalWallEdgeL[i].y
                        + "," + portalWallEdgeR[i].x + "," + portalWallEdgeR[i].y +"," +portalWallWidth[i]);
   
  }
  
  mapFile.flush();
  mapFile.close();
  
}

void saveCSV() {
  Table table;

  table = new Table();

  table.addColumn("stageWidth");
  table.addColumn("stageDepth");

  table.addColumn("UnderStage");
  table.addColumn("3DP"); // if 3D printer Exhists 

  table.addColumn("_3DPrinterPosX");
  table.addColumn("_3DPrinterPosY");
  table.addColumn("_3DPrinterDir");


  table.addColumn("wallPointNum");
  table.addColumn("wallPointX");
  table.addColumn("wallPointY");
  

  table.addColumn("portalWallNum");
  table.addColumn("portalWallVecX");
  table.addColumn("portalWallVecY");

  table.addColumn("portalWallFrontPointX");
  table.addColumn("portalWallFrontPointY");
  table.addColumn("portalWallBackPointX");
  table.addColumn("portalWallBackPointY");

  table.addColumn("portalWallEdgeLX");
  table.addColumn("portalWallEdgeLY");
  table.addColumn("portalWallEdgeRX");
  table.addColumn("portalWallEdgeRY");

  table.addColumn("portalWallatWallNum");
  table.addColumn("portalWallWidth");
  table.addColumn("portalWallAS");
  
  table.addColumn("under_wallPointNum");
  table.addColumn("under_wallPointX");
  table.addColumn("under_wallPointY");


  table.addColumn("portalFloorNum");
  table.addColumn("portalFloorX");
  table.addColumn("portalFloorY");
  table.addColumn("portalFloorFrontPointX");
  table.addColumn("portalFloorFrontPointY");
  table.addColumn("portalFloorBackPointX");
  table.addColumn("portalFloorBackPointY");
  table.addColumn("portalFloorType");
  table.addColumn("portalFloorAS");
  table.addColumn("portalFloorSlopeDir");

  table.addColumn("pillarNum");
  table.addColumn("pillarX");
  table.addColumn("pillarY");


  //TableRow newRow = table.addRow();
  table.setInt(0, "stageWidth", stageWidth);
  table.setInt(0, "stageDepth", stageDepth);

  table.setInt(0, "UnderStage", boolToInt(UnderStage));
  table.setInt(0, "3DP", boolToInt(_3DP));


  table.setInt(0, "_3DPrinterPosX", _3DPrinterPosX);
  table.setInt(0, "_3DPrinterPosY", _3DPrinterPosY);
  table.setInt(0, "_3DPrinterDir", _3DPrinterDir);


  table.setInt(0, "wallPointNum", wallPointNum);
  for (int i = 0; i < wallPointNum; i++) {
    table.setFloat(i, "wallPointX", wallPoint[i].x);
    table.setFloat(i, "wallPointY", wallPoint[i].y);
  }
  
  table.setInt(0, "under_wallPointNum", under_wallPointNum);
  for (int i = 0; i < under_wallPointNum; i++) {
    table.setFloat(i, "under_wallPointX", under_wallPoint[i].x);
    table.setFloat(i, "under_wallPointY", under_wallPoint[i].y);
  }

  table.setInt(0, "portalWallNum", portalWallNum);
  for (int i = 0; i < portalWallNum; i++) {
    table.setFloat(i, "portalWallVecX", portalWallVec[i].x);
    table.setFloat(i, "portalWallVecY", portalWallVec[i].y);
    table.setFloat(i, "portalWallFrontPointX", portalWallFrontPoint[i].x);
    table.setFloat(i, "portalWallFrontPointY", portalWallFrontPoint[i].y);
    table.setFloat(i, "portalWallBackPointX", portalWallBackPoint[i].x);
    table.setFloat(i, "portalWallBackPointY", portalWallBackPoint[i].y);
    table.setFloat(i, "portalWallEdgeLX", portalWallEdgeL[i].x);
    table.setFloat(i, "portalWallEdgeLY", portalWallEdgeL[i].y);
    table.setFloat(i, "portalWallEdgeRX", portalWallEdgeR[i].x);
    table.setFloat(i, "portalWallEdgeRY", portalWallEdgeR[i].y);
    table.setInt(i, "portalWallWidth", portalWallWidth[i]);
    table.setInt(i, "portalWallatWallNum", portalWallatWallNum[i]);
    table.setInt(i, "portalWallAS", portalWallAS[i]);
  }


  table.setInt(0, "portalFloorNum", portalFloorNum);

  for (int i = 0; i < portalFloorNum; i++) {
    table.setFloat(i, "portalFloorX", portalFloor[i].x);
    table.setFloat(i, "portalFloorY", portalFloor[i].y);
    table.setFloat(i, "portalFloorFrontPointX", portalFloorFrontPoint[i].x);
    table.setFloat(i, "portalFloorFrontPointY", portalFloorFrontPoint[i].y);
    table.setFloat(i, "portalFloorBackPointX", portalFloorBackPoint[i].x);
    table.setFloat(i, "portalFloorBackPointY", portalFloorBackPoint[i].y);
    table.setInt(i, "portalFloorType", portalFloorType[i]);
    table.setInt(i, "portalFloorAS", portalFloorAS[i]);
    table.setInt(i, "portalFloorSlopeDir", portalFloorSlopeDir[i]);
  }

  table.setInt(0, "pillarNum", pillarNum);
  for (int i = 0; i < pillarNum; i++) {
    table.setFloat(i, "pillarX", pillar[i].x);
    table.setFloat(i, "pillarY", pillar[i].y);
  }


  String name = cp5.get(Textfield.class, "FileName").getText();

  saveTable(table, "data/csv/" + name + ".csv");
  savePlanerMap();
  println("SAVED CSV - FILENAME: ", name, ".csv");
}

void loadCSV(int ii) {
  Table table;

  table = loadTable(dirPath + filenames[ii], "header");


  TableRow firstRow = table.getRow(0);


  stageWidth = firstRow.getInt("stageWidth");

  stageDepth = firstRow.getInt("stageDepth");

  stageSizeSlider.setValue(stageWidth, stageDepth);

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
  for (int i = 0; i < under_wallPointNum; i++) {
    TableRow row = table.getRow(i);
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

  for (int i = 0; i < portalFloorNum; i++) {
    TableRow row = table.getRow(i);
    portalFloor[i]= new PVector(row.getFloat("portalFloorX"), row.getFloat("portalFloorY"));
    portalFloorFrontPoint[i]= new PVector(row.getFloat("portalFloorFrontPointX"), row.getFloat("portalFloorFrontPointY"));
    portalFloorBackPoint[i]= new PVector(row.getFloat("portalFloorBackPointX"), row.getFloat("portalFloorBackPointY"));
     portalFloorType[i]  = row.getInt("portalFloorType");
     portalFloorAS[i] = row.getInt("portalFloorAS");
    portalFloorSlopeDir[i] = row.getInt("portalFloorSlopeDir");
  }

  pillarNum = firstRow.getInt("pillarNum");

  for (int i = 0; i < pillarNum; i++) {
    TableRow row = table.getRow(i);
    pillar[i]= new PVector(row.getFloat("pillarX"), row.getFloat("pillarY"));
  }


  accordionPortal.remove();
  setupAccordionPortal();
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
