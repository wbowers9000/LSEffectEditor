// set yPos and mHeight to position the screen area
// before calling drawMe()

class effParameterChange {
  float yPos;  // one line, all y positions are the same
  float mHeight;
  float spaceBetweenParam;

  droplet drplt = new droplet();
  textAndBoxSize tbs = new textAndBoxSize();

  // action: 0 - mouse over, 1 - mouse clicked
  boolean mouseOver(int mX, int mY, int action) {
    boolean rtn = mY >= yPos && mY < (yPos + mHeight);
    if(rtn) {
      if(action == 0) {println("mouse in parameter change"); return rtn;}
      if(action == 1) {/* do something */; return rtn;}
    }
    return rtn;
  }
    

  void reposition() {
    textSize(globalFontSize);
    tbs.computeSize(textAscent() + textDescent());
    spaceBetweenParam = tbs.charWidth * 4;
    // test droplet parameter entry area
    drplt.reposition();
  }
  
  void drawMe() {
    drplt.drawMe();
  }
  
  //-------------------------------------------------------------------------  
  
  class param {
    String desc;  // description of parameter
    char type;    // type of input: 'A' alpha, '0' numeric
    float xPos;    // x position of text area
    float descWidth;
    float xPosInp;  // x position of input area
    int inputCharCnt;
    float inputWidth;
    float totalWidth;

    param() {
      desc = "";
      type = ' ';
      xPos = 0;
      descWidth = 0;
      xPosInp = 0;
      inputWidth = 0;
      totalWidth = 0;
    }
    
    void doSetup(String inDesc, char inType, int charCnt) {
    // desc: display description, type: alpha or numeric input
    // charCnt: number of characters allowed in input area
      desc = inDesc;
      type = inType;
      inputCharCnt = charCnt;
      reSize();
      xPos = 0;  // xPos is computed later
    }

    void reSize() {
      xPos = 0;
      descWidth = textWidth(desc);
      // xPosInp is relative to xPos zero, exact position computed later
      xPosInp = descWidth + tbs.charWidth;
      inputWidth = tbs.charWidth * inputCharCnt;
      totalWidth = xPosInp + inputWidth;
    }
    
    void drawMe() {
      fill(fillNormal);
      if(mouseOver(mouseX, mouseY, 0)) {
        fill(backgroundHighlight);
        rect(xPosInp, yPos, inputWidth, tbs.totalHeight);
        fill(fillHighlight);
      }
      text(desc, xPos + tbs.textXPos, yPos + tbs.textYPos);
    }
/*    
      textSize(tbs.mTextSize);
      fill(backgroundHighlight);
      rect(xPosInp, yPos, inputWidth, tbs.totalHeight);
      fill(fillNormal);
      text(desc, xPos, yPos + tbs.textYPos);
*/     
  }
  //--------------------------------------------------------------------
  // parameter input classes
  
  class droplet {
    // try and use one line to input parameters for an effect
    param[] params = new param[5];

    droplet() {
      params[0] = new param();
      params[1] = new param();
      params[2] = new param();
      params[3] = new param();
      params[4] = new param();
    }
    
    void doSetup() {
      params[0].doSetup("Hue Start", '0', 3);
      params[1].doSetup("Hue End", '0', 3);
      params[2].doSetup("Hue Dir", '0', 1);
      params[3].doSetup("Duration", '0', 5);
      params[4].doSetup("Build Time", '0', 5);
    }
    
    
    // adjust coordinates if screen is resized
    void reposition() {
      // calculations to place input parameter areas on screen
      // find a text size that will fit on a line
      float xp;
      int txtSize = tbs.mTextSize;
      do {
        float hh = tbs.totalHeight;
        // recompute metrics, changes tbs.totalHeight
        if(hh < 1) {
          hh = 40;
          println("fixed??");
        }
        tbs.computeSize(hh);
        spaceBetweenParam = tbs.charWidth * 3;
        xp = 0;
        for(int i = 0; i < params.length; i++) {
          params[i].reSize();
          xp += params[i].totalWidth + spaceBetweenParam;
        }
        println("txtSize: " + txtSize);
        txtSize--;
      } while(xp > width && txtSize > 1);
      txtSize++;
      xp -= spaceBetweenParam;
      // adjust all params so they are centered
      xp = (width - xp) / 2;
      // set the actual x coordinates
      for(int i = 0; i < params.length; i++) {
        params[i].xPos += xp;
        params[i].xPosInp += xp;
        xp += params[i].totalWidth + spaceBetweenParam;
      }
    }

    void drawMe() {
      for(int i = 0; i < params.length; i++) {
        params[i].drawMe();
      }
    }
  }
  
}