#ifndef CONNECTIVITY_H_
#define CONNECTIVITY_H_

#include <WiFi.h>
#include <Ticker.h> //Librairie pour interruptions
#include <NTPClient.h>

#define TIMEOUT 4

extern WiFiUDP ntpUDP;

extern bool isBleON;
extern bool oldIsBleON;
// extern bool startingDHT22MeasureFlag;
extern NTPClient timeClient;

extern Ticker startingDHT22MeasureTicker;
extern Ticker startingBrightnessMeasureTicker;

bool connection2InternetRouter(String ssid, String password);
bool isInternetConnected(void);
void updateCurrentDateTime(void);

#endif