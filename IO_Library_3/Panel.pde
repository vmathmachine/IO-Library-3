/*
Panels are a bit different than other Boxes. A panel is composed of 3 components: the surface, the window, and the children.
The children are all the components (boxes) which are displayed as part of the panel. The surface acts like a table mat to display all the
children. The window acts as a literal window from which you can view part of the surface. The surface is at least as large as the window, and
can be moved (scrolled) around freely. Meanwhile, only the parts of the surface which are visible through the window are actually displayed.

All the attributes inherited from box apply to the window. fill is false by default, but you can set it to true to cover up the surface. Or, if fillColor is partially transparent, you can use it
to give you a tinted window.

There are also some attributes which were created solely for describing the surface. Namely its position WRT the window, its dimensions, and its background fill
*/

static class Panel extends Box implements java.lang.Iterable<Box> {
  
  ////////////////////// ATTRIBUTES ////////////////////////
  
  HashSet<Box> children = new HashSet<Box>(); //all the boxes nested in this panel
  
  //surface attributes
  float surfaceX=0, surfaceY=0; //position of surface
  float surfaceW=0, surfaceH=0; //dimensions of surface
  boolean surfaceFill=true;     //whether to fill the surface
  color surfaceFillColor;       //fill color of surface
  
  SwipeMode swipeModeX = SwipeMode.NONE, swipeModeY = SwipeMode.NONE; //the swipe mode for this panel, both in the x and y directions. On PC, swiping usually doesn't exist
  float surfaceXi=0, surfaceYi=0;       //"initial" position of surface, position when a touch was initialized
  ArrayList<Cursor> pointers = new ArrayList<Cursor>(); //arraylist of all the cursors that are dragging around this surface
  //this is called pointers and not cursors because MMIO already has an arraylist called cursors, and it's used for something else. We don't want that to override this
  
  boolean canMouseScroll = true; //whether you can scroll with the mouse
  
  float pixPerClick; //how many pixels you move per movement of the mouse wheel
  
  ////////////////////// CONSTRUCTORS //////////////////////
  
  Panel() { super(); fill=false; } //by default, you don't fill in the window.
  
  Panel(final float x2, final float y2, final float w2, final float h2, final float w3, final float h3) { super(x2,y2,w2,h2); surfaceX=surfaceY=0; surfaceW=w3; surfaceH=h3; fill=false; initPixPerClick(); } //constructor w/ dimensional parameters
  
  Panel(final float x2, final float y2, final float w2, final float h2) { this(x2,y2,w2,h2,w2,h2); } //constructor w/ fewer dimensional parameters
  
  ////////////////////// GETTERS //////////////////////
  
  float getSurfaceX() { return surfaceX; } //gets position of surface (in x direction)
  float getSurfaceY() { return surfaceY; } //gets position of surface (in x direction)
  float getSurfaceW() { return surfaceW; } //gets width of surface
  float getSurfaceH() { return surfaceH; } //gets height of surface
  float getObjSurfaceX() { return getObjX()+surfaceX; } //gets objective position of surface (in x direction)
  float getObjSurfaceY() { return getObjY()+surfaceY; } //gets objective position of surface (in y direction)
  
  ////////////////////// SETTERS //////////////////////
  
  Panel setSurfaceW(final float w2) { surfaceW=w2; return this; }
  Panel setSurfaceH(final float h2) { surfaceH=h2; return this; }
  Panel setSurfaceDims(final float w2, final float h2) { surfaceW=w2; surfaceH=h2; return this; }
  
  Panel setScrollX(final float x2) { surfaceX=x2; return this; }
  Panel setScrollY(final float y2) { surfaceY=y2; return this; }
  Panel setScroll(final float x2, final float y2) { surfaceX=x2; surfaceY=y2; return this; }
  
  Panel setSurfaceFill(boolean s) { surfaceFill=s; return this; }
  Panel setSurfaceFill(color s) { surfaceFillColor=s; return this; }
  
  void shiftSurface(final float x2, final float y2) {
    surfaceX = constrain(surfaceX+x2, w-surfaceW, 0);
    surfaceY = constrain(surfaceY+y2, h-surfaceH, 0);
  }
  
  Panel setPixPerClick(final float p) { pixPerClick = p; return this; } //sets the rate of pixels scrolled per click of the mouse (negative means inverted scrolling)
  
  Panel setSwipeMode(final SwipeMode sx, final SwipeMode sy) { swipeModeX = sx; swipeModeY = sy; return this; } //sets the swiping mode
  
