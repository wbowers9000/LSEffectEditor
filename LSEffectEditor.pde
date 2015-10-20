/**
  * This sketch demonstrates how to play a file with Minim using an AudioPlayer.
  * It's also a good example of how to draw the waveform of the audio. Full documentation 
  * for AudioPlayer can be found at http://code.compartmental.net/minim/audioplayer_class_audioplayer.html
  * 
  * For more information about Minim and additional features, 
  * visit http://code.compartmental.net/minim/
  */
PFont font;
int startingGlobalFontSize = 18;  // starting point for font text sizing
int globalFontSize;  // adjusted to window percent size

import ddf.minim.*;

Minim minim;
AudioPlayer player;
waveForm wf = new waveForm();

effectDisplay ed = new effectDisplay();
effParameterChange epc = new effParameterChange();
mainMenu mm = new mainMenu();


color backgroundNormal;
color inputBoxColor;
color backgroundHighlight;
color fillNormal;
color fillHighlight;
// add colors for input box
color positionMarkerColor;
color waveColor;
color initialEffectColor;
color borderColor;
color debugColor;

final int LEDCnt = 120;
StringList LSEffect;  // light string effect in list string format
int msAdjust = 0;

int prevWindowPercentSize = 0;
int windowPercentSize = 50;
boolean sizeChange = false;

//String songName = "07  Pink - Funhouse";
String songName = "Midnight Express Vyl";
//String songName = "Mystic Rhythms";
//String songName = "CLOSE ENCOUNTERS OF THE THIRD KIND (Disco 45-) HIGH QUALITY";
//String songName = "No Cures";
//String songName = "05 - Sweet Emotion";
//String songName = "Apple Loops";

void setup()
{
  size(512, 400, P3D);
  surface.setResizable(true);
  font = loadFont("Arial-BoldMT-18.vlw");
  textFont(font);
  textSize(startingGlobalFontSize);
  
  colorMode(HSB, 360, 100, 100);
  // setup color preferences
  backgroundNormal = color(0);  // black background
  inputBoxColor = color(233, 16, 36);  // input box color
  backgroundHighlight = color(46, 49, 46); // for drawing rectangles behind text not background()
  fillNormal = color(255);  // white text
  fillHighlight = color(179, 99, 99);  // highlighted text
  positionMarkerColor = color(241, 71, 84);  // marker for wave file postion
  waveColor = color(272, 70, 99);  // sound wave color
  initialEffectColor = color(196, 99, 99);
  borderColor = color(148, 29, 49);
  debugColor = color(60, 99, 99);

  noStroke();
  background(backgroundNormal);

  mm.setupMenu();
  epc.drplt.doSetup();
  ed.setupReferenceDisplay();
  ed.setupEffectSelectAry();
  
  LSEffect = new StringList();
  minim = new Minim(this);  // to load files from data directory
  player = minim.loadFile(songName + ".mp3");
}


void draw()
{
  sizeChange = windowPercentSize != prevWindowPercentSize;
  if(sizeChange) {
    prevWindowPercentSize = windowPercentSize;
    surface.setSize(displayWidth * windowPercentSize / 100, displayHeight * windowPercentSize / 100);
    globalFontSize = int(map(startingGlobalFontSize, 0, 50, 0, windowPercentSize));
    
    int spc = height / 20;
    int spcA = 0;
    int spcH;

    spcH = 5 * spc;
    wf.yPos = spcA;
    wf.mHeight = spcH;
    spcA += spcH;
    
    spcH = 5 * spc;
    mm.yPos = spcA;
    mm.mHeight = spcH;
    spcA += spcH;
    
    spcH = 1 * spc;
    epc.yPos = spcA;
    epc.mHeight = spcH;
    spcA += spcH;
    
    spcH = 9 * spc;
    ed.yPos = spcA;
    ed.mHeight = spcH;
    ed.numOfLines = 16;
    
    mm.reposition();
    ed.reposition();
    epc.reposition();
  }
  background(backgroundNormal);  // clear screen
  mm.drawMe();
  wf.drawMe();
  ed.drawMe();
  epc.drawMe();  // effect parameter change
//  stroke(debugColor);
//  line(0, ed.yPos, width, ed.yPos);
}

