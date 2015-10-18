// set yPos and mHeight to position the screen area
// before calling drawMe()

class effParameterChange {
  float yPos;  // one line, all y positions are the same
  float mHeight;
  float spaceBetweenParam;
  float yPosInp;
  final int charSpaceBetween = 3;

  droplet drplt = new droplet();
  textAndBoxSize tbs = new textAndBoxSize();

  // action: 0 - mouse over, 1 - mouse clicked
  boolean mouseOver(int mX, int mY, int action) {
    boolean rtn = mY >= yPos && mY < (yPos + mHeight);
    if(rtn) {
      if(action == 0) {/*println("mouse in parameter change");*/ return rtn;}
      if(action == 1) {/* do something */; return rtn;}
    }
    return rtn;
  }
    

  void reposition() {
    // y position of line is 1/4 way down from yPos
    yPosInp = yPos + (mHeight / 4);  // y position of line  
    drplt.reposition();
  }
  
  void drawMe() {
    drplt.drawMe();
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

    /*
    tbs.computeSize(mHeight / 2);  // 1 line input + 1/2 line top and bottom, 2 lines total
    yPosInp = yPos + tbs.totalHeight
    spaceBetweenParam = tbs.charWidth * 4;
    */
    
    // adjust coordinates if screen is resized
    void reposition() {
      // calculations to place input parameter areas on screen
      // find a text size that will fit on a line
      //
      // count the total number of characters
      int cc = 0;
      for(int i = 0; i < params.length; i++) {
        cc += params[i].desc.length();
        cc += params[i].inputCharCnt;
        cc += charSpaceBetween + 1;  // account for spaces between parameter areas and description and input
      }
      cc -= charSpaceBetween;  // subtract extra space at the end
      // cc now has number of characters
      float maxLineHeight = mHeight * 0.5;
      int txtSize = globalFontSize + 10;
      do {
        tbs.comp(txtSize, maxLineHeight);
        txtSize = tbs.mTextSize - 1;
      } while((tbs.charWidth * cc) > width && txtSize > 2);
      // tbs.charWidth is now a text size that should work
      // resize parameter fields
      spaceBetweenParam = tbs.charWidth * charSpaceBetween;
      float xp = 0;
      for(int i = 0; i < params.length; i++) {
        params[i].reSize();
        params[i].xPos += xp;
        params[i].xPosInp += xp;
        xp += params[i].totalWidth + spaceBetweenParam;
      }
      xp -= spaceBetweenParam;
      // adjust all params so the line is centered
      xp = (width - xp) / 2;
      // set the actual x coordinates
      for(int i = 0; i < params.length; i++) {
        params[i].xPos += xp;
        params[i].xPosInp += xp;
      }
    }

    void drawMe() {
      for(int i = 0; i < params.length; i++) {
        params[i].drawMe();
      }
    }
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
      boolean mouseOv = mouseOver(mouseX, mouseY);
      fill(fillNormal);
      if(mouseOv) fill(backgroundHighlight);
      text(desc, xPos + tbs.textXPos, yPosInp + tbs.textYPos);
      fill(inputBoxColor);
      if(mouseOv) fill(backgroundHighlight);
      rect(xPosInp, yPosInp, inputWidth, tbs.totalHeight);
    }
    
    boolean mouseOver(int mX, int mY) {
      if(mX >= xPos && mX < (xPos + totalWidth) && mY >= yPosInp && 
      mY < (yPosInp + tbs.totalHeight)) return true;
      return false;
    }
  }
}