  ////////////////////// DRAWING/DISPLAY //////////////////////
  
  void display(PGraphics graph, float x2, float y2) {
    
    if(surfaceFill) { graph.fill(surfaceFillColor); } else { graph.noFill(); } //set drawing attributes
    graph.noStroke(); //no stroke, we draw the border afterward
    
    graph.rect(getX()-x2, getY()-y2, w, h); //draw the surface background, constrained to within the window
    
    for(Box b : this) { //loop through all children
      displayChild(b, graph, x2, y2); //display each child
    }
    
    super.display(graph, x2, y2); //finally, draw the window over it all
    
    //if(this instanceof Mmio) { println(h, surfaceH); }
  }
  
  void displayChild(Box b, PGraphics graph, float x2, float y2) { //displays the child
    
    final byte out = outCode(b.x+surfaceX,b.y+surfaceY,b.w,b.h,w,h); //use compressed cohen-sutherland algorithm to generate 5-bit outcode
    
    if((out&16)!=16) { //skip all boxes that are completely out of bounds
      if(out==0) { b.display(graph, x2-x, y2-y); } //if box is completely in bounds: display it on the same PGraphics object
      else { //otherwise:
        float buffWid = ((out&4)==4 ? w-surfaceX : b.x+b.w) - ((out&8)==8 ? -surfaceX : b.x), //calculate minimum buffer width
              buffHig = ((out&1)==1 ? h-surfaceY : b.y+b.h) - ((out&2)==2 ? -surfaceY : b.y); //and minimum buffer height
        
        //println(h, b.y, surfaceY);
        
        if((out&12)==12 || (out&3)==3) { throw new RuntimeException("ERROR: box is clipped left & right or up & down. Such behavior is not yet implemented, try to make children smaller than their parents!"); }
        
        byte p=0; //the smallest power of 2 whose dimensions can fit this buffered display
        while(buffWid>(1<<p) || buffHig>(1<<p)) { ++p; //continually increment p until we find a power of 2 at least as big as our dimensions
          if(p==32) { throw new RuntimeException("ERROR: buffer dims are "+buffWid+"x"+buffHig+", which exceed the integer maximum. How the fuck did you do this?"); }
        }
        
        Buffer buff = loadBuffer(p); //Load the smallest buffer of at least size 2^p. If none are available, create your own one and add it to the list
        
        float x3 = b.x+surfaceX+((out&4)==4 ? buffWid-buff. width() : b.w-buffWid), //calc x pos of buffer (WRT panel)
              y3 = b.y+surfaceY+((out&1)==1 ? buffHig-buff.height() : b.h-buffHig); //calc y pos of buffer (WRT panel)
        
        buff.beginDraw(); //put buffer in use & begin drawing
        b.display(buff.graph, x3, y3); //display button onto buffer
        //buff.graph.noFill(); buff.graph.strokeWeight(3); buff.graph.stroke(#FF00FF); buff.graph.rect(0,0,buff.graph.width,buff.graph.height);
        buff.endDraw(); //finish drawing buffer
        
        graph.image(buff.graph, x3+getX()-x2, y3+getY()-y2); //display the buffer in the correct location
        //TODO check the math to make sure all the coordinates and dimensions are correct. In the process, you might even end up optimizing the math. Who knows?
        
        buff.usent();   //put buffer out of use
      }
    }
  }
  
  Buffer loadBuffer(byte p) {
    Buffer buff = null; //the buffer we'll be using to draw this crap
    Outer: {            //label the outermost of 2 loops
      for(int ind = p; ind < mmio.buffers.size(); ind++) { //loop through all buffers that are at least big enough to draw this clipped object, find the first one that isn't in use
        for(Buffer buff2 : mmio.buffers.get(ind)) {        //loop through all buffers in each array
          if(!buff2.isInUse()) { buff = buff2; break Outer; } //the first one we find that isn't in use, set that to our buffer, break to the outer loop
        }
      }
    }
    if(buff==null) { //if there were no available buffers:
      mmio.buffers.ensureCapacity(p+1); //first, make sure the buffer array is big enough
      while(mmio.buffers.size()<=p) { mmio.buffers.add(new ArrayList<Buffer>()); }
      //TODO change it so the buffer is always big enough. Do this by manipulating it upon each instantiation and resize
      
      buff = new Buffer(mmio.app, 1<<p, 1<<p); //set our buffer to a newly loaded one of adequate size
      mmio.buffers.get(p).add(buff);           //add said buffer to the list
    }
    
    return buff; //return result
  }
  
