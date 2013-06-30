import processing.video.*;
import javax.media.opengl.*;

int xSize   = 1650;
int ySize   = 1250;
int xMid    = xSize/2;
int yMid    = ySize/2;

int total   = 0;
int maxTent = 200;//100
Tentacle[] tentacle;

Meander meander;

boolean clear = true;
boolean click = false;

int counter = 0;

void setup() {
  size(xSize,ySize,OPENGL);
  smooth();
  colorMode(HSB,255);
  frameRate(30);
  
  ellipseMode(CENTER);
  tentacle =  new Tentacle[maxTent];
  meander = new Meander(xMid, yMid, 1);

  for (int i=0; i<maxTent; i++){
    tentacle[i] = new Tentacle(i);
  }
  
      //midicontrol
   midiIO = MidiIO.getInstance(this);
   //midiIO.plug(this,"noteOn",0,0);
   //midiIO.plug(this,"noteOff",0,0);
   midiIO.plug(this,"controllerIn",0,0);
   //midiIO.plug(this,"programChange",0,0);
}
 
void draw() {
    noCursor();
  drawState();
  maxTent = maxTentm;
  meander.exist();
  meander.noiseScale=noiseScalem;
                  println(noiseScalem);
  for (int i=0; i<total; i++){
    tentacle[i].move();
  }

  counter ++;
  
  if(total >= maxTent){
    tentacle[maxTent-1] = new Tentacle(maxTent-1);
    for (int i=1; i<maxTent; i++){
      tentacle[i-1] = tentacle[i];
    }
    total = maxTent;
  } else {
    total ++;
  }
  
  if (meander.outOfBounds){
    meander.x[0] = xMid;
    meander.x[1] = xMid;
    meander.y[0] = yMid;
    meander.y[1] = yMid;
    meander.outOfBounds = false;
  }
}


void drawState(){
  if (clear){
     background(166,200,0);
  } else {
  }
}

void keyReleased () {
  if (key == ' ' ) {
    clear = !clear;
  }
  
  if(key == '1'){
    bln_JAVA2D =!bln_JAVA2D;
  }
}





class Meander {
  boolean outOfBounds;
  float[] x;
  float[] y;
  float v;
  float xv;
  float yv;
  
  float theta;
  float angle;
  float angleDelta;
  float noiseVal;
  float noiseCount;
  float noiseScale = noiseScalem; //0.008
  
  Meander (int xSent, int ySent, int vSent){
    x = new float[2];
    y = new float[2];
  
    for (int i=0; i<=1; i++){
      x[i] = xSent;
      y[i] = ySent;
    }
    v = vSent;
  }
  
  void exist(){
    findVelocity();
    move();
    //render();
  }
  
  void findVelocity(){
    noiseCount += noiseScale;
    noiseVal = noise((x[0] + noiseCount) * noiseScale, (y[0] + noiseCount) * noiseScale, noiseCount);
    angle   -= (angle - noiseVal * 1440.0f) * .3f;
    theta    = -radians(angle);
    xv       = cos(theta) * v;
    yv       = sin(theta) * v;
  }
  
  
  void move(){
    x[1] = x[0];
    y[1] = y[0];
    
    x[0] -= xv;
    y[0] -= yv;
    
    if (x[0] < -150 || x[0] > xSize + 150 || y[0] < -150 || y[0] > ySize + 150){
      outOfBounds = true;
    }
  }
  
  void render(){
    noStroke();
    fill(255,15);
    ellipse(x[0],y[0],50,50);
  }
}


class Tentacle {
  int index;

  int numNodes           = numNodesm; //75
  float head             = headm;//1
  float girth            = girthm;//1

  //float muscleRange      = numNodes;
  //float muscleFreq       = numNodes/100.0f;
  
  float muscleRange      = 1;
  float muscleFreq       = .1;
  
  float theta;
  float thetaMuscle;
  float count = 0;
  float[] x;
  float[] y;
  float tv;
  float angle;
  float xOffset = xMid;
  float yOffset = yMid;
  boolean visible = true;

  Tentacle (int sentIndex) {
    index = sentIndex;
    x = new float[numNodes];
    y = new float[numNodes];
  }

  void move () {
    if (count == 0){
      x[0] = meander.x[0];
      y[0] = meander.y[0];
      angle = atan2((meander.y[0] - meander.y[1]), (meander.x[0] - meander.x[1]));
      
      for (int i=0; i<numNodes; i++){

        x[i] = meander.x[0];
        y[i] = meander.y[0];
      } 
    }

    angle = atan2((meander.y[0] - meander.y[1]), (meander.x[0] - meander.x[1]));
    x[0]         += head * cos(angle);
    y[0]         += head * sin(angle);
    count        += muscleFreq;
    thetaMuscle   = muscleRange * sin(count);
    x[1]         += (-head * cos((angle + thetaMuscle)));
    y[1]         += (-head * sin((angle + thetaMuscle)));

    for (int i=2; i<numNodes; i++){
      float dx = x[i] - x[i-2];
      float dy = y[i] - y[i-2];
      float d = sqrt(sq(dx) + sq(dy));
  
      float noiseVar = noise((x[i] + meander.noiseCount) * meander.noiseScale, (y[i] + meander.noiseCount) * meander.noiseScale, meander.noiseCount) * 720.0;
      float xVar = cos(radians(noiseVar)) * 1.5;
      float yVar = sin(radians(noiseVar)) * 1.5;
      x[i] = (x[i-1] + (dx * girth) / d) + xVar;
      y[i] = (y[i-1] + (dy * girth) / d) + yVar;
      

    }
    noFill();
    
    beginShape();
    for (int i=2; i<numNodes; i++){
      float myAngle = atan2((y[i] - y[i-1]), (x[i] - x[i-1]));
      float H = constrain(abs((myAngle * 100.0) - 122), 150, 225);
      float S = 50.0;
      float B = constrain(255 - abs((myAngle * 150.0) - 122), 0, 255);
      float A = 100 - count*10.0;
      //float A = 75;
      
      if (B > 100 && B < 120){
        B = 255;
        A *= 2.0;
      } else if (B > 225 && B < 255){
        H = 150;
        B = 200;
        A *= 2.0;
      } else {
        H = 150;
        B = (B + 50.0)/2.0;
      }
      if(bln_JAVA2D){
        if(i==numNodes-1){
            stroke(H,S,B,A);
        }
      }
      else{
        stroke(H,S,B,A);
      }
      vertex(x[i], y[i]);
    }
    endShape();
  }
}

boolean bln_JAVA2D = false;

