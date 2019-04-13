//import processing.serial.*;
import processing.net.*;
import controlP5.*;

ControlP5 cp5;
//Serial myPort; 
Server myServer;
boolean isAnimation = false;

// head_byte, number_byte, brightness_byte, end_byte
//byte sendBytes[] = {0x11,0x12,0x13,0x15};

byte headByte = 0x4C;
byte endByte = 0x42;

byte brightness[] = {0,0,0,0,0};
byte oneChannelNumber = 0;
int oneChannelTime = 0;

void setup(){
  
  myServer = new Server(this, 8899);
  
  size(800,500);
  
  cp5 = new ControlP5(this);

  
  cp5.addButton("setAllChannel_close")
     .setValue(0)
     .setPosition(50,100)
     .setSize(100,30)
     ;
  cp5.addButton("setAllChannel_open")
     .setValue(0)
     .setPosition(50,150)
     .setSize(100,30)
     ;
  cp5.addButton("setAllChannel")
     .setValue(0)
     .setPosition(50,200)
     .setSize(100,30)
     ;
  cp5.addButton("setAllChannel_time")
     .setValue(0)
     .setPosition(50,250)
     .setSize(100,30)
     ;
     
  cp5.addSlider("brightness_0")
     .setPosition(250,100)
     .setSize(200,20)
     .setRange(0,255)
     .setValue(0)
     ;
  cp5.addSlider("brightness_1")
     .setPosition(250,150)
     .setSize(200,20)
     .setRange(0,255)
     .setValue(0)
     ;
  cp5.addSlider("brightness_2")
     .setPosition(250,200)
     .setSize(200,20)
     .setRange(0,255)
     .setValue(0)
     ;
  cp5.addSlider("brightness_3")
     .setPosition(250,250)
     .setSize(200,20)
     .setRange(0,255)
     .setValue(0)
     ;
  cp5.addSlider("brightness_4")
     .setPosition(250,300)
     .setSize(200,20)
     .setRange(0,255)
     .setValue(0)
     ;
  
  cp5.addButton("setOneChannel")
     .setValue(0)
     .setPosition(50,300)
     .setSize(100,30)
     ;
  
  cp5.addTextfield("setOneChannelNumber")
     .setPosition(180,300)
     .setSize(50,30)
     .setFocus(true)
     .setColor(color(255,0,0))
     ;
     
  cp5.addButton("setOneChannel_time")
     .setValue(0)
     .setPosition(50,350)
     .setSize(100,30)
     ;
  
  cp5.addTextfield("setOneChannelTime")
     .setPosition(180,350)
     .setSize(50,30)
     .setFocus(true)
     .setColor(color(255,0,0))
     ;
  
  cp5.addToggle("animation")
     .setPosition(600,100)
     .setSize(50,20)
     ;
     
  sinWave = new float[ splitSin ];
  for(int i = 0 ; i < splitSin ; i++)
    sinWave[i] = sin(TWO_PI / splitSin * i);
}

void loop(){
  
}

void draw(){
  
  
  background(150);
  
  
  if(isAnimation){
    
    fill(200);
    rect(0, 0, 550, height);
    fill(150);
    rect(550, 0, width-550, height);
    
    DrawLights();
    
  }else{
    fill(150);
    rect(0, 0, 550, height);
    fill(200);
    rect(550, 0, width-550, height);
  }

}

public void setAllChannel_close(int theValue) {
  println("setSixChannel_colse");
  
  byte sendBytes[] = {headByte,0x01,endByte};
  
  if(!isAnimation)
    myServer.write(sendBytes);
}

public void setAllChannel_open(int theValue) {
  println("setSixChannel_open");
  
  byte sendBytes[] = {headByte, 0x02, endByte};
  
  if(!isAnimation)
    myServer.write(sendBytes);
}

public void setAllChannel(int theValue) {
  println("setSixChannel");
  
  byte sendBytes[] = {headByte,0x03,
                        //(byte)0xFF,(byte)0xFF,(byte)0xFF,(byte)0xFF,(byte)0xFF,
                        brightness[0],
                        brightness[1],
                        brightness[2],
                        brightness[3],
                        brightness[4],
                        endByte};
  
  if(!isAnimation)
    myServer.write(sendBytes);
}

