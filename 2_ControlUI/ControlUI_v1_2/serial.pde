import processing.serial.*;
Serial myPort; // シリアルポート

void serialSetup(){
    println(Serial.list());
  //myPort = new Serial(this, Serial.list()[3], 9600);
  myPort = new Serial(this, "/dev/cu.usbmodem141401", 9600);
  //myPort = new Serial(this, "COM5", 9600);
  // 改行コード(\n)が受信されるまで、シリアルメッセージを受けつづける
  myPort.bufferUntil('\n');
  
}


void serialEvent(Serial myPort) { 
  // シリアルバッファーを読込み
  String myString = myPort.readStringUntil('\n');
  // 空白文字など余計な情報を消去
  myString = trim(myString);
  // コンマ区切りで複数の情報を読み込む
  int val[] = int(split(myString, ','));
  // 読み込んだ情報の数だけ、配列に格納
  if (val.length > 8) {
   // for(int i = 0; i < 6; i++){
      println("received: ", val[0], val[1], val[2], val[3], val[4], val[5]);
      
      for(int i = 0; i < joyStickNum; i++){
      
      joysStickX[i] = val[i*3];
      joysStickY[i] = val[i*3+1];
      joyStickSwitch[i] = val[i*3+2];
      
      }
   // }
  }
  // 読込みが完了したら、次の情報を要求
  myPort.write("A");
}
