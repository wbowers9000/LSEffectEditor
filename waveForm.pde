class waveForm {
  float yPos;
  float mHeight;
  float posLine;  // position of play line
  
  void drawMe()
  {
    // draw the waveforms
    // the values returned by left.get() and right.get() will be between -1 and 1,
    // so we need to scale them up to see the waveform
    // note that if the file is MONO, left.get() and right.get() will return the same value
    
    stroke(waveColor);
    strokeWeight(2);
    int wfvs = int(mHeight / 4);  // wave form vertical spacing
    int wfc1 = wfvs;  // wave form 1 center
    int wfc2 = wfvs * 3;  // wave form 2 center
    for(int i = 0; i < player.bufferSize() - 1; i++)
    {
      float x1 = map( i, 0, player.bufferSize(), 0, width );
      float x2 = map( i+1, 0, player.bufferSize(), 0, width );
      line( x1, yPos + wfc1 + player.left.get(i)*wfvs, x2, yPos + wfc1 + player.left.get(i+1)*wfvs );
      line( x1, yPos + wfc2 + player.right.get(i)*wfvs, x2, yPos + wfc2 + player.right.get(i+1)*wfvs );
    }
    posLine = map(player.position(), 0, player.length(), 0, width);
    float lineWidth = width / 128;
    if(lineWidth < 1) lineWidth = 1;
    noStroke();
    // draw a line to show where in the song playback is currently located
    fill(borderColor);
    rect(posLine - lineWidth / 2, yPos, lineWidth, mHeight);
    stroke(positionMarkerColor);
    strokeWeight(2);
    line(posLine, yPos, posLine, yPos + mHeight);
  }
}