boolean controlEnable = false;

int loadControlRow = 0;
int maxTimeStamp = 0;



int currentTimeStamp = 0;
int currentRow = 0;
void addFrame() {
  currentTimeStamp++;
  println("currentTimeStamp: ", currentTimeStamp);
  boolean flag = true;
  while (command[currentRow].Timestamp < currentTimeStamp && flag) {
    println(currentRow, command[currentRow].action);
    if (command[currentRow].action.startsWith("moveForward")  ) {
      cubes[command[currentRow].toio_ID].targetx = command[currentRow].to_x;
      cubes[command[currentRow].toio_ID].targety = command[currentRow].to_y;
    }
    if (currentRow < controlRowNum -1) {
      currentRow++;
    } else {
      flag = false;
    }
  }
}

void reduceFrame() {
  currentTimeStamp--;

  boolean flag = true;
  println("currentTimeStamp: ", currentTimeStamp, "currentRow", currentRow, "currentRow.Timestamp", command[currentRow].Timestamp);

  while (command[currentRow].Timestamp > currentTimeStamp && flag ) {

    if (command[currentRow].action.startsWith("moveForward")) {
      cubes[command[currentRow].toio_ID].targetx = command[currentRow].to_x;
      cubes[command[currentRow].toio_ID].targety = command[currentRow].to_y;
    }
    if ( 0 < currentRow) {
      currentRow--;
    } else {
      flag = false;
    }
  }
}

void setTargetFromEnd() {

  println("currentTimeStamp: ", currentTimeStamp, "currentRow", currentRow, "currentRow.Timestamp", command[currentRow].Timestamp);


  for (int i =0; i < numRobot; i++) {
    boolean flag = true;
    println(i);
    int currentRow_ = controlRowNum-1;
    while (flag) {
      
      if (command[currentRow_].action.startsWith("moveForward") && i == command[currentRow_].toio_ID) {
        cubes[command[currentRow_].toio_ID].targetx = command[currentRow_].to_x;
        cubes[command[currentRow_].toio_ID].targety = command[currentRow_].to_y;
        flag = false;
      } else {
        currentRow_--;
      }
    }
  }
}


class ControlCommand { 
  int Timestamp;
  int toio_ID;
  int from_x, from_y, from_degree;
  String action;
  int to_x, to_y, to_degree;
  ControlCommand (int t, int tID, int fx, int fy, int fd, String a, int toX, int toY, int toD) {  
    toio_ID = tID;
    Timestamp = t;
    from_x = fx;
    from_y = fy;
    from_degree = fd;

    action = a;

    to_x = toX;
    to_y = toY;
    to_degree = toD;
  }
} 

ControlCommand command[] = new ControlCommand [3000];
int controlRowNum = 0;

void loadControlCSV(String filename) {
  Table table;

  table = loadTable(stageDesignDirPath + filename, "header");

  println(table.getRowCount() + " total rows in table");

  controlRowNum = table.getRowCount();

  TableRow lastRow = table.getRow(controlRowNum-1);
  maxTimeStamp = lastRow.getInt("Timestamp");


  int rowID = 0;
  for (TableRow row : table.rows()) {
    command[rowID] = new ControlCommand(row.getInt("Timestamp"), row.getInt("toio_ID"), 
      row.getInt("from_x"), row.getInt("from_y"), (int)row.getFloat("from_degree"), row.getString("action"), 
      row.getInt("to_x"), row.getInt("to_y"), (int)row.getFloat("to_degree"));


    rowID++;
  }
}
