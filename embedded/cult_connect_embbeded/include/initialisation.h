#ifndef __INITIALISATION_H_
#define __INITIALISATION_H_

#include "main.h"

void websocketioInit(void);
void serialPortInit(void);
void resetButtonInit(void);
void statusLedsInit(void);
bool SPIFFSInit(void);
void NTPInit(void);
void sensorsInit(void);
void temperatureHumiditySensorInit(void);
int brightnessSensorInit(void);

#endif