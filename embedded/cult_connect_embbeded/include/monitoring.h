#ifndef __MONITORING_H_
#define __MONITORING_H_

#include "main.h"

void raiseHumidityTemperatureMeasureFlag(void);
bool measureTemperatureHumidity(float *celciusTemperatureFromDHT22, float *humidityFromDHT22);

void raiseBrightnessMeasureFlag(void);
bool measureBrightness(float *brightnessLuxFromTSL2561);

int sendSensorsData2Server(int numSensor);

#endif