




class DSweeper {
  int[][][] tile;
  boolean[][] show; //revealed
  boolean[][] mine;
  int[][] number;
  boolean[][] marked;
  
  int w, h; //tiles along width height
  
  int numMines;
  
  boolean autoShowObvious;
  int[][] shape; //which tiles are counted  x/y coordinates in 2nd dimension
  //Rule[] rule;
  int[] ruleVal;
  color[] ruleCol;
  color[] ruleHL;
  int[] ruleInit;
  /*
  int[] rule; //list of possible sector multipliers
  color[] ruleColor; //color associations  
  color[] ruleHL; //highlight color associations  
  boolean[] ruleInit; //which can be randomly initialized
  */
  int edgeRule; //if not negative all edges are set to this rule
  
  
  boolean started; //game has been started
  boolean gameOver, win; //game has ended game was won
  int time; //used to record when game was started and how long gmae lasted
  int marks, shown; //number of tiles marked shown
  
  float x, y, s; //placement on screen and tile size
  
  float wide, tall; //w*s, h*s
  boolean noNegativeRules, noPositiveRules;
  
  
  
  DSweeper(float tx, float ty, float ts, int tw, int th, int tnm, Rule[] tr, int ter, boolean taso) {
    shape=new int[3][2];
    shape[0][0]=-1; shape[0][1]=-1;
    shape[1][0]=0; shape[1][1]=-1;
    shape[2][0]=1; shape[2][1]=-1;
    x=tx; y=ty; s=ts; w=tw; h=th; numMines=tnm;
    autoShowObvious=taso;
    int trl=tr.length; //shorthand //rule=new Rule[trl];  rule[i]=new Rule(tr[i]);
    ruleVal=new int[trl]; ruleCol=new color[trl]; ruleHL=new color[trl]; ruleInit=new int[trl];
    for(int i=0; i<trl; i++) { ruleVal[i]=tr[i].val; ruleCol[i]=tr[i].col; ruleHL[i]=tr[i].HL; ruleInit[i]=tr[i].init; }
    if(ter<trl) { edgeRule=ter; } else { println("ERROR edge rule out of bounds"); exit(); }
    started=false; gameOver=false; win=false;
    tile=initBoi(w, h, ruleInit, edgeRule);
    show=new boolean[w][h];
    mine=new boolean[w][h];
    number=new int[w][h];
    marked=new boolean[w][h];
    time=0;
    wide=w*s; tall=h*s;
    marks=0; shown=0;
  }
  
  
  boolean VTC(int tcx, int tcy) {
    return(IIBA(tcx, 0, w) && IIBA(tcy, 0, h));
  }
  
  
  int[][] getVTCdir(int tcx, int tcy, int dir) {
    int[][] buff=new int[shape.length][2];
    int pos=0;
    for(int i=0; i<shape.length; i++) {
      int tx=tcx, ty=tcy;
      if(dir==0) { tx+=shape[i][0]; ty+=shape[i][1]; }
      if(dir==1) { tx-=shape[i][1]; ty+=shape[i][0]; }
      if(dir==2) { tx-=shape[i][0]; ty-=shape[i][1]; }
      if(dir==3) { tx+=shape[i][1]; ty-=shape[i][0]; }
      if(VTC(tx, ty)) { buff[pos][0]=tx; buff[pos][1]=ty; pos++; }
    }
    int[][] ans=new int[pos][2];
    for(int i=0; i<pos; i++) { ans[i][0]=buff[i][0]; ans[i][1]=buff[i][1]; }
    return(ans);
  }
  
