// "final" is the same as c++ "constant"
// processing does not recognize "enum"
final int cBLEND = 0;
final int cAVERAGE = 1;
final int cFIRST = 2;  // first to appear
final int cLAST = 3;   // last to appear

private static HSBColor[] ceAry;

// Arrays must come in time order, first to last.
// The array in this class holds the accumulation of the effects.

class Combineeffect {
  
  HSBColor clrAcc = new HSBColor();  // color accumulator (because we can't return a non primative)
 
  
  Combineeffect() {
    ceAry = new HSBColor[LEDCnt];
    for(int i = 0; i < ceAry.length; i++) ceAry[i] = new HSBColor();
    resetToZero();
  }

  
  void resetToZero() {
    for(int i = 0; i < ceAry.length; i++) ceAry[i].reset();
  }
  
  
  void get(HSBColor[] aa) {
    for(int i = 0; i < ceAry.length; i++) aa[i].set(ceAry[i]);
  }


  void combine(int combineType, effect ef, int tm) {
    if(ef.active(tm)) combine(combineType, ef.efAry);
  }

  void combine(int combineType, HSBColor [] ica) {
    for(int i = 0; i < ica.length; i++) ceAry[i].combine(combineType, ica[i]);
  }
  
}