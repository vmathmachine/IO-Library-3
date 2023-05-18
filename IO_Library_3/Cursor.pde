//Since on Android, you can have multiple touch events, but on PC, there's only one, we need a class to store cursors.
//On PC, there's always 1, on Android, it varies. We can customize the code for both, but we'll use cursors to keep things reusable.

static class Cursor {
  int id = 0;         //The ID of this cursor. Used primarily for compatibility with touch events on Android. Always 0 on PCs w/out multitouch
  float x, y, px, py; //x, y, previous x, previous y
  //float dx, dy, ex, ey; //x and y in the previous draw cycle, and in the previous event. The previous event isn't actually dealt with in Android because it's touch detection is somewhat broken
  //TODO implement both types of previous positions
  byte press=0;       //whether each button is pressed. On Android, left is always true, right & center are always false.
  //as an optimization, the 3 bools were combined into 1 byte, which both optimizes storage & allows us to quickly check if it's in a particular state (i.e. ==0, !=0)
  boolean active = true;             //when false, this cursor is considered deactivated. The alternative to this would be to simply finalize this object and have it be null, but that might be unsafe
  //TODO figure out if the active boolean ever gets used in practice
  //CursorMode mode = CursorMode.NONE; //what the cursor is currently doing
  Box select = null;                //the behavior of this cursor and how it interacts with UI elements, characterized by the object it touched when it was most recently pressed. More specifically, that object's class
  //NOTE Maybe I shouldn't have the select thing here? I mean, it makes perfect sense, but also it conflicts with a general philosophy that the Cursor should act all on its own, regardless of the inclusion of a UI library
  float xi, yi; //initial x and y, the position it was on the last time it was pressed down
  
  Cursor() { }
  
  Cursor(float x_, float y_) {
    x=px=x_; y=py=y_;
  }
  
  void updatePos(float mouseX, float mouseY) {
    px=x; py=y; x=mouseX; y=mouseY;
  }
  
  void press(int mouseButton) { switch(mouseButton) {
    case LEFT: press|=4; break; case CENTER: press|=2; break; case RIGHT: press|=1;
  } xi=x; yi=y; }
  
  void release(int mouseButton) { switch(mouseButton) {
    case LEFT: press&=~4; break; case CENTER: press&=~2; break; case RIGHT: press&=~1;
  } }
  
  void press() { press(LEFT); }
  void release() { release(LEFT); }
  
  //void setMode(final CursorMode m) { mode = m; }
  void setSelect(final Box b) { select = b; }
  
  boolean left  () { return (press&4)==4; }
  boolean center() { return (press&2)==2; }
  boolean right () { return (press&1)==1; }
  
  int getId() { return id; }
  Cursor setId(final int i) { id=i; return this; }
}

//static enum CursorMode { NONE, BUTTON, PANEL }
