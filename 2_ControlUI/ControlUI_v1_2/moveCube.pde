//helper functions to drive the cubes 
//not used for the class

boolean rotateCube(int id, float ta) {
  float diff = ta-cubes[id].deg;
  if (diff>180) diff-=360;
  if (diff<-180) diff+=360;
  if (abs(diff)<3) return true;
  int dir = 1;
  float strength = int(abs(diff) / 14);
  //println("diff = " + diff + ", strength = " + strength);
  //strength = 1;//
  if (diff<0)dir=-1;

  float left = ( 6*(strength)*dir);
  float right = (-6*(strength)*dir);
  int duration = 100;
  motorControl(id, left, right, duration);
  //motorControl(2, left, right, duration);
  //println("rotate false "+diff +" "+ id+" "+ta +" "+cubes[id].deg);
  return false;
}


// the most basic way to move a cube to target position
// speed is constant
boolean aimCube(int id, float tx, float ty) {
  fill(0, 255, 0);
  ellipse(tx, ty, 10, 10);
  
  if (cubes[id].distance(tx, ty)<20) return true;
  int[] lr = cubes[id].aim(tx, ty);

  float left = (lr[0]*.5);
  float right = (lr[1]*.5);
  int duration = (100);
  motorControl(id, left, right, duration);
  return false;
}


// the most basic way to move a cube to target position
// speed is variable 
boolean aimCubeSpeed(int id, float tx, float ty) {
  fill(0, 255, 0);
  ellipse(tx, ty, 10, 10);
  
  float dd = cubes[id].distance(tx, ty)/100.0;
  dd = min(dd, 1);
  if (dd <.10) return true;


  int[] lr = cubes[id].aim(tx, ty);

  float left = (lr[0]*dd);
  float right = (lr[1]*dd);
  int duration = (100);
  motorControl(id, left, right, duration);
  
  return false;
}


boolean aimCubeSpeedDup(int id, int id2, float tx, float ty) {
  fill(0, 255, 0);
  ellipse(tx, ty, 10, 10);
  
  float dd = cubes[id].distance(tx, ty)/100.0;
  dd = min(dd, 1);
  if (dd <.10) return true;


  int[] lr = cubes[id].aim(tx, ty);

  float left = (lr[0]*dd);
  float right = (lr[1]*dd);
  int duration = (100);
  motorControl(id, left, right, duration);
  motorControl(id2, left, right, duration);
  motorControl(3, left, right, duration);
  return false;
}

boolean rotateCubeDup(int id, int id2, float ta) {
  float diff = ta-cubes[id].deg;
  if (diff>180) diff-=360;
  if (diff<-180) diff+=360;
  if (abs(diff)<3) return true;
  int dir = 1;
  float strength = int(abs(diff) / 14);
  //println("diff = " + diff + ", strength = " + strength);
  //strength = 1;//
  if (diff<0)dir=-1;

  float left = ( 6*(strength)*dir);
  float right = (-6*(strength)*dir);
  int duration = 100;
  motorControl(id, left, right, duration);
  motorControl(id2, left, right, duration);
  motorControl(3, left, right, duration);
  //println("rotate false "+diff +" "+ id+" "+ta +" "+cubes[id].deg);
  return false;
}