  ////////////////////// SWIPING FUNCTIONALITY ////////////////////
  
  void press(final Cursor curs) { //responds to cursor press
    if(!hitbox(curs)) { return; } //if cursor not inside, exit TODO see if this is necessary AND see if you can use hitboxNoCheck
    
    if(pointers.size()==0) { //if this panel has no pointers:
      surfaceXi = surfaceX; surfaceYi = surfaceY; //set our initial surface position
    }
    else { //if this panel DOES have pointers:
      //TODO add this. You know, once you figure out how it works...
    }
    pointers.add(curs); //in any case, add this cursor to our list of pointers
  }
  
  void release(final Cursor curs) { //responds to cursor release
    if(!pointers.contains(curs)) { return; } //if cursor is not in pointer list, exit TODO see if this is even remotely necessary
    
    if(pointers.size()!=1) { //if this isn't the only pointer:
      //TODO add what goes here
    } //otherwise, no adjustments are necessary
    
    pointers.remove(curs); //remove this cursor from our list of pointers
  }
  
  void updateSwipe() { //performs updates once per frames based on swiping functionality
    switch(swipeModeX) { //what we do depends on the swipe mode
      case NONE: break; //none: never do anything
      case NORMAL: if(pointers.size()!=0) { //normal: only do something if there are pointers
        float mean = 0; //first, we compute the mean of all the cursors' positions that are pointed at us (minus their initial positions)
        for(Cursor c : pointers) { mean+=c.x-c.xi; } //add them all up
        mean/=pointers.size(); //divide by how many there are
        surfaceX = constrain(surfaceXi+mean,w-surfaceW,0); //move the surface to its initial position plus that shift
      } break;
      case ANDROID: {
        //TODO this
      } break;
      case IOS: {
        //TODO this
      } break;
      case SWIPE: {
        //TODO this
      } break;
    }
    
    switch(swipeModeY) { //what we do depends on the swipe mode
      case NONE: break; //none: never do anything
      case NORMAL: if(pointers.size()!=0) { //normal: only do something if there are pointers
        float mean = 0; //first, we compute the mean of all the cursors' positions that are pointed at us (minus their initial positions)
        for(Cursor c : pointers) { mean+=c.y-c.yi; } //add them all up
        mean/=pointers.size(); //divide by how many there are
        surfaceY = constrain(surfaceYi+mean,h-surfaceH,0); //move the surface to its initial position plus that shift
      } break;
      case ANDROID: {
        //TODO this
      } break;
      case IOS: {
        //TODO this
      } break;
      case SWIPE: {
        //TODO this
      } break;
    }
  }
  
  ////////////////////// OTHER //////////////////////
  
  java.util.Iterator<Box> iterator() {
    return children.iterator();
  }
  
  void initPixPerClick() { pixPerClick = surfaceH*0.03; }
}

/*static byte intersection(float xin, float yin, float win, float hin, float wout, float hout) { //describes the way in which two surfaces intersect
  if(xin> wout || yin> hout || xin+win< 0 || yin+hin< 0) { return 0; } //0 = completely outside
  if(xin>=0 && yin>=0 && xin+win<=wout && yin+hin<=hout) { return 2; } //2 = completely inside
  return 1; //1 = intersects border
}*/

static byte outCode(float xin, float yin, float win, float hin, float wout, float hout) { //yields a 5-bit outcode describing how two boxes intersect, assuming (xout,yout)=(0,0)
  return (byte)((xin>wout || yin>hout || xin+win<0 || yin+hin<0 ? 16 : 0) | //bit 1: whether box is completely out of bounds
                                                      (xin<   0 ?  8 : 0) | //bit 2: whether left edge is left of clipping plane
                                                      (xin+win>wout ?  4 : 0) | //bit 3: whether right edge is right of clipping plane
                                                      (yin<   0 ?  2 : 0) | //bit 4: whether top edge is above clipping plane
                                                      (yin+hin>hout ?  1 : 0)); //bit 5: whether bottom edge is below clipping plane
}

static enum SwipeMode { NONE, NORMAL, ANDROID, IOS, SWIPE };
//the modes that you can use to swipe with your cursor: no swiping, normal (no momentum), android style, iOS style, and swipe between screens (like on a home screen)

///movement modes: PC, Android, iOS, basicSmartphone
