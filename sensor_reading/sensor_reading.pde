#include <WaspSensorEvent_v30.h>
#include <WaspXBee802.h>
#include <WaspFrame.h>

//PIR
pirSensorClass pir(SOCKET_1);

//XBEE
// Destination MAC address
char RX_ADDRESS[] = "0013A200417EE50D";
// Define the Waspmote ID
char WASPMOTE_ID[] = "node_01";
// error variable
uint8_t error;


void setup_pir() {
  // Firstly, wait for PIR signal stabilization
  uint8_t value = pir.readPirSensor();
  
  while (value == 1) {
    USB.println(F("...wait for PIR stabilization"));
    delay(1000);
    value = pir.readPirSensor();    
  }
  
  // Enable interruptions from the board
  Events.attachInt();
}



void setup() {  
  // Setup for Serial port over USB
  USB.ON();
  //init ACC and enable free fall
  ACC.ON();
  //Turn on events board
  Events.ON();
  //init PIR
  setup_pir();

  // store Waspmote identifier in EEPROM memory
  frame.setID( WASPMOTE_ID );
  
  // init XBee
  xbee802.ON();
}


void loop() {
  //create ASCII message frame
  frame.createFrame(ASCII);
  //fre fall detection
  if( intFlag & ACC_INT ) {
    intFlag &= ~(ACC_INT);
    ACC.unsetFF();
    frame.addSensor(SENSOR_STR, "FREE FALL");
    // send XBee packet
    error = xbee802.send( RX_ADDRESS, frame.buffer, frame.length );   
    Utils.blinkRedLED();

    // check TX flag
    if( error == 0 ) {
      USB.println(F("send ok"));
    
      // blink green LED
      /Utils.blinkRedLED();
    
    } else {
      //print error message
      USB.println(F("send error"));    
    }
  }

  //PIR detection
  uint8_t v = pir.readPirSensor();
  if (v == 1) {
    frame.addSensor(SENSOR_STR, "PRESENCE");
    // send XBee packet
    error = xbee802.send( RX_ADDRESS, frame.buffer, frame.length );   
    Utils.blinkRedLED();

    // check TX flag
    if( error == 0 ) {
      USB.println(F("send ok"));
    
      // blink red LED
      Utils.blinkRedLED();
    
    } else {
      USB.println(F("send error"));    
    }
  }

  Utils.blinkGreenLED();
  //add sensor values to message frame
  frame.addSensor(SENSOR_BAT, PWR.getBatteryLevel());
  frame.addSensor(SENSOR_ACC, ACC.getX(), ACC.getY(), ACC.getZ());
  float temp = Events.getTemperature();
  float humd = Events.getHumidity();
  float pres = Events.getPressure();
  frame.addSensor(SENSOR_AMBIENT_TC, temp);
  frame.addSensor(SENSOR_AMBIENT_HUM, humd);
  frame.addSensor(SENSOR_AMBIENT_PRES, pres);
  
  // send XBee packet
  error = xbee802.send( RX_ADDRESS, frame.buffer, frame.length );   
  
  // check TX flag
  if( error == 0 )
  {
    USB.println(F("send ok"));
    
    // blink green LED
    Utils.blinkRedLED();    
  }
  else 
  {
    USB.println(F("send error"));
  }
  //wait 30s
  delay(30000);
}
