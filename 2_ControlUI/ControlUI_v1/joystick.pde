int joyStickNum = 3;


int joysStickX[] =new int[joyStickNum];
int joysStickY[] =new int[joyStickNum];
int joyStickSwitch[] =new int[joyStickNum];
int p_joyStickSwitch[] =new int[joyStickNum];
boolean spinMode[] = new boolean[joyStickNum];

int currentJoyStickNum = min(nCubes, 3);

int twoJoystickL = 0;
int twoJoystickR = 0;


void joyStickSetup() {

  for (int i = 0; i< joyStickNum; i++) {
    joysStickX[i] =512;
    joysStickY[i] =512;
    joyStickSwitch[i] =1;
    p_joyStickSwitch[i] =1;
    spinMode[i] = false;
  }
}


int duration = 5;
int maxSpeed = 115;
void joyStickUpdate() {
   twoJoystickL = joysStickY[0];
   twoJoystickR = joysStickY[1];
   
   //println(twoJoystickL, twoJoystickR);

  
  for (int i = 0; i< currentJoyStickNum; i++ ) {
    if (p_joyStickSwitch[i] == 0 && joyStickSwitch[i] == 1 ) {
      spinMode[i] = !spinMode[i];
      if (spinMode[i]) {
        //playSound(0, 0, 255, 10);
         ledControl(i, 255,0,0, 0);
      } else {
        //playSound(0, 0, 255, 14);
        ledControl(i, 0,255,0, 0);
      }
    }
    p_joyStickSwitch[i] = joyStickSwitch[i];

    if (spinMode[i]) {
      int motor = constrain((int)map(joysStickX[i], 20, 1000, -maxSpeed, maxSpeed), - maxSpeed, maxSpeed);
      if (abs(motor)> 10) {
        motorControl(i, -motor, motor, duration);
      }
    } else { // steering Mode

      int motor = (int)map(joysStickY[i], 0, 1023, maxSpeed, -maxSpeed);
      int maxL = 550;
      int maxR = 400;
      int maxSensor = 930;
      if (abs(motor) > 10) {
        if (joysStickX[i] > maxL) { // turnLeft
          float reduceRatio = map(joysStickX[i], maxSensor, maxL, 0.5, 1.0);
          motorControl(i,  (int)(reduceRatio*motor),motor, duration);
        } else if (joysStickX[i] < maxR) { // turnRight
          float reduceRatio = map(joysStickX[i], 0, maxR, 0.5, 1.0);
          motorControl(i, motor,(int)(reduceRatio*motor),  duration);
        } else {
          motorControl(i, motor, motor, duration);
        }
      } else {
        if (joysStickX[i] > maxL) { // turnLeft
          motor = (int)map(joysStickX[i], maxSensor, maxL, 50, 0);
          motorControl(i, motor, -motor, duration);
        } else if (joysStickX[i] < maxR) { // turnRight
          motor = (int)map(joysStickX[i], 0, maxR, 50, 0);
          motorControl(i, -motor, motor, duration);
        }
      }
    }
  }
}
