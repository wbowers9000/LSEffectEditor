class effectDisplay {  
  float yPos;
  float mHeight;
  final int effectMax = 14;
  int numOfLines = effectMax + 2;
  textAndBoxSize tbs = new textAndBoxSize();
  
  /*
  public int locationStart; 
  public int spread;
  public int hueStart; 
  public int hueEnd;
  public int hueDirection; 
  public int timeStart; 
  public int duration;
  public int timeBuild; // remaining time is decay time
 */
  
  effectAreaMetrics eam = new effectAreaMetrics();
  effSel[] es = new effSel[effectMax];
  HSBColor[] refDisp = new HSBColor[LEDCnt]; // reference line
  effect efPlayBack; // play back line
  float yPosReference; // reference line
  float yPosPlayBack; // play back line
  boolean testPatternDisplay = true;
  int testPatternStartColor = 90;
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
    int location = 8;
    int spread = 6;
    int startHue = 180;
    int duration = 3000;
    int build = 0;

    for(int i = 0; i < effectMax; i++) {
      // locationStart, spread, hueStart, hueEnd, hueDirection, timeStart, duration, timeBuild
      effect effct = new effect(location, spread, startHue, startHue, 1, 0, duration, build);
      location += 8;
      if(location > LEDCnt) location = 0;
      spread++;
      if(spread > 14) spread = 6;
      startHue += 25;
      duration += 130;
      build += 10;
      es[i] = new effSel(ch, effct);
      ch++;
    }
  }

  
  void setupReferenceDisplay() {
    for(int i = 0; i < refDisp.length; i++) refDisp[i] = new HSBColor();
    for(int i = 0; i < refDisp.length; i += 2) refDisp[i].set((i * 5) % 360, 100, 100);
  }


  void reposition() {
    eam.compute();
    yPosReference = yPos;
    yPosPlayBack = yPos + eam.totalLineHeight;
    for(int i = 0; i < es.length; i++) es[i].computePlacement(i);
  }
  
  void drawMe() {
    noStroke();
    if(ed.efPlayBack != null) {
      ed.efPlayBack.dropleteffect2(player.position());
      displayEffectLine(ed.efPlayBack.efAry, eam.xPsEffect, yPosPlayBack);  // play back line
    }
    for(int i = 0; i < es.length; i++) es[i].drawMe();
    displayEffectLine(refDisp, eam.xPsEffect, yPosReference);  // refernce line
  }
  
  void effectClicked() {
    // TODO: process click
    return;
  }
  
  
  void processKey(int ky, int time) {
    int i = 0;
    println("ed.processKey() ky: " + ky + "  time: " + time);
    while(ky != es[i].esk.ch && i < es.length) i++;
    if(ky == es[i].esk.ch) {
      println("new effect #" + i);
      ed.efPlayBack = new effect(es[i].eff);
      ed.efPlayBack.timeStart = time;
    }
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
    effSelKey esk;
    effect eff;
    int effType;
    float xPsEff;
    float yPsEff;
  
    effSel() {
      esk = null;
      eff = null;
      effType = 0;
      xPsEff = 0;
      yPsEff = 0;
    }
  
    effSel(char ch, effect ef) {
      esk = new effSelKey(ch);
      eff = new effect(ef);
      // display a test pattern for developement
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
      esk.setPosition(0, yPsEff);
    }

    void setupTestDisplay(int startColor, HSBColor[] ary) {
      for(int i = 0; i < ary.length; i++) ary[i] = new HSBColor();
      for(int i = 0; i < ary.length; i++) ary[i].set((startColor + i * 2) % 360, 100, 40);
    }
    
    void drawMe() {
      esk.drawMe();
      // draw example effect by computing the effect at time zero.
      eff.dropleteffect2(millis() % 5000);
      displayEffectLine(eff.efAry, eam.xPsEffect, yPsEff);
    }
  }

  // menu item class
  class effSelKey {
    char ch;
    float xP;
    float yP;
    private float textXPos;
    private float textYPos;
    float totalWidth;
    
    effSelKey(char ch) {
      this.ch = ch;
      this.xP = 0;
      this.yP = 0;
    }
    
     
    void setPosition(float xPs, float yPs) {
      xP = xPs;
      yP = yPs;
      textXPos = xP + tbs.textXPos;
      textYPos = yP + tbs.textYPos;
      totalWidth = tbs.charWidth + tbs.xBorder + tbs.xBorder;
    }
  
    void drawMe() {
      if(mouseOver(mouseX, mouseY)) {
        fill(backgroundHighlight);
        rect(xP, yP, totalWidth, tbs.totalHeight);
        fill(fillHighlight);
      }
      else
        fill(fillNormal);
      text(ch, textXPos, textYPos);
    }
    
    
    boolean mouseOver(int mX, int mY) {
      if(/*mX >= xP && mX < (xP + totalWidth) &&*/ mY >= yP && 
        mY < (yP + tbs.totalHeight)) return true;
      return false;
    }
    
  }
  
}