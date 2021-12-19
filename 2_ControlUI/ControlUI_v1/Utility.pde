PVector CanvasToMatVec(PVector w) {
  PVector tt = new PVector(0, 0);
  tt.x = map(w.x, 0, canvasWidth, 0, stageWidthMax);
  tt.y = map(w.y, 0, canvasHeight, 0, stageDepthMax);
  return tt;
}

PVector MatToCanvasVec(PVector w) {
  PVector tt = new PVector(0, 0);
  tt.x = map(w.x, 0, stageWidthMax, 0, canvasWidth);
  tt.y = map(w.y, 0, stageDepthMax, 0, canvasHeight);
  return tt;
}

int MatToCanvasIntW(int i) {
  int ii = 0; 
  ii = (int)map(i, 0, stageWidthMax, 0, canvasWidth);
  return ii;
}

int MatToCanvasIntD(int i) {
  int ii = 0; 
  ii = (int)map(i, 0, stageDepthMax, 0, canvasHeight);
  return ii;
}


int boolToInt(boolean b){
 int i = 0;
 
 if(b == true){
  i = 1; 
 }
  return i;
}
