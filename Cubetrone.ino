#include<CubeTrone.h>
CubeTrone c;
void setup() {
 c.begin();
 // put your setup code here, to run once:

}

void loop() {
int x;
x=c.ultrasonic(); //return the distance
  // put your main code here, to run repeatedly:
if( x<20) {
 //add your code
c.sound(1); //int x
}
else {
 //add your code
c.sound(0); //int x
}

}