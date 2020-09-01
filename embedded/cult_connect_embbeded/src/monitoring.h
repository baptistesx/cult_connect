#ifndef MONITORING_H
#define MONITORING_H

// #include "initialisation.h"
#include "web_socket_io.h"
#include <Ticker.h> //Librairie pour interruptions
#include "DHT.h"

#define DHTTYPE DHT22 //DHT 22  (AM2302), AM2321
#define DHTPIN 4

extern DHT dht;
extern int dhtMeasureTicker;
extern float dht22CelciusTemperature, dht22Humidity;

bool measureTemperatureHumidity(float *temp_celcius, float *humidity);
int sendDataSensors2Server(void);
void temperatureHumiditySensorInit(void);
void sensorsInit(void);

#endif