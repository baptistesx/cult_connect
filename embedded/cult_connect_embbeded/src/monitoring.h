#ifndef MONITORING_H_
#define MONITORING_H_

// #include "initialisation.h"
#include "web_socket_io.h"
#include <Ticker.h> //Librairie pour interruptions
#include "DHT.h"
#include <Adafruit_Sensor.h>
#include <Adafruit_TSL2561_U.h>

#define DHTTYPE DHT22 //DHT 22  (AM2302), AM2321
#define DHTPIN 4

extern DHT dht;
extern int dhtMeasureTicker;
extern int brightnessMeasureTicker;
extern float dht22CelciusTemperature, dht22Humidity;
extern String sensors[];

bool measureTemperatureHumidity(void);
bool measureBrightness(void);
int sendDataSensors2Server(int numSensor);
void temperatureHumiditySensorInit(void);
void temperatureHumiditySensorInit(void);
void sensorsInit(void);
int brightnessSensorInit(void);
int brightnessMeasure(void);

#endif