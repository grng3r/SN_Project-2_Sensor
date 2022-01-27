/*
    ------ Waspmote Pro Code Example --------

    Explanation: This is the basic Code for Waspmote Pro

    Copyright (C) 2016 Libelium Comunicaciones Distribuidas S.L.
    http://www.libelium.com

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

// Put your libraries here (#include ...)




void setup()
{
  //set digital2 as in
  pinMode(DIGITAL2, INPUT);
  //set digital3 as HIGH out
  pinMode(DIGITAL3, OUTPUT);
  digitalWrite(DIGITAL3, HIGH);
  //turn both LED lights off
  Utils.setLED(LED0, LED_OFF);
  Utils.setLED(LED1, LED_OFF);
}


void loop()
{
  // put your main code here, to run repeatedly:
  //if d2 is H red led on
    if(digitalRead(DIGITAL2) == HIGH) {
      Utils.setLED(LED0, LED_ON);
      }
  //if d3 is L green led on
  if(digitalRead(DIGITAL2) == LOW) {
    Utils.setLED(LED1, LED_ON);
    }

}