  int[][][] getVTC(int tcx, int tcy) {
    int[][][] ans=new int[4][][];
    ans[0]=getVTCdir(tcx, tcy, 0);
    ans[1]=getVTCdir(tcx, tcy, 1);
    ans[2]=getVTCdir(tcx, tcy, 2);
    ans[3]=getVTCdir(tcx, tcy, 3);
    return(ans);
  }
  
  
  int[][] getDeltaVTC(int tcx, int tcy) {
    int[][][] vtc=getVTC(tcx, tcy);
    int[][] buff=new int[shape.length*4][3];
    int pos=0;
    for(int i=0; i<vtc[0].length; i++) { buff[pos][0]=vtc[0][i][0]; buff[pos][1]=vtc[0][i][1]; buff[pos][2]=ruleVal[tile[tcx][tcy][0]]; pos++; }
    for(int i=0; i<vtc[1].length; i++) {
      int nai=notAlreadyIn(buff, vtc[1][i]);
      if(nai==-1) { buff[pos][0]=vtc[1][i][0]; buff[pos][1]=vtc[1][i][1]; buff[pos][2]=ruleVal[tile[tcx][tcy][1]]; pos++; }
      else { buff[nai][2]+=ruleVal[tile[tcx][tcy][1]]; }
    }
    for(int i=0; i<vtc[2].length; i++) {
      int nai=notAlreadyIn(buff, vtc[2][i]);
      if(nai==-1) { buff[pos][0]=vtc[2][i][0]; buff[pos][1]=vtc[2][i][1]; buff[pos][2]=ruleVal[tile[tcx][tcy][2]]; pos++; }
      else { buff[nai][2]+=ruleVal[tile[tcx][tcy][2]]; }
    }
    for(int i=0; i<vtc[3].length; i++) {
      int nai=notAlreadyIn(buff, vtc[3][i]);
      if(nai==-1) { buff[pos][0]=vtc[3][i][0]; buff[pos][1]=vtc[3][i][1]; buff[pos][2]=ruleVal[tile[tcx][tcy][3]]; pos++; }
      else { buff[nai][2]+=ruleVal[tile[tcx][tcy][3]]; }
    }
    int[][] ans=new int[pos][3];
    for(int i=0; i<pos; i++) { ans[i][0]=buff[i][0]; ans[i][1]=buff[i][1]; ans[i][2]=buff[i][2]; }
    return(ans);
  }
  int notAlreadyIn(int[][] a, int[] b) {
    for(int i=0; i<a.length; i++) {
      boolean r=true;
      for(int j=0; j<2; j++) { if(a[i][j]!=b[j]) { r=false; j=a.length; } }
      if(r) { return(i); }
    }
    return(-1);
  }
  
  
  boolean tileNoNegativeRules(int tcx, int tcy) {
    for(int i=0; i<4; i++) { if(ruleVal[tile[tcx][tcy][i]]<0) { return(false); } }
    return(true);
  }
  boolean tileNoPositiveRules(int tcx, int tcy) {
    for(int i=0; i<4; i++) { if(ruleVal[tile[tcx][tcy][i]]>0) { return(false); } }
    return(true);
  }
  
  
  
