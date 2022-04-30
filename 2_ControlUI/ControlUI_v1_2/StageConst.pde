//slope #12
int slopeNum = 0;
int slopePosX[];
int slopePosY[];
int slopeDir[];

int slopeWidthMat; //
int slopeLengthMat; //

int slopeMatOriginX = 2*stageWidthMax/3; // #12's Xorigin
int slopeMatOriginY = 3*stageDepthMax/4; // #12's Xorigin


//elevator #10
int elevNum = 0;
int elevPosX[];
int elevPosY[];
int elevDir[];

int elevMatWidth; //xx
int slopeMatLength; //xx

int elevMatOriginX; // #10's Xorigin
int elevMatOriginY; // #10's Xorigin


//3D Printer #11
int _3DPrinterPosX = 0;
int _3DPrinterPosY = 0;
int _3DPrinterDir = 0;

//range of 3D Printer Bed
int bedXmin = 601; 
int bedXmax = 743;//600, 566 - 743, 422
int bedYmin = 422; 
int bedYmax = 566;
int bedWidth = bedXmax-bedXmin;
int bedDepth = bedYmax - bedYmin;

//range of 3D Printer Slope 
int bedslopeXmin = 680; 
int bedslopeXmax = 903; //680, 567 - 903, 636
int bedslopeYmin = 567; 
int bedslopeYmax = 636; // 

int bedslopeWidth = bedslopeXmax-bedslopeXmin;
int bedslopeDepth = bedslopeYmax - bedslopeYmin;
