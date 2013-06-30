import promidi.*;
int numNodesm=2;
float headm=1;
float girthm=1;
int maxTentm=10;
float noiseScalem=0.005;

MidiIO midiIO;

void controllerIn(Controller controller){
  int num = controller.getNumber();
  float val = controller.getValue();
  

/*  if(num == 24){
    scalar=-val*.8f;
  }
 else if(num == 27){
    scalar=val*.2f;
  }

  if(num == 34){
    yTrans =val*30;
  }*/
  
 if(num == 14){ //31
   noiseScalem = val/127*0.3;

  }

  if(num == 15){//35
    maxTentm =int(val/127*200);

  }
  if(num == 16){//32
    numNodesm =int(val)*2+20;

  }
  if(num == 17){//36
  headm =20*val/127;

  }
  if(num == 18){//33
  girthm= val;
  } 
}

