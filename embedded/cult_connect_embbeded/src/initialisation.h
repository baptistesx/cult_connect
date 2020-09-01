#ifndef INITIALISATION_H
#define INITIALISATION_H

#include "connectivity.h"
#include "spiffs_functions.h"
#include "ble.h"

#define RESET_BUTTON_PIN 32
// #include "monitoring.h" //Contains all the sensors functions prototypes

#define BLE_STATUS_LED_PIN 13
#define SOCKET_STATUS_LED_PIN 12

//"M" for Module and database module "_id"
#define MODULE_NAME "M_5e7a80125d33fe0d041ff8cb"
#define SERIAL_SPEED 115200


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

#endif