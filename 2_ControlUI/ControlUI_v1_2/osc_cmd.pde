import processing.net.*; 
Client myClient;

void setupOsc() {

  myClient = new Client(this, "localhost", 8000);
}



//OSC message handling (receive)

void serverReceive() {
  if (myClient.available() > 0) { 

    String data = myClient.readString();
    //println(data);
    processClientMessage(data);
  }
}

void processClientMessage(String msg) {
  String[] s = split(msg, "\n");

  for (int i = 0; i<s.length; i++) {
    String[] m = split(s[i], "::");
    if (m[0].intern() == ("pos").intern() && m.length > 4) { //get position (x, y, and deg)
      //if (pcount != count) {

      int id = int(m[1]);
      int x = int(m[2])+11;
      int y = int(m[3])+11;
      int deg = int(m[4]);


      if (id < cubes.length && id < nCubes) {
        cubes[id].count++;
        cubes[id].prex = cubes[id].x;
        cubes[id].prey = cubes[id].y;


        cubes[id].x = x;
        cubes[id].y = y;

        cubes[id].deg = deg;

        cubes[id].lastUpdate = System.currentTimeMillis();
      }
      cubes[id].isLost = false;
    } else if (m[0].intern() == ("but").intern() && m.length > 1) {  //get button input 0 or 1
      // button


      int id = int(m[1]);
      int pressValue = int(m[2]);//ID, buttonState

      if (id < nCubes) {
        println("[App Message] Button pressed for id : "+id + ", val = " + pressValue);
        if (pressValue == 1) {
          cubes[id].buttonState = false;
        } else {
          cubes[id].buttonState = true;
        }
      }
    } else if (m[0].intern() == ("acc").intern() && m.length > 3) { 
      // acc
      int id = int(m[1]);
      int isFlat = int(m[2]);
      //int orientation = msg.get(2).intValue();
      int collision = int(m[3]);
      if (id < nCubes) {
        if (collision == 1) {
          println("[App Message] Collision Detected for id : " + id );

          cubes[id].collisionState = true;
        }

        if (isFlat == 1) {
          cubes[id].tiltState = true;
        } else {
          cubes[id].tiltState = false;
        }
      }
    }
  }
}


//OSC messages (send)

String sendCommand = "";

void serverSend() {


  if (sendCommand != "") {
    myClient.write(sendCommand);
  }

  sendCommand = "";
}

void ledControl(int cubeId, int r, int g, int b, int duration) {
  // command to control led
  // r, g, b => 0-255 (color control)
  // duration => duration of motor command  0-255 (val*10 millisec)

  String msg = "led,"+cubeId+ "," + r+"," + g+"," + b+","+duration+"\n";

  sendCommand += msg;
}

void motorControl(int cubeId, float left, float right, int duration) {
  // command to directly control the motor
  // left, right => speed of Motor: in range of -100 and 100 (motor will not move under ±10, 10 = 43rpm, 100 = 430rpm)
  // duration => duration of motor command  0-255 (val*10 millisec)
  String msg = "motor,"+cubeId+ "," + (int)left +"," + (int)right +"," + duration+"\n";
  //println(msg);
  sendCommand += msg;
}




void playSound(int cubeId, int MIDINoteNum, int loudness, int duration) {
  // command to make sound 
  // MIDINoteNum =>  1-127 -> https://toio.github.io/toio-spec/docs/ble_sound
  // loudness => 0-255 // *currently not working //
  // duration => 1-255 (val*10 millisec)

  String msg = "midi,"+cubeId+ "," + MIDINoteNum +"," + loudness +"," + duration +"\n";
  sendCommand += msg;
}


// advanced motor control

void moveTo(int cubeId, int tx, int ty, int dM, int oM) {
  // command to make cube move to target coordinate
  // tx, ty => target coordinate
  // dM (distanceMap) => Ratio of Distance mapped to speed  (around 100 is good)
  // oM (offsetMotion) => offset for target position (around 10 is good)
  String msg = "moveto,"+cubeId+ "," + tx +"," + ty +"," + dM +"," + oM+"\n";
  sendCommand += msg;

  cubes[cubeId].moveTo=true;

  ////draw target point
  //pushMatrix();
  //translate(50,50);
  //translate(tx, ty);
  //stroke(255);
  //fill(255, 0, 0);
  //ellipse(0, 0, 10, 10);

  //fill(255, 0, 0);
  //textSize(11);
  //text(""+int(tx)+", "+ int(ty)+".", 10, 15); 

  //popMatrix();

  //pushMatrix();
  //translate(50,50);
  //stroke(255, 0, 0);
  //line(cubes[cubeId].x, cubes[cubeId].y, tx, ty);
  //popMatrix();
}

void moveToTarget(int cubeId, int tx, int ty, int tdeg, int targetingMode, int rotMode, int timeOutSec, int maxSpeed, int speedChangeType) {
  // command to make cube move to target coordinate
  // tx, ty => target coordinate
  // dM (distanceMap) => Ratio of Distance mapped to speed  (around 100 is good)
  // oM (offsetMotion) => offset for target position (around 10 is good)
  String msg = "moveto,"+cubeId+ "," +tx+","+ty+","+ tdeg+","+targetingMode+","+rotMode+","+ timeOutSec+","+ maxSpeed+","+speedChangeType+"\n";
  sendCommand += msg;



  //  //draw target point
  //  pushMatrix();
  //  translate(tx, ty);
  //  stroke(255);
  //  fill(255, 0, 0);
  //  ellipse(0, 0, 10, 10);

  //  fill(255, 0, 0);
  //  textSize(11);
  //  text(""+int(tx)+", "+ int(ty)+".", 10, 15); 

  //  popMatrix();

  //  stroke(255, 0, 0);
  //  line(cubes[cubeId].x, cubes[cubeId].y, tx, ty);
}


void rotateTo(int cubeId, int targetDeg, int offsetRotate, int rotateMap) { //
  // command to rotate cube to target angle
  // targetDeg => target angle in degrees
  // offsetRotate => Ratio of Angle Difference mapped to rotation speed  (*currently not used)
  // rotateMap => offset for target angle (*currently not used)
  String msg = "rotateto,"+cubeId+ "," + targetDeg +"," + offsetRotate +"," + rotateMap + "\n";
  sendCommand += msg;
}

void vibrate(int cubeId, int dur, int amp, int fps) {
  // command to vibrate cube
  // dur: duration of each vibration (val*10 millisec)
  // amp: speed of motor, amplitude of vibration
  // fps: frame per second (around 1-30 would be good?)

  String msg = "vibrate,"+cubeId+ "," +dur +"," + amp +"," + fps +"\n";
  sendCommand += msg;
}

void pose(int cubeId) {
  // command to stop

  String msg = "stop,"+cubeId+"\n";
  sendCommand += msg;


  cubes[cubeId].moveTo=false;
}