  void reset() {
    started=false; gameOver=false; win=false;
    tile=initBoi(w, h, ruleInit, edgeRule);
    show=new boolean[w][h];
    mine=new boolean[w][h];
    number=new int[w][h];
    marked=new boolean[w][h];
    marks=0; shown=0;
  }
  
  
  void startGame(int sx, int sy) {
    for(int i=-1; i<2; i++) { for(int j=-1; j<2; j++) { if(IIBA(sx+i, 0, w) && IIBA(sy+j, 0, h)) { show[sx+i][sy+j]=true; } } }
    int pmines=0, c=0;
    while(pmines<numMines) {
      int rx=randint(0, w-1), ry=randint(0, h-1);
      if(!show[rx][ry] && !mine[rx][ry]) { mine[rx][ry]=true; pmines++; }
      c++; if(c>100000000) { println("ERROR mine placing loop endless"); exit(); } //debug
    }
    initNumber();
    started=true;
    time=millis();
  }
  
  
  void checkObviousTiles() {
    boolean newtile=true;
    while(newtile) {
      newtile=false;
      for(int i=0; i<w; i++) { for(int j=0; j<h; j++) { if(show[i][j]) {
        if(tileNoNegativeRules(i, j)) {
          int[][] dvtc=getDeltaVTC(i, j);
          for(int k=0; k<dvtc.length; k++) {
            if(dvtc[k][2]>number[i][j] && !show[dvtc[k][0]][dvtc[k][1]]) { show[dvtc[k][0]][dvtc[k][1]]=true; newtile=true; }
          }
        }
        else if(tileNoPositiveRules(i, j)) {
          int[][] dvtc=getDeltaVTC(i, j);
          for(int k=0; k<dvtc.length; k++) {
            if(dvtc[k][2]<number[i][j] && !show[dvtc[k][0]][dvtc[k][1]]) { show[dvtc[k][0]][dvtc[k][1]]=true; newtile=true; }
          }
        }
      } } }
    }
    /*
    if(noNegativeRules) {
      boolean newtile=true;
      while(newtile) {
        newtile=false;
        for(int qx=0; qx<w; qx++) { for(int qy=0; qy<h; qy++) { if(show[qx][qy]) {
          int tar=number[qx][qy];
          for(int i=-1; i<2; i++) { for(int j=-1; j<2; j++) { if(IIBA(qx+i, 0, w) && IIBA(qy+j, 0, h) && !marked[qx+i][qy+j]) {
            int tiji=0;
            if(j==-1) { tiji+=rule[tile[qx][qy][0]]; }
            if(i==1)  { tiji+=rule[tile[qx][qy][1]]; }
            if(j==1)  { tiji+=rule[tile[qx][qy][2]]; }
            if(i==-1) { tiji+=rule[tile[qx][qy][3]]; }
            if(tiji>tar && !show[qx+i][qy+j]) { show[qx+i][qy+j]=true; newtile=true; }
          } } }
        } } }
        /*
        for(int i=0; i<w; i++) { for(int j=0; j<h; j++) { if(show[i][j] && number[i][j]==0) {
          for(int k=-1; k<2; k++) {
            if(IIBA(i+k, 0, w) && IIBA(j-1, 0, h) && rule[tile[i][j][0]]!=0 && !show[i+k][j-1]) { show[i+k][j-1]=true; newtile=true; }
            if(IIBA(i+1, 0, w) && IIBA(j+k, 0, h) && rule[tile[i][j][1]]!=0 && !show[i+1][j+k]) { show[i+1][j+k]=true; newtile=true; }
            if(IIBA(i+k, 0, w) && IIBA(j+1, 0, h) && rule[tile[i][j][2]]!=0 && !show[i+k][j+1]) { show[i+k][j+1]=true; newtile=true; }
            if(IIBA(i-1, 0, w) && IIBA(j+k, 0, h) && rule[tile[i][j][3]]!=0 && !show[i-1][j+k]) { show[i-1][j+k]=true; newtile=true; }
          }
        } } }
        //*
      }
    }
    */
  }
  
