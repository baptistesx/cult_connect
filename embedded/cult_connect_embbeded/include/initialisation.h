#ifndef __INITIALISATION_H_
#define __INITIALISATION_H_

#include "main.h"

void websocketioInit(void);

//Initialize the serial communication with the computer
void serialPortInit(void);

// Reset button init
// Button used in interruption to reinit SPIFFS memory that stores the internet router ids
void resetButtonInit(void);

// Initialize the module status leds
void statusLedsInit(void);

//Initialize the SPIFFS memory
bool SPIFFSInit(void);

//Initialize a NTPClient to get date and time
void NTPInit(void);

// Enable timer interruptions for each sensor
void startSensorsTimers(void);

#endif