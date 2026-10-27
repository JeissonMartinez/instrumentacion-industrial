#include <SD.h>

//Author: eletechsup
//More information welcome to : http://www.485io.com 
//Arduino 0022
//for Arduino MEGA2560 R3
//4 bit Common Cathode Digital Tube Module test code,use Timer2

//When leaving the factory, it is used to verify the function of the board.



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
char out_num;

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

//Input current value, unit 0.01MA
int I1_Current=0;
int I2_Current=0;
int I3_Current=0;
int I4_Current=0;
int I5_Current=0;
int I6_Current=0;
int I7_Current=0;
int I8_Current=0;

//Input voltage value, unit 0.01V
int V1_Voltage=0;
int V2_Voltage=0;
int V3_Voltage=0;
int V4_Voltage=0;
int V5_Voltage=0;
int V6_Voltage=0;
int V7_Voltage=0;
int V8_Voltage=0;

//If there is a deviation in the reading, it may be the error of the 5V power supply voltage 
//or the error of the sampling resistor value. This is a linear error, which can be calibrated by the error ratio.
float I1_Calibration_value = 1000/1000; //I1 current calibration value
float I2_Calibration_value = 1000/1000; //I2 current calibration value
float I3_Calibration_value = 1000/1000; //I3 current calibration value
float I4_Calibration_value = 1000/1000; //I4 current calibration value
float I5_Calibration_value = 1000/1000; //I1 current calibration value
float I6_Calibration_value = 1000/1000; //I2 current calibration value
float I7_Calibration_value = 1000/1000; //I3 current calibration value
float I8_Calibration_value = 1000/1000; //I4 current calibration value

float V1_Calibration_value = 1000/1000; //V1 voltage calibration value
float V2_Calibration_value = 1000/1000; //V2 voltage calibration value
float V3_Calibration_value = 1000/1000; //V3 voltage calibration value
float V4_Calibration_value = 1000/1000; //V4 voltage calibration value
float V5_Calibration_value = 1000/1000; //V1 voltage calibration value
float V6_Calibration_value = 1000/1000; //V2 voltage calibration value
float V7_Calibration_value = 1000/1000; //V3 voltage calibration value
float V8_Calibration_value = 1000/1000; //V4 voltage calibration value

// II1-II4 0-20MA current analog input
//The sampling resistor is 0.24K(240Ω), and the ADC reference voltage is 5.00V(500*0.01MA)
//Current_ratio_value = (5.00/0.24/1024)*100
#define Current_ratio_value_20MA  2.0345

// II5-II8 0-100MA current analog input
//The sampling resistor is 0.047K(47Ω), and the ADC reference voltage is 5.00V(500*0.01MA)
//Current_ratio_value = (5.00/0.047/1024)*100
#define Current_ratio_value_100MA  10.38896

//V1-V4 0-10V voltage analog input
//The voltage dividing resistors are 12KΩ and 10KΩ, and the ADC reference voltage is 5.00V
//Voltage_ratio_value = 5.00 * (100+120)/1024
#define Voltage_ratio_value_10V 1.0742

//V5-V8 0-30V voltage analog input
//The voltage dividing resistors are 51KΩ and 100KΩ, and the ADC reference voltage is 5.00V
//Voltage_ratio_value = 5.00 * (100+510)/1024
#define Voltage_ratio_value_30V 2.9785




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

  
   if(digitalRead(KEY1)==LOW) {digitalWrite(LED1, LOW);} else {digitalWrite(LED1, HIGH);}
   if(digitalRead(KEY2)==LOW) {digitalWrite(LED2, LOW);} else {digitalWrite(LED2, HIGH);}
   if(digitalRead(KEY3)==LOW) {digitalWrite(LED3, LOW);} else {digitalWrite(LED3, HIGH);}
   if(digitalRead(KEY4)==LOW) {;digitalWrite(LED4, LOW);} else {digitalWrite(LED4, HIGH);}

  if(digitalRead(IN1)==LOW) {display_dat = 1;}
  else if(digitalRead(IN2)==LOW) {display_dat = 2;}
  else if(digitalRead(IN3)==LOW) {display_dat = 3;}
  else if(digitalRead(IN4)==LOW) {display_dat = 4;}
  else if(digitalRead(IN5)==LOW) {display_dat = 5;}
  else if(digitalRead(IN6)==LOW) {display_dat = 6;}
  else if(digitalRead(IN7)==LOW) {display_dat = 7;}
  else if(digitalRead(IN8)==LOW) {display_dat = 8;}
  else if(digitalRead(IN9)==LOW) {display_dat = 1;}
  else if(digitalRead(IN10)==LOW) {display_dat = 2;}
  else if(digitalRead(IN11)==LOW) {display_dat = 3;}
  else if(digitalRead(IN12)==LOW) {display_dat = 4;}
  else if(digitalRead(IN13)==LOW) {display_dat = 5;}
  else if(digitalRead(IN14)==LOW) {display_dat = 6;}
  else if(digitalRead(IN15)==LOW) {display_dat = 7;}
  else if(digitalRead(IN16)==LOW) {display_dat = 8;}
  
  while (Serial2.available() > 0)   { display_dat = char(Serial2.read()) - 48;}
     

    
   dat_buf[0] = display_dat;
   dat_buf[2] = display_dat;
   dat_buf[4] = display_dat;
   dat_buf[6] = display_dat;
  
}