  void checkMarkedObviousTiles(int sx, int sy) {
    if(noNegativeRules) {
      int mmc=0;
      for(int k=-1; k<2; k++) {
        if(VTC(sx+k, sy-1) && mine[sx+k][sy-1] && marked[sx+k][sy-1]) { mmc+=ruleVal[tile[sx][sy][0]]; }
        if(VTC(sx+1, sy+k) && mine[sx+1][sy+k] && marked[sx+1][sy+k]) { mmc+=ruleVal[tile[sx][sy][1]]; }
        if(VTC(sx+k, sy+1) && mine[sx+k][sy+1] && marked[sx+k][sy+1]) { mmc+=ruleVal[tile[sx][sy][2]]; }
        if(VTC(sx-1, sy+k) && mine[sx-1][sy+k] && marked[sx-1][sy+k]) { mmc+=ruleVal[tile[sx][sy][3]]; }
      }
      int tar=number[sx][sy]-mmc;
      for(int i=-1; i<2; i++) { for(int j=-1; j<2; j++) { if(IIBA(sx+i, 0, w) && IIBA(sy+j, 0, h) && !marked[sx+i][sy+j]) {
        int tiji=0;
        if(j==-1) { tiji+=ruleVal[tile[sx][sy][0]]; }
        if(i==1)  { tiji+=ruleVal[tile[sx][sy][1]]; }
        if(j==1)  { tiji+=ruleVal[tile[sx][sy][2]]; }
        if(i==-1) { tiji+=ruleVal[tile[sx][sy][3]]; }
        if(tiji>tar) { show[sx+i][sy+j]=true; }
      } } }
      /*
      if(number[sx][sy]-mmc==0) {
        for(int k=-1; k<2; k++) {
          if(IIBA(sx+k, 0, w) && IIBA(sy-1, 0, h) && rule[tile[sx][sy][0]]!=0 && !marked[sx+k][sy-1]) { show[sx+k][sy-1]=true; }
          if(IIBA(sx+1, 0, w) && IIBA(sy+k, 0, h) && rule[tile[sx][sy][1]]!=0 && !marked[sx+1][sy+k]) { show[sx+1][sy+k]=true; }
          if(IIBA(sx+k, 0, w) && IIBA(sy+1, 0, h) && rule[tile[sx][sy][2]]!=0 && !marked[sx+k][sy+1]) { show[sx+k][sy+1]=true; }
          if(IIBA(sx-1, 0, w) && IIBA(sy+k, 0, h) && rule[tile[sx][sy][3]]!=0 && !marked[sx-1][sy+k]) { show[sx-1][sy+k]=true; }
        }
      }
      */
    }
  }
  
  
  void initNumber() {
    for(int i=0; i<w; i++) { for(int j=0; j<h; j++) {
      int mc=0;
      for(int k=-1; k<2; k++) {
        if(IIBA(i+k, 0, w) && IIBA(j-1, 0, h) && mine[i+k][j-1]) { mc+=ruleVal[tile[i][j][0]]; }
        if(IIBA(i+1, 0, w) && IIBA(j+k, 0, h) && mine[i+1][j+k]) { mc+=ruleVal[tile[i][j][1]]; }
        if(IIBA(i+k, 0, w) && IIBA(j+1, 0, h) && mine[i+k][j+1]) { mc+=ruleVal[tile[i][j][2]]; }
        if(IIBA(i-1, 0, w) && IIBA(j+k, 0, h) && mine[i-1][j+k]) { mc+=ruleVal[tile[i][j][3]]; }
      }
      number[i][j]=mc;
    } }
  }
  
  
  void disp() {
    dispBoard();
    if(gameOver) {
      dispGOM();
    }
    dispHUD();
  }
  
  void dispBoard() {
    for(int i=0; i<w; i++) { for(int j=0; j<h; j++) {
      if(show[i][j]) { drawTile(s, i*s+x, j*s+y, tile[i][j], number[i][j], ruleCol); }
      else if(marked[i][j]) { drawMarked(s, i*s+x, j*s+y); }
      else { drawCover(s, i*s+x, j*s+y); }
      if(show[i][j] && mine[i][j]) { drawMine(s, i*s+x, j*s+y); }
    } }
    if(!gameOver) {
      for(int i=0; i<w; i++) { for(int j=0; j<h; j++) {
        if(mouseOnRect(x+i*s, y+j*s, s, s)) {
          if(show[i][j]) { drawTileTOP(s, i*s+x, j*s+y, tile[i][j], number[i][j], ruleHL); }
          else if(marked[i][j]) { drawMarkedTop(s, i*s+x, j*s+y); }
          else { drawCoverTop(s, i*s+x, j*s+y); }
        }
      } }
    }
    else {
      for(int i=0; i<w; i++) { for(int j=0; j<h; j++) { if(marked[i][j] && !mine[i][j]) { drawBadMarked(s, i*s+x, j*s+y); } } }
    }
  }
  
  void dispHUD() {
    fill(0);
    textSize(wide/20);
    textAlign(LEFT);
    text("M: "+marks+"/"+numMines,         x+wide+wide/40, y+wide/10);
    text("T: "+shown+"/"+((w*h)-numMines), x+wide+wide/40, y+wide/10+wide/20+wide/40);
    stroke(0);
    for(int i=0; i<ruleVal.length; i++) {
      String eq="="+ruleVal[i];
      fill(ruleCol[i]);
      rect(x+wide+wide/40, y+wide/10+(wide/20+wide/40)*(i+3)-wide/24, wide/20, wide/20);
      fill(0);
      text(eq, x+wide+wide/40+wide/20+wide/80, y+wide/10+(wide/20+wide/40)*(i+3));
    }
    if(started) {
      if(gameOver) { text(""+(time/1000)+"."+(time%1000),   x+wide+wide/40, y+wide/10+2*(wide/20+wide/40)); }
      else {
        int ctime=millis()-time;
        text(""+(ctime/1000)+"."+(ctime%1000),   x+wide+wide/40, y+wide/10+2*(wide/20+wide/40));
      }
    }
    else {
      text("0.0",   x+wide+wide/40, y+wide/10+2*(wide/20+wide/40));
    }
  }
  
