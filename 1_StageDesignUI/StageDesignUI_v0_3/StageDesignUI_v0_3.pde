import peasy.PeasyCam;
PeasyCam cam;


void setup() {
  size(1600, 950, P3D);
  frameRate(60);
  blendMode(BLEND);
  noStroke();
  smooth();
  cam = new PeasyCam(this, 400);
  
  cam.setDistance(800);

  setupStageParameter();
  setupCSV();
  
  gui();
}


void draw() {

  if (keyPressed && key == ' ') {
    cam.setMouseControlled(true);
  } else {
    cam.setMouseControlled(false);
  }

  background(20);

  updateStageParameters();
  renderStage();

  getMouseforCanvas();
  cam.beginHUD();
  cp5.draw();
  cam.endHUD();
}


void keyPressed() {

}

void mousePressed() {
  
  if (onCanvas) {
    mousePressedOnCanvas();
  }
  
}

void mouseDragged(){
 if(draggingPortal){
   portalFloor[draggedPortal] = CanvasToMatVec(new PVector(mx_, my_));
 }
 
 if(draggingWallPoint){
   if(editMode ==0){
   wallPoint[draggedWallPoint] = CanvasToMatVec(new PVector(mx_, my_));
   } else if (editMode ==1){
     under_wallPoint[draggedWallPoint] = CanvasToMatVec(new PVector(mx_, my_));
   }
 }
  
}

void mouseReleased(){
  draggingPortal = false;
}
