

int _3DPrintHeight = 55;

//range of 3D Printer Bed
int bedXmin = 601; int bedXmax = 743;//600, 566 - 743, 422
int bedYmin = 422; int bedYmax = 566;
int bedWidth = bedXmax-bedXmin;
int bedDepth = bedYmax - bedYmin;

//range of 3D Printer Slope 
int bedslopeXmin = 680; int bedslopeXmax = 903; //680, 567 - 903, 636
int bedslopeYmin = 567; int bedslopeYmax = 636; // 

int bedslopeDepth = bedslopeXmax-bedslopeXmin;
int bedslopeWidth = bedslopeYmax - bedslopeYmin;
