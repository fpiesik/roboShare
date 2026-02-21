/*
  Analog input, analog output, serial output

 Reads an analog input pin, maps the result to a range from 0 to 255
 and uses the result to set the pulsewidth modulation (PWM) of an output pin.
 Also prints the results to the serial monitor.

 The circuit:
 * potentiometer connected to analog pin 0.
   Center pin of the potentiometer goes to the analog pin.
   side pins of the potentiometer go to +5V and ground
 * LED connected from digital pin 9 to ground

 created 29 Dec. 2008
 modified 9 Apr 2012
 by Tom Igoe

 This example code is in the public domain.

 */

// These constants won't change.  They're used to give names
// to the pins used:

const int pot1 = A9;
const int pot2 = A7;
const int pot3 = A5;
const int pot4 = A3;
const int pot5 = A0;
const int pot6 = A11;
const int pot7 = A13;
const int pot8 = A19;

const int fader1 = A8;
const int fader2 = A6;
const int fader3 = A4;
const int fader4 = A2;
const int fader5 = A1;
const int fader6 = A12;
const int fader7 = A10;
const int fader8 = A18;

const int ribbon= A14;
const int potL = A20;
const int faderR = A15;

const int btn1 = 10;
const int btn2 = 3;
const int btn3 = 4;
const int btn4 = 6;
const int btn5 = 9;
const int btn6 = 12;
const int btn7 = 25;
const int btn8 = 32;
const int btn9 = 11;
const int btn10 = 3;
const int btn11 = 5;
const int btn12 = 7;
const int btn13 = 8;
const int btn14 = 13;
const int btn15 = 24; //10;
const int btn16 = 33;

const int btnL = 27;
const int btnR = 28;

byte analogs[] = {A9,A7,A5,A3,A0,A11,A13,A19,A8,A6,A4,A2,A1,A12,A10,A18,A14,A20,A15};
//byte analogs[] = {23,21,19,17,14,35,29,30,22,20,18,16,15,34,36,29,34,31,26};
byte buttons[] = {10,2,4,6,9,12,25,32,11,3,5,7,8,13,24,33,27,28};

#define NUMANALOGS sizeof(analogs)
#define NUMBUTTONS sizeof(buttons)


const int digitalInPin = 28;
const int analogInPin = A7;// Analog input pin that the potentiometer is attached to
const int analogOutPin = 9; // Analog output pin that the LED is attached to

int sensorValue = 0;        // value read from the pot
int outputValue = 0;        // value output to the PWM (analog out)

void setup() {
  // initialize serial communications at 9600 bps:
  //Serial.begin(9600);
  Serial.begin(115200);
for (int i=0;i<NUMBUTTONS;i++){ 
  pinMode(buttons[i], INPUT);
  digitalWrite(buttons[i], HIGH);
}
}

void loop() {
for (int i=0;i<NUMANALOGS;i++){
 int val = analogRead(analogs[i]);
 int valA = val/100;
 int valB = (val - valA*100);
//  Serial1.write(255-i);
//  Serial1.write(valA);
//  Serial1.write(valB+100);

  Serial.write(255-i);
  Serial.write(valA);
  Serial.write(valB+100);
  
  delay(1);
}
for (int i=0;i<NUMBUTTONS;i++){
 bool val = digitalRead(buttons[i]);
 Serial.write(255-i-NUMANALOGS);
 Serial.write(val + 100);
 delay(1);
}
  // read the analog in value:
  //sensorValue = digitalRead(digitalInPin);
  sensorValue = analogRead(analogInPin);
  // map it to the range of the analog out:
  outputValue = map(sensorValue, 0, 1023, 0, 255);
  // change the analog out value:
  //analogWrite(analogOutPin, outputValue);

  // print the results to the serial monitor:
//  Serial.print("sensor = ");
//  Serial.print(sensorValue);
//  Serial.print("\t output = ");
//  Serial.println(outputValue);
//
//  long pos1 = sensorValue/100;
//  long pos2 = (sensorValue - pos1*100);
//  Serial1.write(255);
//  Serial1.write(pos1);
//Serial1.write(225);

  // wait 2 milliseconds before the next loop
  // for the analog-to-digital converter to settle
  // after the last reading:
  delay(1);
}
