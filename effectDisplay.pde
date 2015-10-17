class effectDisplay {  
  float yPos;
  float mHeight;
  final int effectMax = 14;
  int numOfLines = effectMax + 2;
  textAndBoxSize tbs = new textAndBoxSize();
  
  effect efEdit = new effect(10, 8, 180, 180, 1, 0, 300, 0); // inital values for default effect
  effectAreaMetrics eam = new effectAreaMetrics();
  effSel[] es = new effSel[effectMax];
  HSBColor[] refDisp = new HSBColor[LEDCnt];
  effect efGeneric; // generic effect for keystoke
  boolean testPatternDisplay = true;
  int testPatternStartColor = 90;
  //initialEffectColor
//Combineeffect ce = new Combineeffect();
  
  boolean mouseOver(int mX, int mY, int action) {
    boolean rtn = mY >= yPos && mY < (yPos + mHeight);
    if(rtn) {
      if(action == 0) {/*println("mouse in effectDisplay");*/ return rtn;}
      if(action == 1) {/* do something */ return rtn;}
    }
    return rtn;
  }
    
  //--------------------------------------------------------------------------------------
  // effectAreaMetrics is where all computed measurements for the effect area are stored
  // metrics need only be recomputed once when screen size changes
  
  class effectAreaMetrics {
    float totalLineHeight;
    float lineHeight;
    float widthLineID;
    float xPsEffect;
    float widthEffect;
    float totalLEDWidth;
    float LEDWidth;
    
    effectAreaMetrics() {
      totalLineHeight = 0;
      lineHeight = 0;
      widthLineID = 0;
      xPsEffect = 0;
      widthEffect = 0;
      totalLEDWidth = 0;
      LEDWidth = 0;
    }
    
    void compute() {
      totalLineHeight = mHeight / numOfLines;
      lineHeight = totalLineHeight * 0.8;
      // Compute x axis widths.
      tbs.computeSize(lineHeight);
      
      widthLineID = tbs.oneCharBoxWidth();
      xPsEffect = widthLineID * 1.2;
      widthEffect = width - xPsEffect;
      totalLEDWidth = widthEffect / LEDCnt;
      LEDWidth = totalLEDWidth * 0.9;
    }
  }
  
  //---------------------------------------------------------------------------------
  
  void setupEffectSelectAry() {
    char ch = 'A';
    for(int i = 0; i < effectMax; i++) {
      es[i] = new effSel(ch, efEdit);
      ch++;
    }
  }
  
  void setupReferenceDisplay() {
    for(int i = 0; i < refDisp.length; i++) refDisp[i] = new HSBColor();
    for(int i = 0; i < refDisp.length; i += 2) refDisp[i].set((i * 5) % 360, 100, 100);
  }
  
  void reposition() {
    eam.compute();
    for(int i = 0; i < es.length; i++) 
      es[i].computePlacement(i);
  }
  
  void drawMe() {
    noStroke();
    for(int i = 0; i < es.length; i++) es[i].itemDraw();
    displayEffectLine(refDisp, eam.xPsEffect, yPos);
  }
  
  void effectClicked() {
    // TODO: process click
    return;
  }
  
  void displayEffectLine(HSBColor[] ary, float xPs, float yPs) {
    color cc;
    
    if(ary == null) return;
    for(int i = 0; i < ary.length; i++) {
      cc = ary[i].getColor();
      fill(cc);
      rect(xPs, yPs, eam.LEDWidth, eam.lineHeight);
      xPs += eam.totalLEDWidth;
    }
  }
  
  //--------------------------------------------------------------------------------
  
  
  class effSel {
    menuItemClickable mic;
    effect eff;
    int effType;
    float xPsEff;
    float yPsEff;
  
    effSel() {
      mic = null;
      eff = null;
      effType = 0;
      xPsEff = 0;
      yPsEff = 0;
    }
  
    effSel(char ch, effect ef) {
      mic = new menuItemClickable(ch);
      eff = new effect(ef);
      if(testPatternDisplay) {
        setupTestDisplay(testPatternStartColor, eff.efAry);
        testPatternStartColor += 15;
      }
      effType = 0;
      xPsEff = 0;
      yPsEff = 0;
    }
    
    void computePlacement(int idx) {
      yPsEff = yPos + (idx + 2) * eam.totalLineHeight;
      mic.setPosition(0, yPsEff);
    }
    
    void setupTestDisplay(int startColor, HSBColor[] ary) {
      for(int i = 0; i < ary.length; i++) ary[i] = new HSBColor();
      for(int i = 0; i < ary.length; i++) ary[i].set((startColor + i * 2) % 360, 100, 100);
    }
  
    
    void itemDraw() {
      mic.itemDraw();
      displayEffectLine(eff.efAry, eam.xPsEffect, yPsEff);
    }
  }

  // menu item class
  class menuItemClickable {
    char ch;
    float xP;
    float yP;
    private float textXPos;
    private float textYPos;
    int txtSz;  // text size for this area
    float totalWidth;
    float totalHeight;
    
    menuItemClickable(char ch) {
      this.ch = ch;
      this.xP = 0;
      this.yP = 0;
    }
    
     
    void setPosition(float xPs, float yPs) {
      xP = xPs;
      yP = yPs;
      textXPos = xP + tbs.textXPos;
      textYPos = yP + tbs.textYPos;
    }
  
    void itemDraw() {
      if(mouseOver(mouseX, mouseY)) {
        fill(backgroundHighlight);
        rect(xP, yP, totalWidth, totalHeight);
        fill(fillHighlight);
      }
      else
        fill(fillNormal);
      text(ch, textXPos, textYPos);
    }
    
    
    boolean mouseOver(int mX, int mY) {
      if(mX >= xP && mX < (xP + totalWidth) && mY >= yP && 
        mY < (yP + totalHeight)) return true;
      return false;
    }
    
  }
  
}