public void setAllChannel_time(int theValue) {
  println("setSixChannel");
  
  byte highTime = (byte)((oneChannelTime >> 8) & 0xFF);
  byte lowTime = (byte)((oneChannelTime) & 0xFF);
  
  byte sendBytes[] = {headByte,0x04,
                        //(byte)0xFF,(byte)0xFF,(byte)0xFF,(byte)0xFF,(byte)0xFF,
                        brightness[0],
                        brightness[1],
                        brightness[2],
                        brightness[3],
                        brightness[4],
                        lowTime,
                        highTime,
                        endByte};
  
  if(!isAnimation)
    myServer.write(sendBytes);
}

void brightness_0(float _b) {
  brightness[0] = (byte)round(_b);
}
void brightness_1(float _b) {
  brightness[1] = (byte)round(_b);
}
void brightness_2(float _b) {
  brightness[2] = (byte)round(_b);
}
void brightness_3(float _b) {
  brightness[3] = (byte)round(_b);
}
void brightness_4(float _b) {
  brightness[4] = (byte)round(_b);
}


public void setOneChannel(int theValue) {
  println("setOneChannel , "+ oneChannelNumber + "," + brightness[oneChannelNumber]);
  
  byte sendBytes[] = {headByte,0x05,
                        oneChannelNumber,brightness[oneChannelNumber],
                        endByte};              
  if(!isAnimation)
    myServer.write(sendBytes);                   
}

public void setOneChannelNumber(String theText) {
  
  int number = Integer.parseInt(theText);
  if(number >= 0 && number <=5)
      oneChannelNumber = (byte)number;
  // automatically receives results from controller input
  //println("a textfield event for controller 'input' : "+theText);
}

public void setOneChannel_time(int theValue) {
  println("setOneChannel_time");
  
  byte highTime = (byte)((oneChannelTime >> 8) & 0xFF);
  byte lowTime = (byte)((oneChannelTime) & 0xFF);
  
  byte sendBytes[] = {headByte,0x06,
                        oneChannelNumber,brightness[oneChannelNumber],
                        lowTime,highTime,
                        endByte};
  
  //println(hex(lowTime) + "," + hex(highTime));
  if(!isAnimation)
    myServer.write(sendBytes);
}

public void setOneChannelTime(String theText) {
  
  int number = Integer.parseInt(theText);
  if(number >= 0 && number <=65535)
      oneChannelTime = number;
  // automatically receives results from controller input
  //println("a textfield event for controller 'input' : "+theText);
}

void animation(boolean theFlag) {
  if(theFlag==true) {
    isAnimation = true;
  } else {
    isAnimation = false;
  }
}


// -- Animation Test

int splitSin = 5000;
float sinWave[];
int numberOfCircle = 5;
int distance = 50;
int b;

void DrawLights(){
  
  pushMatrix();
  translate(300,0);
  for(int i = 0 ; i < numberOfCircle ; i++){
    pushMatrix();//
    translate( sin( (TWO_PI/numberOfCircle) * i ) * distance , cos( (TWO_PI/numberOfCircle) * i ) * distance );//
    
    float waveData = sin( (TWO_PI/splitSin)* millis() - TWO_PI/numberOfCircle * i );
    float pow2sin = pow(waveData + abs(waveData) , 2 );
    b = (int)(127* (1+ map(pow2sin , 0 , 4 , -1 , 1) ) );
    brightness[i] = (byte)b;
    
    
    fill(b);
    //arc(width/2,height/2 ,50 ,50 , 0 ,TWO_PI/numberOfCircle * i +1 , CHORD);
    ellipse(width/2 , height/2 , 20 , 20);
    
    popMatrix(); 
  } 
  
  popMatrix();
  
  byte sendBytes[] = {headByte,0x03,
                        //(byte)0xFF,(byte)0xFF,(byte)0xFF,(byte)0xFF,(byte)0xFF,
                        brightness[0],
                        brightness[1],
                        brightness[2],
                        brightness[3],
                        brightness[4],
                        endByte};
  
  
  myServer.write(sendBytes);
}