




class Button {
  float x, y, w, h; //position size
  color col, HL;
  String text;
  Button(float tx, float ty, float tw, float th, color tc, color thl, String tt) {
    x=tx; y=ty; w=tw; h=th; col=tc; HL=thl; text=tt;
  }
  
  boolean MO() { return(mouseOnRect(x, y, w, h)); }
  
  void disp() {
    stroke(0); strokeWeight(1);
    if(MO()) { fill(HL); }
    else { fill(col); }
    rect(x, y, w, h);
    textAlign(CENTER);
    textSize(h);
    fill(0);
    text(text, x+w/2, y+h*0.85);
  }
}




class Slider {
  float x, y, w, h, s;
  int val;
  int min, max;
  boolean clicked;
  int oldval;
  Slider(float tx, float ty, float tw, float th, float ts, int tv, int ti, int ta) {
    x=tx; y=ty; w=tw; h=th; s=ts; val=tv; min=ti; max=ta;
    clicked=false; oldval=val;
  }
  
  float xoff() { return((w-s)*(val-min)/(max-min)); }
  boolean MO() { return(mouseOnRect(x, y, w, h)); }
  boolean MOS() { return(mouseOnRect(x+xoff(), y, s, h)); }
  
  void boundVal() { if(val<min) { val=min; } else if(val>max) { val=max; } }
  
  void MP() {
    if(MOS()) { clicked=true; oldval=val; }
  }
  void MR() {
    clicked=false;
  }
  void scroll(int scroll) { if(MO()) {
    val+=scroll; boundVal();
  } }
  
  void update() {
    if(clicked) {
      val=oldval+int((screenFitMouseX()-CX)*(max-min)/(w-s));
      boundVal();
    }
  }
  
  void disp() {
    stroke(0); strokeWeight(1);
    if(MO() || clicked) { fill(223, 223, 255); }
    else { fill(255); }
    rect(x, y, w, h);
    if(MOS() || clicked) { fill(128, 192, 128); }
    else { fill(0, 255, 0); }
    rect(x+xoff(), y, s, h);
    textAlign(CENTER);
    textSize(h);
    fill(0);
    text(""+val, x+w/2, y+h*0.85);
  }
  
  void updisp() { update(); disp(); }
}
