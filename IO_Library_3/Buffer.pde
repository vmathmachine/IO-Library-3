static class Buffer {
  PGraphics graph;        //PGraphics object to load pixels onto
  boolean inUse   =false; //whether it's currently in use
  boolean canWrite=false; //whether the PGraphics is writeable
  byte usage=0;           //a record of whether is was used in the last 8 garbage collection cycles
  
  Buffer(PApplet app, int w, int h) {
    graph = app.createGraphics(w,h); //load graphics buffer
  }
  
  /*boolean beginDraw() { //attempts to beginDraw, returns success flag
    if(inUse) { return false; }              //if in use, return false
    graph.beginDraw(); inUse=true; usage|=1; //begin draw, is now in use, stamp usage recorder
    return true;                             //return true
  }
  
  boolean endDraw() { //attempts to endDraw, returns success flag
    if(!inUse) { return false; }  //if not in use, return false
    graph.endDraw(); inUse=false; //end draw, is now not in use
    return true;                  //return true
  }*/
  //TODO cleanup (remove these /|\)
  
  //GETTERS//
  
  PGraphics getGraphics() { return graph; }
  boolean isInUse() { return inUse; }
  byte getUsage() { return usage; }
  int width() { return graph.width; }
  int height() { return graph.height; }
  
  //SETTERS//
  
  void stamp() { usage|=1; } //stamps to show it's been used
  void step() { usage<<=1; } //takes 1 step: shift bits of usage recorder
  
  void use() { inUse=true; usage|=1; } //sets that it's in use
  void beginDraw() { inUse=canWrite=true; usage|=1; graph.beginDraw(); graph.background(0x00FFFFFF); } //sets that it's in use AND starts editing PGraphics object (starting with clearing the background completely)
  void endDraw()   { canWrite=false; graph.endDraw();  } //stops editing PGraphics object
  void usent() { inUse=false; } //sets that it's no longer in use (usen't)
}
