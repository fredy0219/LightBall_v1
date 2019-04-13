
struct LED{
  byte brightness = 0;
  byte brightness_temp = 0; // record the start point of brightness
  byte brightness_target = 0;

  unsigned long startTime = 0;
  unsigned long targetTime = 0;
};

LED led[5];
byte PWM_PIN[] = {3, 5, 6, 9 , 10};

byte headByte = 0x4C;
byte endByte = 0x42;

union byteToInt
{
    struct
    {
      byte b0 :8;
      byte b1 :8;
    } bytes;

    uint16_t i;
};

void setup() {
  // put your setup code here, to run once:

  pinMode(3,OUTPUT);
  pinMode(5,OUTPUT);
  pinMode(6,OUTPUT);
  pinMode(9,OUTPUT);
  pinMode(10,OUTPUT);

  for(byte i = 0 ; i < 5 ; i++)
    analogWrite(PWM_PIN[i], 0);
  
  Serial.begin(57600);


}

void loop() {
  
  if(Serial.available()>0){

    byte incomingBytes[20];
    int sizeread = Serial.readBytesUntil(endByte,incomingBytes,20);

    switch( incomingBytes[1] ){
      case 0x01:
        setAllChannel_close(); break;
      case 0x02:
        setAllChannel_open(); break;
      case 0x03:
        byte allChannelBytes[5];
        memcpy(allChannelBytes, incomingBytes+2, 5*sizeof(byte));
        setAllChannel( allChannelBytes ); break;
      case 0x04:
        byte allChannelTimeBytes[6];
        memcpy(allChannelBytes, incomingBytes+2, 7*sizeof(byte));
        setAllChannel_time( allChannelBytes ); break;
      case 0x05:
        byte oneChannelBytes[2];
        memcpy(oneChannelBytes, incomingBytes+2, 2*sizeof(byte));
        setOneChannel( oneChannelBytes ); break;
      case 0x06:
        byte oneChannelTimeBytes[4];
        memcpy(oneChannelTimeBytes, incomingBytes+2, 4*sizeof(byte));
        setOneChannel_time( oneChannelTimeBytes ); break; 
    }
  }


  for(byte i = 0 ; i < 5 ; i++)
    if(led[i].brightness_target != led[i].brightness){
      float t = (millis() - led[i].startTime) / (float)led[i].targetTime;
      led[i].brightness = (byte)( lerp( led[i].brightness_temp, led[i].brightness_target, t));
      analogWrite(PWM_PIN[i],led[i].brightness);
    }
  
  

}

void setAllChannel_close(){
  
  for(byte i = 0 ; i < 5 ; i++){
    led[i].brightness = 0;
    led[i].brightness_target = 0;
    analogWrite(PWM_PIN[i],0);
  }
}

void setAllChannel_open(){

  for(byte i = 0 ; i < 5 ; i++){
    led[i].brightness = 255;
    led[i].brightness_target = 255;
    analogWrite(PWM_PIN[i],255);
  }

}
// -- SET ALL CHANNEL LED
// data = [ 0_brightness, 1_brightness, 2_brightness, 3_brightness, 4_brightness ]
void setAllChannel(byte *data ){
  
  for(byte i = 0 ; i < 5; i++){
    led[i].brightness = data[i];
    led[i].brightness_target = data[i];
    analogWrite(PWM_PIN[i], data[i]);
  }
  
}

// -- SET ALL CHANNEL LED WITH TIME
// data = [ 0_brightness, 1_brightness, 2_brightness, 3_brightness, 4_brightness , low_time, high_time]
void setAllChannel_time(byte *data){

  byteToInt time_millis;
  time_millis.bytes.b0 = data[5];
  time_millis.bytes.b1 = data[6];

  for(byte i = 0 ; i < 5; i++){
    
    led[i].brightness_temp = led[i].brightness;
    led[i].brightness_target = data[i];

    led[i].targetTime = time_millis.i;
    unsigned long m = millis();
    led[i].startTime = m;
  }

}

// -- SET ONE CHANNEL LED
// data = [ channel, brightness ]
void setOneChannel(byte *data ){

  byte channel = data[0];
  led[channel].brightness = data[1];
  led[channel].brightness_target = data[1];
  analogWrite(PWM_PIN[channel], led[channel].brightness);
  
}

// -- SET ONE CHANNEL LED with TIME
// data = [ channel, brightness, time_low, time_high]
void setOneChannel_time(byte *data ){

  byte channel = data[0];
  
  led[channel].brightness_temp = led[channel].brightness;
  led[channel].brightness_target = data[1];
  
  byteToInt time_millis;
  time_millis.bytes.b0 = data[2];
  time_millis.bytes.b1 = data[3];

  led[channel].targetTime = time_millis.i;
  led[channel].startTime = millis();
  
  
}

float lerp(byte start_b, byte end_b, float scale){

  return (start_b + scale * (end_b - start_b));
}

float mapfloat(float x, float in_min, float in_max, float out_min, float out_max)
{
 return (float)(x - in_min) * (out_max - out_min) / (float)(in_max - in_min) + out_min;
}