void mouseClicked() {
  int mY = mouseY, mX = mouseX;
  if(mm.mouseOver(mX, mY, 1)) return;
  if(epc.mouseOver(mX, mY, 1)) return;
  if(ed.mouseOver(mX, mY, 1)) return;
}

void mouseMoved() {
  int mY = mouseY, mX = mouseX;
  if(mm.mouseOver(mX, mY, 0)) return;
  if(epc.mouseOver(mX, mY, 0)) return;
  if(ed.mouseOver(mX, mY, 0)) return;
}

void keyPressed() {
  if(key == 27) key = 0;
  int k = keyToInt(keyCode, key);
  
  if(epc.checkFocus()) {
    epc.keypress(keyCode, key);
    return;
  }
  
  println(int(keyCode), int(key), keyToInt(keyCode, key));
  
  // time sync check
  if(k >= 'A' && k <= 'Z') {
    int pp = player.position();
    int tmCheck = pp - millis() - msAdjust;
    if(tmCheck < 0) tmCheck = -tmCheck;
    if(tmCheck > 30) println("time out of sync at " + millis() + " by " + tmCheck);

    // Move effect selected by key to play back line to give user some feedback.
    // This is best done in effectDisplay object since we are mostly dealing with
    // visuals.
    ed.processKey(k, pp);
    // save key and time relative to start of song
    String effLine = nf(pp, 7) + ',' + char(k);
    LSEffect.append(effLine);
    return;
  }
  doTask(mm.keyToMenuNum(k));
}


void keyReleased() {
  int k = keyToInt(keyCode, key);
  if(k >= 'a' && k <= 'z') {
    // save key and time relative to start of song
    k = char(byte(k) - 32); // capitalize
    String effLine = nf(player.position(), 7) + ',' + k;
    LSEffect.append(effLine);  
  }
}


int keyToInt(int kc, int k) {
  if(kc == k || (kc + 0x20) == k)
    kc = k;
  else {
    kc <<= 16;
    kc += k;
  }
  //print("keyCode: " + hex(keyCode) + "  key: " + hex(key));
  //println("  combined: " + hex(kc));
  return kc;
}

void doTask(int task) {
  switch(task) {
  case 0:  // play pause
    playPause();
    break;
  case 1:  // load
    loadData();
    break;
  case 2:  // save
    saveData();
    break;
  case 3:  // save file and end program
    saveData();
    exit();
    break;
  case 4:  // abandon data
    abandonData();
    break;
  case 5:  // play from beginning
    rewind();
    break;
  case 6:  // exit program without saving data (processing default)
    exit();
    break;
  case 7:  // decrease window size
  case 8:
    windowResize(0);
    break;
  case 9:  // increase window size
  case 10:
    windowResize(1);
    break;
  default:
    break;
  }
}

void playPause() {
  // play pause
  if ( player.isPlaying() )
    player.pause();
  // if the player is at the end of the file,
  // we have to rewind it before telling it to play again
  else if ( player.position() == player.length() ) {
    player.rewind();
    player.play();
  }
  else
    player.play();
  // setup to check time against millis()    
  if(player.isPlaying()) {
    msAdjust = player.position() - millis();
    println("player.position(): " + player.position() + " millis(): " + millis() + "    msAdjust: " + msAdjust);
  }
}  

void rewind() {
  player.rewind();
  if (player.isPlaying()) {
    player.play();
  }
}

void saveData() {
  LSEffect.sort();
  String[] aa = new String[LSEffect.size()];
  for(int i = 0; i < LSEffect.size(); i++) {
    println(LSEffect.get(i));
    aa[i] = LSEffect.get(i);
  }
  saveStrings(songName + ".md1", aa);
}


void loadData() {
  LSEffect.clear();
  String[] aa = loadStrings(songName + ".md1");
  for(int i = 0; i < aa.length; i++) {
    LSEffect.append(aa[i]);    
    println(aa[i]);
  }
}

void abandonData() {
  LSEffect.clear();
}


void windowResize(int direction) {
  if (direction == 0) {
    windowPercentSize -= 10;
    if(windowPercentSize < 20) windowPercentSize = 20;
  }
  else {
    windowPercentSize += 10;
    if(windowPercentSize > 100) windowPercentSize = 100;
  }
  println("WindowPercentSize", windowPercentSize);
}