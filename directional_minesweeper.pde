/*
WARNING this code is pretty bad and is confusing
this is one of the first puzzles i programmed
*/

int baseScreenX=1920, baseScreenY=1080;
boolean screenFit=false;
float screenScale=1;
float screenOffX=0, screenOffY=0;
boolean screenXLim=false;




int CX=0, CY=0;

boolean menu=true;
Button startButton;
Slider mineSlider, widthSlider, heightSlider;





DSweeper game;
int sidelength=10;
int hardness=20;
Rule[] standard, s2;
int[] standardRules, rules2;
color[] standardColors, colors2;
color[] standardHL, HL2;
boolean[] standardInit, init2;
int standardEdge=1, edge2=0;



void setup() {
  //fullScreen(JAVA2D, 2);
  size(1200, 675, FX2D); surface.setResizable(true); //fx2d is required to prevent crash on windows 10 on resize
  //noSmooth();
  
  makeScreenFit();
  
  
  startButton=new Button((baseScreenX-baseScreenX/8)/2, baseScreenY/8, baseScreenX/8, baseScreenY/16, color(255, 255, 0), color(192, 192, 128), "START");
  mineSlider=new Slider((baseScreenX-baseScreenX/8)/2, baseScreenY/4, baseScreenX/8, baseScreenY/16, baseScreenX/8/10, 20, 5, 35);
  widthSlider=new Slider((baseScreenX-baseScreenX/8)/2, baseScreenY*3/8, baseScreenX/8, baseScreenY/16, baseScreenX/8/10, 10, 5, 40);
  heightSlider=new Slider((baseScreenX-baseScreenX/8)/2, baseScreenY/2, baseScreenX/8, baseScreenY/16, baseScreenX/8/10, 10, 5, 40);
  
  
  standard=new Rule[3];
  standard[0]=new Rule(128, 0, 0, 255, 0, 0, -1, 1);
  standard[1]=new Rule(0, 128, 0, 0, 255, 0, 0, 0);
  standard[2]=new Rule(0, 0, 128, 0, 0, 255, 1, 1);
  
  s2=new Rule[3];
  s2[0]=new Rule(0, 128, 0, 0, 255, 0, 0, 1);
  s2[1]=new Rule(128, 0, 0, 255, 0, 0, 1, 5);
  s2[2]=new Rule(0, 0, 128, 0, 0, 255, 2, 5);
  
  
  //game=new DSweeper((baseScreenX-baseScreenY)/2, 0, baseScreenY/sidelength, sidelength, sidelength, sidelength*sidelength*hardness/100, standard, standardEdge, false);
  //game=new DSweeper((baseScreenX-baseScreenY)/2, 0, baseScreenY/sidelength, sidelength, sidelength, sidelength*sidelength*hardness/100, s2, edge2, true);
  
}




void draw() {
  makeScreenFit();
  background(0);
  fill(64, 128, 255); noStroke();
  rect(0, 0, baseScreenX, baseScreenY);
  if(menu) { dispMenu(); }
  else { game.disp(); }
}




void mousePressed() {
  if(menu) { menuMP(); }
  else { game.MP(screenFitMouseX(), screenFitMouseY()); }
}

void mouseReleased() {
  if(menu) { menuMR(); }
  else { }
}


void mouseWheel(MouseEvent event) {
  float e=event.getCount();
  if(menu) { menuScroll(e); }
}


void keyPressed() {
  //println(key, int(key)); //fx2d causes key to show what key was pressed instead of what was typed
  if(menu) { menuKP(); }
  else {
    if(int(key)==27) { key=0; menu=true; }
    game.KP();
  }
}









void dispMenu() {
  startButton.disp();
  mineSlider.updisp();
  widthSlider.updisp();
  heightSlider.updisp();
}




void menuMP() {
  CX=screenFitMouseX(); CY=screenFitMouseY();
  if(startButton.MO()) {
    menu=false;
    int w=widthSlider.val, h=heightSlider.val, mine=mineSlider.val;
    //game=new DSweeper(0, 0, min(baseScreenX*0.8/w, baseScreenY/h), w, h, w*h*mine/100, standard, standardEdge, false);
    game=new DSweeper(0, 0, min(baseScreenX*0.8/w, baseScreenY/h), w, h, w*h*mine/100, s2, edge2, true);
  }
  mineSlider.MP();
  widthSlider.MP();
  heightSlider.MP();
}


void menuMR() {
  mineSlider.MR();
  widthSlider.MR();
  heightSlider.MR();
}


void menuScroll(float scroll) {
  int s=int(-scroll);
  mineSlider.scroll(s);
  widthSlider.scroll(s);
  heightSlider.scroll(s);
}


void menuKP() {
  
}









void makeScreenFit() {
  if(width!=0 && height!=0) { //actually matters lol
    if(screenFit) { popMatrix(); }
    pushMatrix();
    if(width*9>height*16) {
      screenScale=float(height)/baseScreenY;
      screenOffX=width*baseScreenY/height-baseScreenX;
      screenOffX/=2;
      screenOffY=0;
      screenXLim=false;
    }
    else {
      screenScale=float(width)/baseScreenX;
      screenOffX=0;
      screenOffY=height*baseScreenX/width-baseScreenY;
      screenOffY/=2;
      screenXLim=true;
    }
    scale(screenScale);
    translate(screenOffX, screenOffY);
    screenFit=true;
  }
}

int screenFitMouseX() {
  return(int(mouseX/screenScale-screenOffX));
}
int screenFitMouseY() {
  return(int(mouseY/screenScale-screenOffY));
}















boolean mouseOnRect(float x, float y, float sx, float sy) {
  return(screenFitMouseX()>=x && screenFitMouseX()<x+sx && screenFitMouseY()>=y && screenFitMouseY()<y+sy);
  //return(mouseX>=x && mouseX<x+sx && mouseY>=y && mouseY<y+sy);
}




int weightedRandInt(int[] weight) {
  int ws=arrSum(weight);
  int c=0;
  int r=int(random(ws));
  while(r>=weight[c]) { r-=weight[c]; c++; }
  return(c);
}
int arrSum(int[] arr) { int ans=0; for(int i=0; i<arr.length; i++) { ans+=arr[i]; } return(ans); }


int randint(int min, int max) {
  return(int(random(1+max-min))+min);
}

int[] randintarr(int l, int min, int max) {
  int[] ans=new int[l];
  for(int i=0; i<l; i++) { ans[i]=randint(min, max); }
  return(ans);
}




boolean IIBA(int i, int min, int max) { //array
  return(i>=min && i<max);
}
boolean IIBI(int i, int min, int max) { //inclusive
  return(i>=min && i<=max);
}
boolean IIBE(int i, int min, int max) { //exclusive
  return(i>min && i<max);
}
