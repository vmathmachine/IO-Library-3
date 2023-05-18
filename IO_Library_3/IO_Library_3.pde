import java.util.HashSet;
import java.util.Iterator;

boolean test1 = false;

Mmio io;

void setup() {
  size(600,600);
  
  io = new Mmio(this);
  io.cursors.add(new Cursor(mouseX,mouseY));
  io.setSurfaceFill(255).setSurfaceDims(500,500).setPos(50,50).setW(500).setH(500);
  
  Panel pan = (Panel)new Panel(200,100,200,300).setSurfaceDims(300,500).setSurfaceFill(#808080).setParent(io);
  new Button(100,50,50,50).setFills(#FF0000,#00FF00,#0000FF).setTimings(0.2,0.2,0.2).setText(new Text("Test",25,25,12,#FFFF00,CENTER,CENTER)).setStroke(false).setParent(io);
  pan.setSwipeMode(SwipeMode.NONE, SwipeMode.NORMAL);
  
  new Button(50,125,50,50).setFills(#000000,#800000,#FF0000).setTimings(0.2,0.2,0.2).setStrokes(#0000FF,#0000FF,#0000FF).setText(new Text("Fuck",25,25,12,#00FF00,CENTER,CENTER)).setParent(pan);
  new Button(50,350,50,50).setFills(#000000,#800000,#FF0000).setTimings(0.2,0.2,0.2).setStrokes(#0000FF,#0000FF,#0000FF).setText(new Text("Shit",25,25,12,#00FF00,CENTER,CENTER)).setParent(pan);
  
  Button pissDrinker = new Button(100,400,80,50); pissDrinker.setFills(#FF0000,#800080,#0000FF).setTimings(0.2,0.2,0.2).setText(new Text("( . )( . )",40,25,18,#FFFFFF,CENTER,CENTER)).setStroke(false).setParent(io);
  //new Box(-1,50,202,50).setParent(pan);
  
  ///FORMULA FOR TEXT HEIGHT: (approximate) height = 1.1635718 * textSize + 0.90234375
}

void draw() {
  background(0);
  
  io.display();
  //io.updateButtons(mouseX,mouseY,mousePressed);
  io.updatePanelScroll(mouseX,mouseY,mousePressed);
  io.updatePanelSwipe();
  
  io.wheelEvent = 0;
}

void mouseWheel(MouseEvent event) {
  io.wheelEvent = event.getCount();
}

void mousePressed() {
  Cursor curs = io.cursors.get(0); //PC: there's only one cursor
  
  if(curs.press==0) { //if the cursor was previously not pressed
    io.setCursorSelect(curs); //set the cursor select to whatever it's selecting
    if(curs.select instanceof Panel) { //TODO add special case for textboxes (and other derived classes of panel)
      Panel panel = (Panel)curs.select; //cast to panel
      panel.press(curs); //activate press functionality
    }
  }
  
  curs.press(mouseButton); //press the correct button
  
  io.updateButtons(curs, (byte)1); //update the buttons, with code 1 for pressing
}

void mouseReleased() {
  Cursor curs = io.cursors.get(0); //PC: there's only one cursor
  curs.release(mouseButton); //release the correct button
  
  io.updateButtons(curs, (byte)0); //update the buttons, with code 0 for releasing
  //TODO make this compatible with multiple mouse buttons being pressed & released
  
  if(curs.press==0) { //if cursor isn't pressing anymore
    if(curs.select instanceof Panel) { //TODO add special case for textboxes (and other derived classes of panel)
      Panel panel = (Panel)curs.select; //cast to panel
      panel.release(curs); //activate release functionality
    }
    curs.setSelect(null); //set select for the just-released cursor to null
  }
}

void mouseMoved() {
  Cursor curs = io.cursors.get(0); //PC: there's only one cursor
  curs.updatePos(mouseX,mouseY);   //change the cursor position
  
  io.updateButtons(curs, (byte)2); //update the buttons, with code 2 for moving
}

void mouseDragged() {
  Cursor curs = io.cursors.get(0); //PC: there's only one cursor
  curs.updatePos(mouseX,mouseY);   //change the cursor position
  
  io.updateButtons(curs, (byte)3); //update the buttons, with code 3 for dragging
}


/*
WHAT TO DO:

Make buttons have multiple methods that get performed on multiple events. For instance, mouse enters hitbox, mouse leaves hitbox, mouse pressed while in hitbox, mouse released while in hitbox,
mouse pressed while still selected, mouse released while still selected, button selected for a certain amount of time.

Or, perhaps, we could make things simpler (albeit, less customizable). Instead, each button has a set of options. I'm too drunk to think this through.


Make UI elements still show up even if they're partially obscured.

Add text boxes

Add scroll bars

Add sliders




*/
