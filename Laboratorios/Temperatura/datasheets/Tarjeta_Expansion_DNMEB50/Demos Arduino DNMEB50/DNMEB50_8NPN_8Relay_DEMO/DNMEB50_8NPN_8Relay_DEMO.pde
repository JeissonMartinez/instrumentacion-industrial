#include <SD.h>

//Author: eletechsup
//More information welcome to : http://www.485io.com 
//Arduino 0022
//for Arduino MEGA2560 R3
//4 bit Common Cathode Digital Tube Module test code,use Timer2

//8 channel delay relay delay
//Resources used: 4x buttons; 4 bit digital tubes, 8x NPN inputs, 8x relays



/*---Segment Display Screen----
--A--
F---B
--G--
E---C
--D-- 
 __  __   __  __
|__||__|.|__||__|
|__||__|'|__||__|
----------------------*/
#include <FlexiTimer2.h>
#define uchar unsigned char 
#define uint  unsigned int

int display_dat; 
int key_value;

//74HC595 for control digital tube
//Pin connected to latch of Digital Tube Module
int latchPin = 8;
//Pin connected to clock of Digital Tube Module
int clockPin =7;
//Pin connected to data of Digital Tube Module
int dataPin = 10;
//Pin connected to 595_OE of Digital Tube Module
int OE_595 = 9;

//4 buttons keys
const int KEY1 = 21;
const int KEY2 = 20;
const int KEY3 = 12;
const int KEY4 = 11;

//4 LED indicator light outputs, low level ON
const int LED1 = 34;
const int LED2 = 36;
const int LED3 = 38;
const int LED4 = 40;

//8 NPN digital inputs
const int IN1 = 6;
const int IN2 = 5;
const int IN3 = 4;
const int IN4 = 3;
const int IN5 = 2;
const int IN6 = 14;
const int IN7 = 15;
const int IN8 = 19;

//8 PNP digital inputs
const int IN9 = 32;
const int IN10 = 30;
const int IN11 = 28;
const int IN12 = 22;
const int IN13 = 23;
const int IN14 = 24;
const int IN15 = 25;
const int IN16 = 26;

//8-channel ULN2803 Darlington NPN output
const int DO1 = 41;
const int DO2 = 39;
const int DO3 = 37;
const int DO4 = 35;
const int DO5 = 33;
const int DO6 = 31;
const int DO7 = 29;
const int DO8 = 27;

//8-channel 3A relay output
const int RO1 = 43;
const int RO2 = 45;
const int RO3 = 47;
const int RO4 = 49;
const int RO5 = 50;
const int RO6 = 51;
const int RO7 = 52;
const int RO8 = 53;

//4 channels 0-20MA current analog input
const int II1 = A0;
const int II2 = A1;
const int II3 = A2;
const int II4 = A3;

//4 channels 0-100MA current analog input
const int II5 = A4;
const int II6 = A5;
const int II7 = A6;
const int II8 = A7;

//4 channels 0-10V voltage analog input
const int VI1 = A8;
const int VI2 = A9;
const int VI3 = A10;
const int VI4 = A11;

//4 channels 0-20V voltage analog input
const int VI5 = A12;
const int VI6 = A13;
const int VI7 = A14;
const int VI8 = A15;

const int RS485_RD =18;

//The voltage dividing resistors are 120KΩ and 100KΩ, and the ADC reference voltage is 5.00V
//Voltage_ratio_value = 5.00 * (100+120)/1024
#define Voltage_ratio_value 1.0742

//The sampling resistor is 0.2K(200Ω), and the ADC reference voltage is 5.00V(500*0.01MA)
//Current_ratio_value = (5.00/0.2/1024)*100
#define Current_ratio_value  2.4414



