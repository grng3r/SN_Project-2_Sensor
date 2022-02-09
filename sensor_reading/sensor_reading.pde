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
/*//PAN ID
uint8_t  panID[2] = {0x12,0x34};
//Freq channel
uint8_t  channel = 0x0F;
//encryption mode
uint8_t encryptionMode = 0;
// AES 16-byte Encryption Key
char  encryptionKey[] = "TheLinkKey!";*/



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

void print_pres(uint8_t v) {
  // Print the info
  if (v == 1) 
  {
    USB.println(F("Sensor output: Presence detected"));
  } 
  else 
  {
    USB.println(F("Sensor output: Presence not detected"));
  } 
}

void get_print_bme280() {
  float temp = Events.getTemperature();
  float humd = Events.getHumidity();
  float pres = Events.getPressure();

  USB.println("-----------------------------");
  USB.println("           BME280");
  USB.println("-----------------------------");
  USB.print("Temperature: ");
  USB.printFloat(temp, 2);
  USB.println(F(" Celsius"));
  USB.print("Humidity: ");
  USB.printFloat(humd, 1); 
  USB.println(F(" %")); 
  USB.print("Pressure: ");
  USB.printFloat(pres, 2); 
  USB.println(F(" Pa")); 
  USB.println("-----------------------------");
}

void acc_alarm() {
  // print info
  ACC.unsetFF();
  USB.ON();
  USB.println(F("++++++++++++++++++++++++++++"));
  USB.println(F("++ ACC interrupt detected ++"));
  USB.println(F("++++++++++++++++++++++++++++")); 
  USB.println();

  // blink LEDs
  for(int i=0; i<10; i++) {
    Utils.blinkLEDs(50);
  } 
 }

 
void rtc_alarm() {
  USB.ON();  
  USB.println(F("-------------------------"));
  USB.println(F("RTC INT Captured"));
  USB.println(F("-------------------------"));

  get_print_bme280();
    
  // blink LEDs
  for(int i=0; i<10; i++) {
    Utils.blinkLEDs(50);
  }
}


void setup() {
  
  // Setup for Serial port over USB
  USB.ON();
   // Init RTC and set up time and date
  RTC.ON();

  //init ACC and enable free fall
  ACC.ON();

 
  // Setting time [yy:mm:dd:dow:hh:mm:ss]
  RTC.setTime("22:01:29:03:17:35:30"); 

  // Setting Alarm1
  RTC.setAlarm1("00:00:00:30",RTC_OFFSET,RTC_ALM1_MODE5);

  //Turn on events board
  Events.ON();

  setup_pir();

  // store Waspmote identifier in EEPROM memory
  frame.setID( WASPMOTE_ID );
  
  // init XBee
  xbee802.ON();
  /*set_channel();
  set_PAN();
  crypto_mode();
  xbee_w();*/
}


void loop() {
  frame.createFrame(ASCII);
  //fre fall detection
  if( intFlag & ACC_INT ) {
    intFlag &= ~(ACC_INT);
    ACC.unsetFF();
    frame.addSensor(SENSOR_STR, "FREE FALL");
    // send XBee packet
    error = xbee802.send( RX_ADDRESS, frame.buffer, frame.length );   
  
    // check TX flag
    if( error == 0 ) {
      USB.println(F("send ok"));
    
      // blink green LED
      Utils.blinkGreenLED();
    
    } else {
      USB.println(F("send error"));
    
      // blink red LED
      Utils.blinkRedLED();
    }
  }  
  //PIR detection
  uint8_t v = pir.readPirSensor();
  if (v == 1) {
    frame.addSensor(SENSOR_STR, "PRESENCE");
    // send XBee packet
    error = xbee802.send( RX_ADDRESS, frame.buffer, frame.length );   
  
    // check TX flag
    if( error == 0 ) {
      USB.println(F("send ok"));
    
      // blink green LED
      Utils.blinkGreenLED();
    
    } else {
      USB.println(F("send error"));
    
      // blink red LED
      Utils.blinkRedLED();
    }
  }
  
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
    Utils.blinkGreenLED();
    
  }
  else 
  {
    USB.println(F("send error"));
    
    // blink red LED
    Utils.blinkRedLED();
  }
  /*//USB.println();
  //USB.println();
  // Getting time
  USB.print(F("Time: "));
  USB.println(RTC.getTime());
   
  //enter sleep mode
  USB.println(F("enter sleep"));
  
  PWR.deepSleep("00:00:00:12", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
  
  // Getting Alarm1
  USB.print(F("Alarm: "));
  USB.println(RTC.getAlarm1());
  //xbee conf
  //get_xbee_conf();

  ACC.ON();

  //Events.ON();

  //ACC alarm
  if( intFlag & ACC_INT ) {
    intFlag &= ~(ACC_INT);
    acc_alarm();
  }
  
  // RTC alarm
  if( intFlag & RTC_INT ) {
    // clear interruption flag
    intFlag &= ~(RTC_INT);
    rtc_alarm();
  }

  //Check interruption from Sensor Board
  if (intFlag & SENS_INT) {
    // Disable interruptions from the board
    Events.detachInt();
    
    // Load the interruption flag
    Events.loadInt();
    
    // In case the interruption came from PIR
    if (pir.getInt()) {
      USB.println(F("-----------------------------"));
      USB.println(F("Interruption from PIR"));
      USB.println(F("-----------------------------"));
    }    

     // Read the PIR Sensor
    uint8_t v = pir.readPirSensor();
    print_pres(v);
    
    // Clean the interruption flag
    intFlag &= ~(SENS_INT);
    
    // Enable interruptions from the board
    Events.attachInt();
  } 
  PWR.clearInterruptionPin();*/
  delay(5000);
}