  void dispGOM() {
    textSize(wide/20);
    String printTime="time: "+(time/1000)+"."+(time%1000)+" seconds";
    String PAKtR="press any key to reset";
    float widd=max(textWidth(PAKtR), textWidth(printTime));
    fill(255, 192);
    noStroke();
    rect(x+(wide-widd)/2-wide/40, y+wide/2-(wide*17/80)/2, widd+wide/20, wide*17/80);
    fill(0);
    textSize(wide/10);
    textAlign(CENTER);
    if(win) {
      text("YEET", x+wide/2, y+wide/2-wide/80);
      textSize(wide/20);
      text(printTime, x+wide/2, y+wide/2+wide/20-wide/80);
      text(PAKtR, x+wide/2, y+wide/2+2*wide/20-wide/80);
    }
    else {
      text("OOF", x+wide/2, y+wide/2-wide/160);
      textSize(wide/20);
      text(printTime, x+wide/2, y+wide/2+wide/20-wide/80);
      text(PAKtR, x+wide/2, y+wide/2+2*wide/20-wide/80);
    }
  }
  
  
  
  
  void MP(int SFMX, int SFMY) {
    if(!gameOver && mouseOnRect(x, y, w*s, h*s)) {
      int MX=int((SFMX-x)/s), MY=int((SFMY-y)/s);
      if(mouseButton==LEFT) {
        if(started) {
          if(show[MX][MY] && autoShowObvious) { checkMarkedObviousTiles(MX, MY); }
          if(!marked[MX][MY]) { show[MX][MY]=true; }
        }
        else {
          startGame(MX, MY);
        }
        if(autoShowObvious) { checkObviousTiles(); }
      }
      else if(mouseButton==RIGHT) {
        if(!show[MX][MY]) { marked[MX][MY]=!marked[MX][MY]; }
      }
      shown=0; marks=0;
      for(int i=0; i<w; i++) { for(int j=0; j<h; j++) {
        if(show[i][j]) {
          if(mine[i][j]) { gameOver=true; time=millis()-time; }
          shown++;
        }
        if(marked[i][j]) { marks++; }
      } }
      if(!gameOver && shown==w*h-numMines) { gameOver=true; win=true; time=millis()-time; }
    }
    /*
    if(!gameOver && mouseOnRect(x, y, w*s, h*s)) {
      int MX=int((mouseX-x)/s), MY=int((mouseY-y)/s);
      if(mouseButton==LEFT) {
        if(started) {
          if(show[MX][MY]) { checkMarkedObviousTiles(MX, MY); }
          if(!marked[MX][MY]) { show[MX][MY]=true; }
        }
        else {
          startGame(MX, MY);
        }
        checkObviousTiles();
      }
      else if(mouseButton==RIGHT) {
        if(!show[MX][MY]) { marked[MX][MY]=!marked[MX][MY]; }
      }
      shown=0; marks=0;
      for(int i=0; i<w; i++) { for(int j=0; j<h; j++) {
        if(show[i][j]) {
          if(mine[i][j]) { gameOver=true; time=millis()-time; }
          shown++;
        }
        if(marked[i][j]) { marks++; }
      } }
      if(!gameOver && shown==w*h-numMines) { gameOver=true; win=true; time=millis()-time; }
    }
    */
  }
  
  
  void KP() {
    if(gameOver) {
      reset();
    }
    else {
      if(key=='r') { reset(); }
    }
  }
}




class Rule {
  color col, HL; //color / highlight
  int val; //multiplier for mines in reigon
  int init; //initialization chance weight (P=local init/sum(init))
  Rule(int r, int g, int b, int hr, int hg, int hb, int tv, int ti) {
    col=color(r, g, b); HL=color(hr, hg, hb); val=tv; init=ti;
  }
  Rule(Rule i) {
    col=i.col; HL=i.HL; val=i.val; init=i.init;
  }
}