int relay1_delay_time = 1;//1-9999 seconds,Modify the number change the delay time
int relay2_delay_time = 2;//1-9999 seconds,Modify the number change the delay time
int relay3_delay_time = 3;//1-9999 seconds,Modify the number change the delay time
int relay4_delay_time = 4;//1-9999 seconds,Modify the number change the delay time
int relay5_delay_time = 5;//1-9999 seconds,Modify the number change the delay time
int relay6_delay_time = 6;//1-9999 seconds,Modify the number change the delay time
int relay7_delay_time = 7;//1-9999 seconds,Modify the number change the delay time
int relay8_delay_time = 8;//1-9999 seconds,Modify the number change the delay time9
int relay1_time_left;
int relay2_time_left;
int relay3_time_left;
int relay4_time_left;
int relay5_time_left;
int relay6_time_left;
int relay7_time_left;
int relay8_time_left;

int relay1_display;
int relay2_display;
int relay3_display;
int relay4_display;
int relay5_display;
int relay6_display;
int relay7_display;
int relay8_display;



/*       NO.:0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22 23 24 25 26 27 28      
/*Character :0,1,2,3,4,5,6,7,8,9,A, b, C, c, d, E, F, H, h, L, n, N, o, P, r, t, U, -,  ,*/
uchar  TUBE_SEG[] = 
{0x3f,0x06,0x5b,0x4f,0x66,0x6d,0x7d,0x07,0x7f,0x6f,0x77,0x7c,0x39,0x58,0x5e,0x79,0x71,0x76,0x74,0x38,0x54,0x37,0x5c,0x73,0x50,0x78,0x3e,0x40,0x00};//Common anode Digital Tube Character Gallery

uchar TUBE_NUM[8]={0xfe,0xff,0xfd,0xff,0xfb,0xff,0xf7,0xff,};//Tuble bit number

uchar dat_buf[8];

//***********************************************
// dat : Data to be displayed
// com_num :  Digital Tube Common 
//relay_port : Relay port
//***********************************************
uchar dat;
uchar com_num;
uchar relay_port;
void TubeDisplayOneBit()
{
  uchar tube_dat,bit_num;
  uchar display_l,display_h,relay_dat;
   
   //digitalWrite(13,!digitalRead(13));
   tube_dat = TUBE_SEG[dat]; //Common Cathode Digital Tube,bit negated
   bit_num = TUBE_NUM[com_num];
   
     //ground latchPin and hold low for as long as you are transmitting
     digitalWrite(latchPin, LOW);  
     
     shiftOut(dataPin, clockPin, MSBFIRST, bit_num);
     shiftOut(dataPin, clockPin, MSBFIRST, tube_dat);  

     //return the latch pin high to signal chip that it 
     //no longer needs to listen for information
     digitalWrite(latchPin, HIGH);

}




uint OneSecondCnt=500;
void TubeDisplay4Bit(void)
{
  if(com_num<7) com_num ++;else com_num=0;
  dat = dat_buf[com_num];
  TubeDisplayOneBit();

  OneSecondCnt--;
  if(OneSecondCnt==0)
  {
    OneSecondCnt = 500;
    if(relay1_time_left>0){relay1_time_left--; relay1_display = relay1_time_left;} else {digitalWrite(RO1, LOW);relay1_display = relay1_delay_time;}
    if(relay2_time_left>0){relay2_time_left--; relay2_display = relay2_time_left;} else {digitalWrite(RO2, LOW);relay2_display = relay2_delay_time;}
    if(relay3_time_left>0){relay3_time_left--; relay3_display = relay3_time_left;} else {digitalWrite(RO3, LOW);relay3_display = relay3_delay_time;}
    if(relay4_time_left>0){relay4_time_left--; relay4_display = relay4_time_left;} else {digitalWrite(RO4, LOW);relay4_display = relay4_delay_time;}
    if(relay5_time_left>0){relay5_time_left--; relay5_display = relay5_time_left;} else {digitalWrite(RO5, LOW);relay5_display = relay5_delay_time;}
    if(relay6_time_left>0){relay6_time_left--; relay6_display = relay6_time_left;} else {digitalWrite(RO6, LOW);relay6_display = relay6_delay_time;}
    if(relay7_time_left>0){relay7_time_left--; relay7_display = relay7_time_left;} else {digitalWrite(RO7, LOW);relay7_display = relay7_delay_time;}
    if(relay8_time_left>0){relay8_time_left--; relay8_display = relay8_time_left;} else {digitalWrite(RO8, LOW);relay8_display = relay8_delay_time;}
   
  }

  if(key_value==0) display_dat = relay1_display; 
  else if(key_value==1) display_dat = relay2_display;
  else if(key_value==2) display_dat = relay3_display;  
  else if(key_value==3) display_dat = relay4_display;

    
   dat_buf[0] = display_dat/1000;
   display_dat = display_dat%1000;
   dat_buf[2] = display_dat/100;
   display_dat = display_dat%100;
   dat_buf[4] = display_dat/10;
   dat_buf[6] = display_dat%10;
  
}

