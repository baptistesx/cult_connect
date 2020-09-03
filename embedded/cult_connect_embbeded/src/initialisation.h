#ifndef INITIALISATION_H_
#define INITIALISATION_H_

#include "connectivity.h"
#include "spiffs_functions.h"
#include "ble.h"

#define RESET_BUTTON_PIN 32
// #include "monitoring.h" //Contains all the sensors functions prototypes

#define BLE_STATUS_LED_PIN 13
#define SOCKET_STATUS_LED_PIN 12
extern String PRIVATE_ID;
extern String MODULE_NAME;
//"M" for Module and database module "_id"
// #define MODULE_NAME "M_5e7a88e55d33fe0d041ff8ce"
#define SERIAL_SPEED 115200
extern bool startingDHT22MeasureFlag;
extern bool startingBrightnessMeasureFlag;
extern String currentDateTime;
extern bool isBleON;
extern int buttonState;                //the current reading from the input pin
extern int lastButtonState;            //the previous reading from the input pin
extern unsigned long lastDebounceTime; //the last time the output pin was toggled
extern unsigned long debounceDelay;    //the debounce time; increase if the output flickers
extern bool resetModuleFlag;

void serialPortInit(void);
void resetButtonInit(void);
void resetButtonInterrupt();
bool SPIFFSInit(void);
void statusLedsInit();
void NTPInit(void);
void temperatureHumiditySensorInit(void);
void raiseDHT22MeasureFlag(void);
void raiseBrightnessMeasureFlag(void);

#endif