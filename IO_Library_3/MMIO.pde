static class Mmio extends Panel { //the top level parent of all the IO objects in here, and the class solely responsible for all the IO functionality
  
  final PApplet app; //the applet this runs in
  
  //Panel drag;   //which panel we're dragging (if any) TODO remove me
  
  
  int wheelEvent = 0; //how many scrolls of the wheel occurred in the last frame
  
  ArrayList<ArrayList<Buffer>> buffers = new ArrayList<ArrayList<Buffer>>(); //array of arrays of buffers used to buffer items partially off screen
  //each inner array contains buffer objects whose dimensions are powers of 2. Which power? It depends on the index of the outermost array
  
  ArrayList<Cursor> cursors = new ArrayList<Cursor>();
  
  Mmio(final PApplet a) {
    app = a; mmio = this;
  }
  
  void display(PGraphics graph, float x2, float y2) {
    //first, record all the PGraphics's original drawing parameters
    final boolean fill2 = graph.fill, stroke2 = graph.stroke;
    final color fillColor2 = graph.fillColor, strokeColor2 = graph.strokeColor;
    final float strokeWeight2 = graph.strokeWeight, textSize2 = graph.textSize;
    final int textAlign2 = graph.textAlign, textAlignY2 = graph.textAlignY;
    
    super.display(graph, x2, y2); //next, display
    
    //finally, reset all the PGraphics's original drawing parameters
    graph.fill(fillColor2); if(!fill2) { graph.noFill(); }
    graph.stroke(strokeColor2); graph.strokeWeight(strokeWeight2); if(!stroke2) { graph.noStroke(); }
    graph.textSize(textSize2); graph.textAlign(textAlign2, textAlignY2);
  }
  
  void display() {
    super.display(app.g, 0,0);
  }
  
  /*static void updateButtons(Panel p, int mouseX, int mouseY, boolean mousePressed) { //looks through all buttons in a panel and updates accordingly
    if(!p.hitbox(mouseX,mouseY)) { return; } //if mouse is not in hitbox, skip
    
    for(Box b : p) { //loop through all the boxes in the panel
      if(b instanceof Panel) { updateButtons((Panel)b, mouseX, mouseY, mousePressed); } //if b is a panel: update all the buttons in b
      else if(b instanceof Button) {                                                    //if b is a button: update it
        Button butt = (Button)b; //cast to a button
        if(!butt.hitboxNoCheck(mouseX,mouseY)) { butt.progress.update(State. DEAD); } //case 1: mouse isn't on it: it's dead
        else if(mousePressed)                  { butt.progress.update(State.PRESS); } //case 2: the mouse is on it AND it's pressed: it's pressed
        else                                   { butt.progress.update(State.HOVER); } //case 3: the mouse is on it and it's NOT pressed: it's hovered
      }
    }
  }*/
  
  /*void updateCursorsAndroid(Pointer[] touches) {
    int ind = 0; //this represents our index as we iterate through both the touches list & the cursors list
    ArrayList<Cursor> adds = new ArrayList<Cursor>(), //arraylists of the cursors we add,
                      subs = new ArrayList<Cursor>(), //subtract,
                      movs = new ArrayList<Cursor>(); //and move
    
    while(ind<touches.length || ind<cursors.size()) { //loop through both lists until we reach the end of them both
      if(ind==cursors.size() || ind<touches.length && touches[ind].id < cursors.get(ind).id) { //if the touch ID is less than the cursor ID, that means a new touch was added before this cursor. If we're past the end of cursors, a new touch was added at the end
        Cursor curs = new Cursor(touches[ind].x, touches[ind].y).setId(touches[ind].id); //create new cursor to represent that touch
        curs.press(LEFT);      //make the cursor pressed
        cursors.add(ind,curs); //add it to the list in the correct spot
        adds.add(curs);        //add it to the list of things we added
        ind++;                 //increment the index
      }
      else if(ind==touches.length || ind<cursors.size() && touches[ind].id > cursors.get(ind).id) { //if the touch ID is greater than the cursor ID, or we're past the end of touches, that means this cursor was removed from the touch list.
        subs.add(cursors.get(ind));     //add this cursor to the list of things we removed
        cursors.get(ind).release(LEFT); //make the cursor released
        cursors.remove(ind);            //remove this cursor from the cursor list
        //don't increment the index, stay in the same place
      }
      else { //same ID:
        if(touches[ind].x != cursors.get(ind).x || touches[ind].y != cursors.get(ind).y) { //first, see if the position has changed
          movs.add(cursors.get(ind));                                 //if so, add this to the list
          cursors.get(ind).updatePos(touches[ind].x, touches[ind].y); //update the position
        }
        ind++; //in any case, increment index, then continue
      }
    }
    
    for(Cursor curs : adds) { updateButtons(curs, (byte)1); } //update everything to account for buttons pressed,
    for(Cursor curs : subs) { updateButtons(curs, (byte)0); } //to account for buttons released,
    for(Cursor curs : movs) { updateButtons(curs, (byte)3); } //and to account for cursors moved
  }*/
  
  void setCursorSelect(Cursor curs) { //sets what the cursor is selecting, ASSUMING the cursor was JUST pressed down
    Box box = getCursorSelect(this, curs); //get the box this cursor is selecting, if any
    if(box==curs.select) { return; }       //no change: return
    curs.setSelect(box);                   //set select to whatever we're pressing
  }
  
  static Box getCursorSelect(Panel pan, Cursor curs) { //searches through a panel and returns which object this cursor is hovering over
    if(!pan.hitbox(curs)) { return null; } //if cursor is not in hitbox, skip
    
    for(Box b : pan) { //loop through all the boxes in the panel
      if(b instanceof Panel) { //if b is a panel:
        Box b2 = getCursorSelect((Panel)b, curs); //perform this recursively on said panel
        if(b2!=null) { return b2; }               //if b2 isn't null, return it TODO make this work even if there are overlapping boxes
      }
      else if(b.hitbox(curs)) { return b; } //if b isn't a panel, return b iff the cursor is in it's hitbox
    }
    
    return pan; //if we're in it's hitbox, but not the hitboxes of any of its children, return this panel
  }
  
  static void updateButtons(Panel pan, Cursor curs, final byte code) { //looks through all visible buttons in a panel and updates accordingly
    if(!pan.hitbox(curs)) { return; } //if cursor is not in hitbox, skip
    
    for(Box b : pan) { //loop through all the boxes in the panel
      if(b instanceof Panel) { updateButtons((Panel)b, curs, code); } //if b is a panel: update all the buttons in b
      else if(b instanceof Button) {                                  //if b is a button: update it
        ((Button)b).respondToChange(curs, code);                      //cast to a button, respond to the change
      }
    }
  }
  
  void updateButtons(Cursor curs, final byte code) {
    updateButtons(this, curs, code);
  }
  
  static boolean updatePanelScroll(Panel p, int mouseX, int mouseY, boolean mousePressed, int event) { //PC only (return whether an update actually occurred)
    if(!p.hitbox(mouseX,mouseY)) { return false; } //if mouse is not in hitbox, skip
    
    for(Box b : p) { //loop through all the boxes in the panel
      if(b instanceof Panel) {
        Panel p2 = (Panel)b; //cast to a panel
        if(updatePanelScroll(p2,mouseX,mouseY,mousePressed,event)) { return true; } //if an inner panel got an event, return true so we can immediately leave
      }
    }
    
    if(!p.canMouseScroll /*|| p.h>=p.surfaceH*/) { return false; } //if you can't scroll with the mouse, or the surface is the same size as the window, return false
    
    //p.surfaceY = constrain(p.surfaceY-event*p.pixPerClick, p.h-p.surfaceH, 0); //move the surface, constrain to avoid moving out of bounds
    p.shiftSurface(0, -event*p.pixPerClick); //move the surface
    
    return true; //return true because we updated
  }
  
  void updatePanelScroll(int mouseX, int mouseY, boolean mousePressed) {
    if(wheelEvent!=0) { updatePanelScroll(this, mouseX, mouseY, mousePressed, wheelEvent); }
  }
  
  static void updatePanelSwipe(Panel p) {
    p.updateSwipe(); //update swiping mechanics TODO fix whatever the fuck happens when we swipe one panel then swipe a panel inside it
    
    for(Box b : p) { //loop through all the boxes in the panel
      if(b instanceof Panel) { updatePanelSwipe((Panel)b); } //for each panel, update their panel swipes as well
    }
  }
  
  void updatePanelSwipe() { updatePanelSwipe(this); }
  
  /*
  ArrayList<Box> generateRecursiveList() {
    ArrayList<Panel> list1 = new ArrayList<Panel>(); list1.add(this); //list1 will hold this generation
    ArrayList<Panel> list2;                                           //list2 will hold all the (panel) children of this generation
    ArrayList<Box> list3 = new ArrayList<Box>(); list3.add(this);     //list3 will hold everything
    
    while(!list1.isEmpty()) { //loop until this generation is empty
      
      list2 = new ArrayList<Panel>(); //initialize list2
      for(Panel panel : list1) { //loop through all panels in list1
        for(Box box : panel) {   //loop through all boxes in each panel
          list3.add(box);        //add each box to the total list
          if(box instanceof Panel) { list2.add((Panel)box); } //if it's a panel, add it to list2
        }
      }
      list1 = list2; //set list1 equal to list2
    }
    
    return list3; //return the total list
  }*/
}

/*public static class Pointer {
  public int id;
  public float x, y;
  public float area;
  public float pressure;
}*/
