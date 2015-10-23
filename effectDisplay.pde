class effectDisplay {  
  float yPos;
  float mHeight;
  final int effectMax = 14;
  int numOfLines = effectMax + 2;
  textAndBoxSize tbs = new textAndBoxSize();
  
  final int EFFECTDROPLET = 0;
  final int EFFECTWAVE = 1;
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
  HSBColor[] dispRef = new HSBColor[LEDCnt]; // reference line
  HSBColor[] dispPlayBack = new HSBColor[LEDCnt]; // play back line
  HSBColor[] CC = new HSBColor[LEDCnt]; // generic array for reuse
  float yPosReference; // reference line
  float yPosPlayBack; // play back line
  boolean testPatternDisplay = true;
  int testPatternStartColor = 90;
  effObj efob;
  dropletSustain dSust;
  waveEffect waveE;
//Combineeffect ce = new Combineeffect();
  
  boolean mouseOver(int mX, int mY, int action) {
    boolean rtn = mY >= yPos && mY < (yPos + mHeight);
    if(rtn) {
      if(action == 0) {/*println("mouse in effectDisplay");*/ return rtn;}
      if(action == 1) {/* do something */ return rtn;}
    }
    return rtn;
  }
  //-------------------------------------------------------------------------------------
  class effObj {
    int type;  // EFFECTDROPLET or EFFECTWAVE
    Object obj;
    
    effObj(int type, Object obj) {
      this.type = type;
      this.obj = obj;
    }
    
    effObj(effObj x) {
      type = x.type;
      obj = x.obj;
    }
    
    void computeAndDraw(int time, float xPos, float yPos) {
      switch(type) {
      case EFFECTDROPLET:
        dSust = (dropletSustain) obj;
        dSust.build(time);
        displayEffectLine(dSust.efAry, xPos, yPos);
        break;
      case EFFECTWAVE:
        waveE = (waveEffect) obj;
        waveE.build(time);
        displayEffectLine(waveE.efAry, xPos, yPos);
        break;
      default:
        break;
      }
    }
    
    void setStartTime(int time) {
      switch(type) {
      case EFFECTDROPLET:
        dSust = (dropletSustain) obj;
        dSust.tStart = time;
        break;
      case EFFECTWAVE:
        waveE = (waveEffect) obj;
        waveE.tStart = time;
        break;
      default:
        break;
      }
    }
    
    
    
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
    int sustain = 1000;
    int decay = 0;

    for(int i = 0; i < effectMax; i++) {
/*      
  public dropletSustain(
    int tStart,  // start time
    int tBuild,  // build time
    int tSustain,  // sustain time
    int tDecay,  // decay time
    int locationStart,
    int spread,
    int hueStart,
    int hueEnd,
    int hueDirection
    ) {
*/      
      dSust = new dropletSustain(0, 0, sustain, decay, location, spread, startHue, startHue, 1);
      location += 8;
      if(location > LEDCnt) location = 0;
      spread++;
      if(spread > 14) spread = 6;
      startHue += 25;
      sustain += 200;
      decay += 70;
      efob = new effObj(EFFECTDROPLET, dSust);
      es[i] = new effSel(ch, efob);
      ch++;
    }
  }

  
  void setupReferenceDisplay() {
    for(int i = 0; i < dispRef.length; i++) dispRef[i] = new HSBColor();
    for(int i = 0; i < dispRef.length; i += 2) dispRef[i].set((i * 5) % 360, 100, 100);
  }


  void reposition() {
    eam.compute();
    yPosReference = yPos;
    yPosPlayBack = yPos + eam.totalLineHeight;
    for(int i = 0; i < es.length; i++) es[i].computePlacement(i);
  }
  
  // Here we do what it takes to setup the color array to display the effect on the 
  // play back line.
  // efob must be pointing to and effect object
      // TODO:
      // Vector on what mode we are in. 
      // If the player is playing, display the moving effect.
      // if the player is not playing, display the "highlight" of the effect,
      // i.e. the most prominant part of the effect.
  void drawMe() {
    noStroke();
    displayEffectLine(dispRef, eam.xPsEffect, yPosReference);  // refernce line
    // display play back line
    if(efob != null) efob.computeAndDraw(player.position(), eam.xPsEffect, yPosPlayBack);
    for(int i = 0; i < es.length; i++) es[i].drawMe();
  }
  
  void effectClicked() {
    // TODO: process click
    return;
  }
  
  // pick the effect that matches the key and display is on play back line
  void processKey(int ky, int time) {
    int i = 0;
    //println("ed.processKey() ky: " + ky + "  time: " + time);
    while(ky != es[i].esk.ch && i < es.length) i++;
    if(ky == es[i].esk.ch) {
      //println("new effect #" + i);
      es[i].eo.setStartTime(time);
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
    //effect eff;
    effObj eo;
    float xPsEff;
    float yPsEff;
  
  // is this needed?
    effSel() {
      esk = null;
      //eff = null;
      eo = null;
      xPsEff = 0;
      yPsEff = 0;
    }
  
    effSel(char ch, effObj efo) {
      esk = new effSelKey(ch);
      //eff = new effect(ef);
      eo = new effObj(efo);
/*      
      // display a test pattern for developement
      if(testPatternDisplay) {
        setupTestDisplay(testPatternStartColor, eff.efAry);
        testPatternStartColor += 15;
      }
*/      
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
      // draw example effect by computing the effect from time zero.
      if(eo != null) eo.computeAndDraw(millis() % 5000, eam.xPsEffect, yPsEff);
    }
  }

  // This class draws the key on the left side of the screen associated with an effect.
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