int[][][] initBoi(int w, int h, int[] ri, int e) {
  int[][][] ans=new int[w][h][4];
  for(int i=0; i<w; i++) { for(int j=0; j<h; j++) { for(int k=0; k<4; k++) {
    ans[i][j][k]=weightedRandInt(ri);
  } } }
  if(e>=0) {
    for(int i=0; i<w; i++) {
      ans[i][0][0]=e; ans[i][h-1][2]=e;
    }
    for(int i=0; i<h; i++) {
      ans[0][i][3]=e; ans[w-1][i][1]=e;
    }
  }
  return(ans);
}






void drawTile(float s, float x, float y, int[] m, int n, color[] col) {
  if(m.length==4) {
    noStroke();
      fill(col[m[0]]);
      beginShape();
      vertex(0+x, 0+y);
      vertex(s+x, 0+y);
      vertex(s/2+x, s/2+y);
      endShape(CLOSE);
      fill(col[m[1]]);
      beginShape();
      vertex(s+x, 0+y);
      vertex(s+x, s+y);
      vertex(s/2+x, s/2+y);
      endShape(CLOSE);
      fill(col[m[2]]);
      beginShape();
      vertex(s+x, s+y);
      vertex(0+x, s+y);
      vertex(s/2+x, s/2+y);
      endShape(CLOSE);
      fill(col[m[3]]);
      beginShape();
      vertex(0+x, s+y);
      vertex(0+x, 0+y);
      vertex(s/2+x, s/2+y);
      endShape(CLOSE);
    fill(0);
    rect(s/4+x, s/4+y, s/2, s/2);
    fill(255);
    textSize(s/2);
    textAlign(CENTER);
    text(n, s/2+x, s*0.6875+y);
    stroke(0);
    strokeWeight(s/50);
    noFill();
    rect(0+x, 0+y, s, s);
  }
  else { println("ERROR m not length 4"); exit(); } //debug
}

void drawTileTOP(float s, float x, float y, int[] m, int n, color[] col) {
  if(m.length==4) {
    noStroke();
    fill(col[m[0]]);
    beginShape();
    vertex(0+x, 0+y);
    vertex(s+x, 0+y);
    vertex(s/2+x, s/2+y);
    endShape(CLOSE);
    fill(col[m[1]]);
    beginShape();
    vertex(s+x, 0+y);
    vertex(s+x, s+y);
    vertex(s/2+x, s/2+y);
    endShape(CLOSE);
    fill(col[m[2]]);
    beginShape();
    vertex(s+x, s+y);
    vertex(0+x, s+y);
    vertex(s/2+x, s/2+y);
    endShape(CLOSE);
    fill(col[m[3]]);
    beginShape();
    vertex(0+x, s+y);
    vertex(0+x, 0+y);
    vertex(s/2+x, s/2+y);
    endShape(CLOSE);
    fill(0);
    rect(s/4+x, s/4+y, s/2, s/2);
    fill(255);
    textSize(s/2);
    textAlign(CENTER);
    text(n, s/2+x, s*0.6875+y);
    stroke(255);
    strokeWeight(s/50);
    noFill();
    rect(0+x, 0+y, s, s);
  }
  else { println("ERROR m not length 4"); exit(); } //debug
}


void drawCover(float s, float x, float y) {
  fill(128);
  stroke(0);
  strokeWeight(s/50);
  rect(0+x, 0+y, s, s);
}

void drawCoverTop(float s, float x, float y) {
  fill(192);
  stroke(255);
  strokeWeight(s/50);
  rect(0+x, 0+y, s, s);
}


void drawMarked(float s, float x, float y) {
  fill(192, 192, 0);
  stroke(0);
  strokeWeight(s/50);
  rect(0+x, 0+y, s, s);
}
void drawBadMarked(float s, float x, float y) {
  fill(192, 0, 192);
  stroke(0);
  strokeWeight(s/50);
  rect(0+x, 0+y, s, s);
}

void drawMarkedTop(float s, float x, float y) {
  fill(255, 255, 0);
  stroke(255);
  strokeWeight(s/50);
  rect(0+x, 0+y, s, s);
}


void drawMine(float s, float x, float y) {
  fill(255, 0, 0);
  stroke(0);
  strokeWeight(s/50);
  rect(0+x, 0+y, s, s);
}