void setup() {
  
   //set pins to output because they are addressed in the main loop
  
   pinMode(latchPin, OUTPUT);
   pinMode(clockPin, OUTPUT);
   pinMode(dataPin, OUTPUT);
   pinMode(OE_595, OUTPUT);
   
   pinMode(KEY1, INPUT);
   pinMode(KEY2, INPUT);
   pinMode(KEY3, INPUT);
   pinMode(KEY4, INPUT);
   
   pinMode(IN1, INPUT);
   pinMode(IN2, INPUT);
   pinMode(IN3, INPUT);
   pinMode(IN4, INPUT);
   pinMode(IN5, INPUT);
   pinMode(IN6, INPUT);
   pinMode(IN7, INPUT);
   pinMode(IN8, INPUT);
   
   pinMode(RO1, OUTPUT);
   pinMode(RO2, OUTPUT);
   pinMode(RO3, OUTPUT);
   pinMode(RO4, OUTPUT);
   pinMode(RO5, OUTPUT);
   pinMode(RO6, OUTPUT);
   pinMode(RO7, OUTPUT);
   pinMode(RO8, OUTPUT);
   
  FlexiTimer2::set(2, 1.0/1000, TubeDisplay4Bit); // call every 2ms "ticks"
  FlexiTimer2::start();
  

  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, HIGH);
  digitalWrite(IN3, HIGH);
  digitalWrite(IN4, HIGH);
  digitalWrite(IN5, HIGH);
  digitalWrite(IN6, HIGH);
  digitalWrite(IN7, HIGH);
  digitalWrite(IN8, HIGH);
  
  
  digitalWrite(KEY1, HIGH);
  digitalWrite(KEY2, HIGH);
  digitalWrite(KEY3, HIGH);
  digitalWrite(KEY4, HIGH);
  
  key_value = 0;
  
  delay(100);
  digitalWrite(OE_595, LOW);// Enable 74HC595  
}

void loop() {

  while(1)
  {
   
    if(digitalRead(IN1)==LOW) {relay1_time_left = relay1_delay_time;digitalWrite(RO1, HIGH);}
    if(digitalRead(IN2)==LOW) {relay2_time_left = relay2_delay_time;digitalWrite(RO2, HIGH);}
    if(digitalRead(IN3)==LOW) {relay3_time_left = relay3_delay_time;digitalWrite(RO3, HIGH);}
    if(digitalRead(IN4)==LOW) {relay4_time_left = relay4_delay_time;digitalWrite(RO4, HIGH);}
    if(digitalRead(IN5)==LOW) {relay5_time_left = relay5_delay_time;digitalWrite(RO5, HIGH);}
    if(digitalRead(IN6)==LOW) {relay6_time_left = relay6_delay_time;digitalWrite(RO6, HIGH);}
    if(digitalRead(IN7)==LOW) {relay7_time_left = relay7_delay_time;digitalWrite(RO7, HIGH);}
    if(digitalRead(IN8)==LOW) {relay8_time_left = relay8_delay_time;digitalWrite(RO8, HIGH);}

    
    if     (digitalRead(KEY1)==LOW) {key_value = 0;  } 
    else if(digitalRead(KEY2)==LOW) {key_value = 1;  } 
    else if(digitalRead(KEY3)==LOW) {key_value = 2; } 
    else if(digitalRead(KEY4)==LOW) {key_value = 3; } 
      
  }
} 