void setup() {
  
   //set pins to output because they are addressed in the main loop
   
  Serial2.begin(9600);
  pinMode(RS485_RD, OUTPUT);
  analogReference(DEFAULT); // use 5V DEFAULT for reference voltage
  digitalWrite(RS485_RD, LOW); //Set RS485 to Read 
   
  
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
   pinMode(IN9, INPUT);
   pinMode(IN10, INPUT);
   pinMode(IN11, INPUT);
   pinMode(IN12, INPUT);
   pinMode(IN13, INPUT);
   pinMode(IN14, INPUT);
   pinMode(IN15, INPUT);
   pinMode(IN16, INPUT);
   
   pinMode(LED1, OUTPUT);
   pinMode(LED2, OUTPUT);
   pinMode(LED3, OUTPUT);
   pinMode(LED4, OUTPUT);
   
   pinMode(RO1, OUTPUT);
   pinMode(RO2, OUTPUT);
   pinMode(RO3, OUTPUT);
   pinMode(RO4, OUTPUT);
   pinMode(RO5, OUTPUT);
   pinMode(RO6, OUTPUT);
   pinMode(RO7, OUTPUT);
   pinMode(RO8, OUTPUT);
   
   pinMode(DO1, OUTPUT);
   pinMode(DO2, OUTPUT);
   pinMode(DO3, OUTPUT);
   pinMode(DO4, OUTPUT);
   pinMode(DO5, OUTPUT);
   pinMode(DO6, OUTPUT);
   pinMode(DO7, OUTPUT);
   pinMode(DO8, OUTPUT);
   
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
  digitalWrite(IN9, HIGH);
  digitalWrite(IN10, HIGH);
  digitalWrite(IN11, HIGH);
  digitalWrite(IN12, HIGH);
  digitalWrite(IN13, HIGH);
  digitalWrite(IN14, HIGH);
  digitalWrite(IN15, HIGH);
  digitalWrite(IN16, HIGH);
  
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
    
    
    //Input current value, unit 0.01MA
    delay(1000);
    digitalWrite(RS485_RD,HIGH); //Set RS485 to Write
    
    I1_Current = Current_ratio_value_20MA*analogRead(II1); 
    I1_Current = I1_Current * I1_Calibration_value; //error calibration
    I2_Current = Current_ratio_value_20MA*analogRead(II2); 
    I2_Current = I2_Current * I2_Calibration_value;  //error calibration
    I3_Current =Current_ratio_value_20MA*analogRead(II3); 
    I3_Current = I3_Current * I3_Calibration_value;  //error calibration
    I4_Current = Current_ratio_value_20MA*analogRead(II4); 
    I4_Current = I4_Current * I4_Calibration_value;  //error calibration
    
    I5_Current = Current_ratio_value_100MA*analogRead(II5); 
    I5_Current = I5_Current * I5_Calibration_value; //error calibration
    I6_Current = Current_ratio_value_100MA*analogRead(II6); 
    I6_Current = I6_Current * I6_Calibration_value; //error calibration
    I7_Current = Current_ratio_value_100MA*analogRead(II7); 
    I7_Current = I7_Current * I7_Calibration_value; //error calibration
    I8_Current = Current_ratio_value_100MA*analogRead(II8); 
    I8_Current = I8_Current * I8_Calibration_value; //error calibration
    
    V1_Voltage = Voltage_ratio_value_10V*analogRead(VI1);  
    V1_Voltage = V1_Voltage * V1_Calibration_value;  //error calibration
    V2_Voltage = Voltage_ratio_value_10V*analogRead(VI2); 
    V2_Voltage = V2_Voltage * V2_Calibration_value;  //error calibration
    V3_Voltage = Voltage_ratio_value_10V*analogRead(VI3);
    V3_Voltage = V3_Voltage * V3_Calibration_value;  //error calibration
    V4_Voltage = Voltage_ratio_value_10V*analogRead(VI4);  
    V4_Voltage = V4_Voltage * V4_Calibration_value;  //error calibration
    
    V5_Voltage = Voltage_ratio_value_30V*analogRead(VI5);  
    V5_Voltage = V5_Voltage * V5_Calibration_value;  //error calibration
    V6_Voltage = Voltage_ratio_value_30V*analogRead(VI6);  
    V6_Voltage = V6_Voltage * V6_Calibration_value;  //error calibration
    V7_Voltage = Voltage_ratio_value_30V*analogRead(VI7);  
    V7_Voltage = V7_Voltage * V7_Calibration_value;  //error calibration
    V8_Voltage = Voltage_ratio_value_30V*analogRead(VI8);  
    V8_Voltage = V8_Voltage * V8_Calibration_value;  //error calibration
     
    Serial2.print("II1:");   
    Serial2.print(I1_Current); 
    Serial2.print("  II2:");   
    Serial2.print(I2_Current);   
    Serial2.print("  II3:");   
    Serial2.print(I3_Current);
    Serial2.print("  II4:");   
    Serial2.print(I4_Current);
    Serial2.print("  II5:");   
    Serial2.print(I5_Current);
    Serial2.print("  II6:");   
    Serial2.print(I6_Current);
    Serial2.print("  II7:");   
    Serial2.print(I7_Current);
    Serial2.print("  II8:");   
    Serial2.print(I8_Current);
    
    Serial2.print("  VI1:");   
    Serial2.print(V1_Voltage);  
    Serial2.print("  VI2:");   
    Serial2.print(V2_Voltage);  
    Serial2.print("  VI3:");   
    Serial2.print(V3_Voltage);   
    Serial2.print("  VI4:");   
    Serial2.print(V4_Voltage);  
    Serial2.print("  VI5:");   
    Serial2.print(V5_Voltage);  
    Serial2.print("  VI6:");   
    Serial2.print(V6_Voltage);  
    Serial2.print("  VI7:");   
    Serial2.print(V7_Voltage);  
    Serial2.print("  VI8:");   
    Serial2.println(V8_Voltage);  
    delay(2);//Delay 2 milliseconds, wait for the data to be sent, this delay is necessary
    digitalWrite(RS485_RD, LOW); //Set RS485 to Read 
  
   switch(out_num){
   case 0 :  digitalWrite(RO1, !digitalRead(RO1)); digitalWrite(DO1, !digitalRead(DO1)); break;
   case 1 :  digitalWrite(RO2, !digitalRead(RO2)); digitalWrite(DO2, !digitalRead(DO2)); break;
   case 2 :  digitalWrite(RO3, !digitalRead(RO3)); digitalWrite(DO3, !digitalRead(DO3)); break;
   case 3 :  digitalWrite(RO4, !digitalRead(RO4)); digitalWrite(DO4, !digitalRead(DO4)); break;
   case 4 :  digitalWrite(RO5, !digitalRead(RO5)); digitalWrite(DO5, !digitalRead(DO5)); break;
   case 5 :  digitalWrite(RO6, !digitalRead(RO6)); digitalWrite(DO6, !digitalRead(DO6)); break;
   case 6 :  digitalWrite(RO7, !digitalRead(RO7)); digitalWrite(DO7, !digitalRead(DO7)); break;
   case 7 :  digitalWrite(RO8, !digitalRead(RO8)); digitalWrite(DO8, !digitalRead(DO8)); break;
   
   default : break;
   }
   if(out_num<7) out_num ++;else out_num=0;
      
  }
} 
