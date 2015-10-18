// set yPos when known
class mainMenu {
  float yPos;
  float mHeight;
  textAndBoxSize tbs = new textAndBoxSize();
  
  // action: 0 - mouse over, 1 - mouse clicked
  boolean mouseOver(int mX, int mY, int action) {
    boolean rtn = mY >= yPos && mY < (yPos + mHeight);
    if(rtn) {
      if(action == 0) {/*println("mouse in mainMenu");*/ return rtn;}
      if(action == 1) {doTask(menuItemClicked(mX, mY)); return rtn;}
    }
    return rtn;
  }
    
  class menuItem {
    String iText;
    float xPs;  // set in repostion()
    float yPs;  // set in repostion()
    float tWidth;  // set in repostion()
    int toKey;
    
    menuItem() {
      iText = "";
      xPs = 0;
      yPs = 0;
      tWidth = 0;
      toKey = 0;
    }
    
    menuItem(String iText, int toKey) {
      this.iText = iText;
      this.tWidth = int(textWidth(iText));
      this.toKey = toKey;
    }

    void itemDraw() {
      fill(fillNormal);
      if(mouseOver(mouseX, mouseY)) {
        fill(backgroundHighlight);
        rect(xPs, yPs, tWidth, tbs.totalHeight);
        fill(fillHighlight);
      }
      text(iText, xPs + tbs.textXPos, yPs + tbs.textYPos);
    }
  
    boolean mouseOver(int mX, int mY) {
      if(mX >= xPs && mX < (xPs + tWidth) && mY >= yPs && 
      mY < (yPs + tbs.totalHeight)) return true;
      return false;
    }
  
    void display() {
      println(iText + "  xPs: " + xPs + "  yPs: " + yPs + "  tWidth: " + tWidth + 
        "  toKey: " + hex(toKey));      
    }
  }
  
  
  
  ArrayList<menuItem> mItm = new ArrayList<menuItem>();
  
  void setupMenu() {
    String system = System.getProperty("os.name").toString();
    if (system.indexOf("Windows") != -1) {
      mItm.add(new menuItem("SPACE: pause / playback", int(' ')));
      mItm.add(new menuItem("ctrl-l: load data", 0x004C000C));
      mItm.add(new menuItem("ctrl-s: save data", 0x00530013));
      mItm.add(new menuItem("END: save file and end program", 0x00030000));
      mItm.add(new menuItem("DELETE: abandon unsaved data", 0x00930000));
      mItm.add(new menuItem("ENTER: play from beginning", 0xD));
      mItm.add(new menuItem("ESC: exit", 0x1B));
      mItm.add(new menuItem("'-': decrease window size", 0x008C002D));
      mItm.add(new menuItem("", 0x2D));
      mItm.add(new menuItem("'+': increase window size", 0x008B002B));
      mItm.add(new menuItem("", 0x003D002B)); // second code for '+'
    } else if (system.indexOf("Mac OS X") != -1) {
      mItm.add(new menuItem("space: pause / playback", int(' ')));
      mItm.add(new menuItem("fn-left (home): load data", 194345));
      mItm.add(new menuItem("fn-right (end): save data", 259883));
      mItm.add(new menuItem("tab: save file and end program", 9));
      mItm.add(new menuItem("delete: abandon unsaved data", 8));
      mItm.add(new menuItem("return: play from beginning", 10));
      mItm.add(new menuItem("esc: exit", 1769472));
      mItm.add(new menuItem("'-': decrease window size", 45));
      mItm.add(new menuItem("", 2949215));
      mItm.add(new menuItem("'+': increase window size", 61));
      mItm.add(new menuItem("", 3997739)); // second code for '+'
    } else {
      // XXX Currently using Windows keys
      mItm.add(new menuItem("SPACE: pause / playback", int(' ')));
      mItm.add(new menuItem("ctrl-l: load data", 0x004C000C));
      mItm.add(new menuItem("ctrl-s: save data", 0x00530013));
      mItm.add(new menuItem("END: save file and end program", 0x00030000));
      mItm.add(new menuItem("DELETE: abandon unsaved data", 0x00930000));
      mItm.add(new menuItem("ENTER: play from beginning", 0xD));
      mItm.add(new menuItem("ESC: exit", 0x1B));
      mItm.add(new menuItem("'-': decrease window size", 0x008C002D));
      mItm.add(new menuItem("", 0x2D));
      mItm.add(new menuItem("'+': increase window size", 0x008B002B));
      mItm.add(new menuItem("", 0x003D002B)); // second code for '+'
    }
  }
  
  
  void reposition() {
    menuItem mi;
    float xp, yp;
    int numberOfLines, numberOfMenuLines, cntMenuItems;

    cntMenuItems = 0;
    for(int i = 0; i < mItm.size(); i++) {
        mi = mItm.get(i);
        if(mi.tWidth != 0) cntMenuItems++;
    }
    numberOfMenuLines = cntMenuItems / 2;
    if((numberOfMenuLines * 2) != cntMenuItems) numberOfMenuLines++;
    numberOfLines = numberOfMenuLines + 1; // number of lines plus 1/2 line top and bottom
    float targetHeight = mHeight / numberOfLines;
    tbs.comp(globalFontSize + 10, targetHeight); // compute text and box size
    float startingYPos = yPos + tbs.totalHeight * 0.5;
    xp = 10;
    int idxItm = 0;
    for(int n = 0; n < 2; n++) {
      yp = startingYPos;
      for(int i = 0; i < numberOfMenuLines; i++) {
        mi = mItm.get(idxItm);
        if(mi.tWidth != 0) {
          mi.xPs = xp;
          mi.yPs = yp;
          yp += tbs.totalHeight;
        }
        idxItm++;
        if(idxItm >= mItm.size()) break;
      }
      xp = width / 2 + 10;
    }
  }
  
  void drawMe() {
    menuItem mi;
    for (int i = 0; i < mItm.size(); i++) {
      mi = mItm.get(i);
      if(mi.tWidth != 0) mi.itemDraw();
    }
  }
  
  
  int keyToMenuNum(int kk) {
    menuItem mi;
    
    for (int i = 0; i < mItm.size(); i++) {
      mi = mItm.get(i);
      if(mi.toKey == kk) return i; 
    }
    return -1;
  }
  
  int menuItemClicked(int mX, int mY) {
    menuItem mi;
    
    for (int i = 0; i < mItm.size(); i++) {
      mi = mItm.get(i);
      if(mi.mouseOver(mX, mY)) return i; 
    }
    return -1;
  }
}