import arb.soundcipher.*;
SCScore[] score = {
  new SCScore(), new SCScore(), new SCScore(), new SCScore(), new SCScore()
  };
SoundCipher[] sc = {
  new SoundCipher(this), new SoundCipher(this), new SoundCipher(this), new SoundCipher(this), new SoundCipher(this)
  };

  import processing.video.*;
import java.awt.Point;

Point capturePoint;


import oscP5.*; // -->se importan las librerías oscP5 y netP5
import netP5.*;
import java.awt.Point;
OscP5 oscP5; //--> definición del objeto
NetAddress direccionRemota;
NetAddress myRemoteLocation; 
OscMessage myMessage;

OscP5 oscP5b;
ScreenCapturer capturer;



PImage destination;  // Destination image
PImage source, cam;       // Source image
float[] pitches = {
  0, 4, 7, 9
};
int tempo = 80;
int nbuttons=12;
int beat; // which beat we're on
float beatDur=0;
float tempoFrame=1;
float timeDuration=16;
float numBts=1;

boolean[] hatRow = new boolean[nbuttons];
boolean[] snrRow = new boolean[nbuttons];
boolean[] kikRow = new boolean[nbuttons];

ArrayList<Rect> buttons = new ArrayList<Rect>();

float interspace;
float wbuttons;
float initx;
float proporSpace=0.2;
float proporButton=0.8;

int w, h;
float[] proportionv = new float[3] ;
float[] proportionh =  new float[3] ;
int[] H = new int[3];
int[] V = new int[3];

void recordBass() {
  // bass

    float[] bassPitches = new float[4];

  float[] bassDynamics = new float[4];

  float[] bassDurations = new float[4];

  float[] bassArticulations = new float[4];

  float[] bassPans = new float[4];

  for (int i=0; i<4; i++) {

    if (i<1) {

      bassDurations[i] = 1;  

      bassPitches[i] = 30+random(10);
    } else {

      bassDurations[i] = random(1) * 0.5 + 0.5;

      bassPitches[i] = 36 + pitches[(int)(random(pitches.length))];
    }

    bassDynamics[i] = random(50) + 50;

    bassArticulations[i] = 0.7+random(0.7);

    bassPans[i] = random(127);
  }

  score[3].addPhrase(0, 0, 34, bassPitches, bassDynamics, bassDurations, bassArticulations, bassPans);
}



void setup()
{
  w=395;  
  h=200;
  size(395, 200);

  proportionh[0] = 1.0;
  proportionh[1] = 2.0 / 3.0 ; 
  proportionh[2] = 1.0 / 2.0; 

  proportionv[0] = 0; 
  proportionv[1] = 1.0 / 4.0 - 1.0 / 19.0; 
  proportionv[2] = 1.0 / 2.0 + 1.0 / 6 ;
  println("proportions = "+proportionh[0]+"  "+proportionh[1]+" "+proportionh[2]);
  H[0]=int((h * proportionh[0])-10);
  H[1]=int(h * proportionh[1]);
  H[2]=int(h * proportionh[2]);
  V[0]=int((w * proportionv[0]));
  V[1]=int(w * proportionv[1]);
  V[2]=int(w * proportionv[2]);

  println("Horizontaly = "+H[0]+"  "+H[1]+" "+H[2]);

  cam = createImage(w, h, RGB);
  capturer = new ScreenCapturer(w, h, 100, 100, 25);
  loadPixels();
  initx=((width / nbuttons)*proporSpace)*1;    
  interspace = ((width-initx*1)  / nbuttons) * proporSpace ;
  wbuttons = ((width-initx*1 ) / nbuttons) * proporButton ;
  for (int i = 0; i < nbuttons; i++)
  {
    buttons.add( new Rect(int(initx+interspace*(i)+i*wbuttons), H[2], hatRow, i ) );
    buttons.add( new Rect(int(initx+interspace*(i)+i*wbuttons), H[1], snrRow, i ) );
    buttons.add( new Rect(int(initx+interspace*(i)+i*wbuttons), H[0], kikRow, i ) );
  }
  beat = 0;
  score[1].tempo(tempo);
  score[2].tempo(tempo);
  score[3].tempo(tempo);
  score[1].addCallbackListener(this);  

  // kick drum
  score[1].addNote(0, 9, 0, 36, 100, 0.5, 0.8, 64);
  score[1].addNote(3.5, 9, 0, 36, 100, 0.5, 0.8, 64);

  // hi hats
  for (float i=0; i<8; i++) {
    score[2].addNote(i/2, 9, 0, 42, cos(i * 3.14159 * 2 * .25) * 30 + 70, 0.5, 0.8, 64);
  }

  //bass
  recordBass();
  //
  
  beatDur=60/tempo;
  //beat[2]=60/tempo;
  tempoFrame=map(beatDur, 0, timeDuration, 0, width);
  numBts=timeDuration/beatDur;
  frameRate(10);
}

void draw()
{
  getImage();
  fill(255);
  for (int i = 0; i < buttons.size (); ++i)
  {
    buttons.get(i).draw();
  }

  stroke(128);
  if ( beat % 4 == 0 )
  {
    fill(200, 0, 0);
  } else
  {
    fill(0, 200, 0);
  }
  // beat marker
  float arrow=initx+interspace*beat+beat*wbuttons;
  if (arrow<40 ) {
    frameRate(6);
  }
  if (arrow>40 && arrow<120) {
    frameRate(12);
  }
  if (arrow>120) {
    frameRate(24);
  }
  rect(arrow, 0, 14, 9);
  fill(0, 20, 0, 20);
  rect(V[1], 0, V[2]-V[1], height);
  line(V[0], 0, V[0], height);
  line(V[1], 0, V[1], height);
  line(V[2], 0, V[2], height);
  if (frameCount%2==0) {  
    if ( hatRow[beat] ) { 
      score[1].play();
    }
    if ( snrRow[beat] ) { 
      score[2].play();
    }
    if ( kikRow[beat] ) { 
      score[3].play();
    }
  } else {
    beat = (beat+1)%nbuttons;
  }
}


void getImage() {
  cam=capturer.getImage();
  image(cam, 0, 0);
  loadPixels();
}


boolean pointBright(int x, int y) {
  boolean pointb=false;
  float bright=0;
  color micolor;
  int loc = x+y*width;
  micolor = pixels[loc];
  bright=brightness(micolor);
  if (bright>240) {
    pointb=true;
  }
  return pointb;
}

class Rect 
{
  int x, y, w, h;
  boolean[] steps;
  int stepId;

  public Rect(int _x, int _y, boolean[] _steps, int _id)
  {
    x = _x;
    y = _y;
    w = int(wbuttons);
    h =  10;
    steps = _steps;
    stepId = _id;
  }

  public void draw()
  {
    steps[stepId]= pointBright(x, y);
    if ( steps[stepId] )
    {
      fill(0, 255, 0);
    } else
    {
      fill(255, 0, 0);
    }

    rect(x, y, w, h);
  }

  public void mousePressed()
  {
    if ( mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h )
    {
      steps[stepId] = !steps[stepId];
    }
  }
}

/////////////////////////

void handleCallbacks(int id) {
  score[1].tempo(tempo );
}


void mousePressed(){
}


void keyPressed() {
  if (key=='1') {
    frameRate(10);
    score[3].empty();
    recordBass();
    score[3].update();
  }
  if (key=='2') {
    frameRate(20);
  }
  if (key=='3') {
    frameRate(30);
  }
  if (key=='4') {
    frameRate(40);
  }
}
