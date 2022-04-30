Cube[] cubes;

int nCubes = 10;


void setupCube() {
  //create cubes
  cubes = new Cube[nCubes];
  for (int i = 0; i< cubes.length; ++i) {
    cubes[i] = new Cube(i, true);
  }
}


class Cube {
  int x;
  int y;
  int prex;
  int prey;
  float targetx =-1;
  float targety =-1;
  boolean moveTo = false;


  int floor = 0; // 0 -> 1st floor, -1 -> understage, 2 -> slope, ///3-> elevator, 4 -> 3D printer, 5 -> 3D Printer's Slope
  int preFloor = 0;

  int stageX = 0; //
  int stageY = 0; //
  int portalID = -1; //

  boolean buttonState = false;


  boolean collisionState = false;
  boolean tiltState = false;


  boolean isLost = true;

  int id;
  int deg;
  long lastUpdate;
  int count=0;

  Cube(int i, boolean lost) {
    id = i;
    isLost=lost;

    lastUpdate = System.currentTimeMillis();
  }
  void resetCount() {
    count =0;
  }

  boolean isAlive(long now) {
    return(now < lastUpdate+200);
  }


  //TODO: add offset?
  void setStageCoordinate() {


    //first check if the toio is on slope, elevator, 3DP
    boolean flag = false;

    //println(slopeNum);
    if (slopeNum>0 && UnderStage) {
      //println("TESt");
      for (int i = 0; i<slopeNum; i++) {
        // singleMatWidth / singleMatDepth
        // slopeMatOriginX, slopeMatOriginY


        //println(i, x, y);
        if (slopeMatOriginX +  i* (singleMatWidth/6) < x && x< slopeMatOriginX +  (i+1)* (singleMatWidth/6) && slopeMatOriginY < y) {
          portalID = i;

          floor = 2;

          stageX = x - (slopeMatOriginX +  i* (singleMatWidth/6));
          stageY = y - slopeMatOriginY;
          println(i, stageX, stageY);

          flag = true;
        }
      }
    } else if (elevNum>0 && UnderStage) {
      floor = 3;
    } else if (_3DP) {
    }
    if (flag == false) {
      if (x < stageWidth && y < stageDepth) {
        floor = 0;
        stageX = x;
        stageY = y;
      } else if (UnderStage && x < stageWidth && (stageDepth <= y & y < stageDepth*2)) {
        floor = -1;
        stageX = x;
        stageY = y - stageDepth;
      }
    }
  }



  //This function defines how the cubes aims at something
  //the perceived behavior will strongly depend on this
  int[] aim(float tx, float ty) {
    int left = 0;
    int right = 0;
    float angleToTarget = atan2(ty-y, tx-x);
    float thisAngle = deg*PI/180;
    float diffAngle = thisAngle-angleToTarget;
    if (diffAngle > PI) diffAngle -= TWO_PI;
    if (diffAngle < -PI) diffAngle += TWO_PI;
    //if in front, go forward and
    //println(diffAngle);
    if (abs(diffAngle) < HALF_PI) {
      //in front
      float frac = cos(diffAngle);

      //println(frac);
      if (diffAngle > 0) {
        //up-left
        left = floor(100*pow(frac, 2));
        right = 100;
      } else {
        left = 100;
        right = floor(100*pow(frac, 2));
      }
    } else {
      //face back
      float frac = -cos(diffAngle);
      if (diffAngle > 0) {
        left  = -floor(100*frac);
        right =  -100;
      } else {
        left  =  -100;
        right = -floor(100*frac);
      }
    }


    //println(left +" " + right);
    int[] res = new int[2];
    res[0] = left;
    res[1] = right;
    return res;
  }
  float distance(Cube o) {
    return distance(o.x, o.y);
  }

  float distance(float ox, float oy) {
    return sqrt ( (x-ox)*(x-ox) + (y-oy)*(y-oy));
  }
}
