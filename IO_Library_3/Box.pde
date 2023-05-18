static class Box {
  
  //////////////// ATTRIBUTES ///////////////
  
  //spatial attributes
  float x=0, y=0; //position WRT parent's surface (or to screen if no parent)
  float w=0, h=0; //width & height
  float r=0;      //corner radius
  
  //drawing attributes
  boolean fill=true, stroke=true; //whether it fills & has a stroke
  float strokeWeight, textSize; //stroke weight & text size
  color fillColor, strokeColor; //fill & stroke color
  
  //other display attributes
  Text[] text = new Text[0]; //the text(s) we display on the box (empty by default)
  PImage image;              //the image to draw (null by default)
  
  //parent
  Panel parent; //the panel this is inside of
  Mmio mmio;    //the ancestor panel everything is inside of
  
  //////////////// CONSTRUCTORS ///////////////
  
  Box() { } //default constructor
  
  Box(final float x2, final float y2, final float w2, final float h2) { //constructor w/ dimensions
    x=x2; y=y2; w=w2; h=h2; //set attributes
  }
  
  //////////////// GETTERS ////////////////
  
  float getX() { return parent==null ? x : x+parent.getSurfaceX(); } //get x position WRT parent
  float getY() { return parent==null ? y : y+parent.getSurfaceY(); } //get y position WRT parent
  
  float getObjX() { return parent==null ? x : x+parent.getObjSurfaceX(); } //get x position on screen
  float getObjY() { return parent==null ? y : y+parent.getObjSurfaceY(); } //get y position on screen
  
  float getWidth () { return w; } //get width
  float getHeight() { return h; } //get height
  float getRadius() { return r; } //get radius
  
  Panel getParent() { return parent; } //get parent
  
  boolean doesFill() { return fill; }
  boolean doesStroke() { return stroke; }
  float getStrokeWeight() { return strokeWeight; } //get strokeWeight
  float getTextSize    () { return     textSize; } //get textSize
  color getFillColor  () { return fillColor;   } //get fill color
  color getStrokeColor() { return strokeColor; } //get stroke color
  
  //////////////// SETTERS ////////////////
  
  Box setX(final float x2) { x=x2; return this; } //set x
  Box setY(final float y2) { y=y2; return this; } //set y
  Box setW(final float w2) { w=w2; return this; } //set width
  Box setH(final float h2) { h=h2; return this; } //set height
  Box setR(final float r2) { r=r2; return this; } //set radius
  Box setPos(final float x2, final float y2) { x=x2; y=y2; return this; }
  
  Box setParent(final Panel p) { //set parent
    if(parent==p) { return this; } //if same parent, do nothing
    
    if(parent!=null) { parent.children.remove(this); } //if currently has a parent, estrange
    if(p!=null) { p.children.add(this); mmio=p.mmio; } //if will have parent, join family
    parent=p;                                          //set parent
    
    return this; //return result
  }
  
  Box setFill(final boolean f) { fill=f; return this; }
  Box setStroke(final boolean s) { stroke=s; return this; }
  Box setStrokeWeight(final float s) { strokeWeight=s; return this; }
  Box setTextSize(final float t) { textSize=t; return this; }
  Box setFill  (final color f) { fillColor  =f; return this; } //set fill color
  Box setStroke(final color s) { strokeColor=s; return this; } //set stroke color
  
  Box setPalette(final Box b) { //copies over all of its color & draw attributes
    fill = b.fill; stroke = b.stroke; //copy whether it has fill/stroke
    strokeWeight = b.strokeWeight;    //copy its stroke weight
    fillColor = b.fillColor; strokeColor = b.strokeColor; //copy its fill & stroke color
    return this; //return result
  }
  
  Box setShape(final Box b) { //copies over the exact shape
    w = b.w; h = b.h; r = b.r; //set the width, height, & radius
    return this;               //return result
  }
  
  Box setText(Text... texts) { //sets the texts
    text = new Text[texts.length]; //initialize array
    for(int n=0;n<texts.length;n++) { text[n] = texts[n]; } //set each element
    return this; //return result
  }
  
  ////////////////////////////// DRAWING/DISPLAY //////////////////////////////////
  
  void display(final PGraphics graph, float x2, float y2) { //displays on a particular PGraphics (whose top left corner is at x2,y2 on the parent)
    //float x3 = getObjX()-x2, y3 = getObjY()-y2; //get location where you should actually draw
    float x3 = getX()-x2, y3 = getY()-y2; //get location where you should actually draw
    setDrawingParams(graph);                    //set drawing parameters
    graph.rect(x3,y3,w,h,r);                    //draw rectangle
    
    for(Text t : text) { //loop through all the texts
      t.display(graph,-x3,-y3); //draw them all
    }
  }
  
  void setDrawingParams(final PGraphics graph) {
    if(fill) { graph.fill(fillColor); } else { graph.noFill(); }
    if(stroke) { graph.stroke(strokeColor); graph.strokeWeight(strokeWeight); } else { graph.noStroke(); }
  }
  
  
  ////////////////////////// HITBOX ///////////////////////////////////
  
  protected boolean hitboxNoCheck(final float x2, final float y2) {
    final float x3=x2-getObjX(), y3=y2-getObjY(); //get position relative to top left corner
    return x3>=0 && y3>=0 && x3<=w && y3<=h;      //determine if it's within the bounding box
  }
  
  protected boolean hitboxNoCheck(final Cursor curs) { return hitboxNoCheck(curs.x,curs.y); }
  
  boolean hitbox(final float x2, final float y2) {
    return (parent==null || parent.hitbox(x2,y2)) && hitboxNoCheck(x2,y2);
  } //if not in parent's hitbox, automatic false. Otherwise, check hitbox
  
  boolean hitbox(final Cursor curs) { return hitbox(curs.x,curs.y); }
}

static class Text {
  String text; //text
  float x, y;  //text position
  float size;  //text size
  color fill;  //text color
  int alignX, alignY; //text alignment
  
  Text(String txt, float x2, float y2, float siz, color col, int alx, int aly) { //constructor
    text = txt; x=x2; y=y2; size=siz; fill=col; alignX=alx; alignY=aly;
  }
  
  @Override
  public Text clone() {
    return new Text(text,x,y,size,fill,alignX,alignY);
  }
  
  @Override
  public boolean equals(final Object obj) {
    if(!(obj instanceof Text)) { return false; }
    Text txt = (Text)obj;
    return text.equals(txt.text) && size==txt.size && fill==txt.fill;
  }
  
  @Override
  public int hashCode() { return 961*fill+31*Float.floatToIntBits(size)+text.hashCode(); }
  
  @Override
  public String toString() { return text; }
  
  public String getText() { return text; }
  
  public void display(final PGraphics graph, float x2, float y2) { //displays itself onto the pgraphics, assuming the coordinate origin is at x2,y2 WRT the box
    graph.fill(fill); graph.textSize(size); graph.textAlign(alignX,alignY);
    graph.text(text,x-x2,y-y2);
  }
  
  
  
}

//clone, equals, hashCode, toString

//BOOL: fill, stroke
//FLOAT: strokeWeight, textSize
//COLOR: fillColor, strokeColor
//INT: textAlign, textAlignY
