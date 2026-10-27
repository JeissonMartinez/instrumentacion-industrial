//Author: eletechsup
//More information welcome to : http://www.485io.com 
//Arduino 0022
//for Arduino MEGA2560 R3
//RS485 receiving and sending test.
//Enter one Arabic numerals, return one Arabic numerals

const int RS485_RD =18;


int incomingByte = 0; // for incoming serial data

void setup() {
  Serial2.begin(9600); // opens serial port, sets data rate to 9600 bps
   pinMode(RS485_RD, OUTPUT);
   digitalWrite(RS485_RD, LOW); //Set RS485 to Read 
}

void loop() {
  // send data only when you receive data:
  if (Serial2.available() > 0) {
    // read the incoming byte:
    incomingByte = Serial2.read();
   digitalWrite(RS485_RD, HIGH); //Set RS485 to Write
    // say what you got:
    Serial2.print("I received: ");
    Serial2.println(incomingByte-48);
    delay(2);
    digitalWrite(RS485_RD, LOW); //Set RS485 to Read 
  }
  
}

