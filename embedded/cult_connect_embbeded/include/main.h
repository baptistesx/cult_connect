/****** Header file containing all the other project private headers
    It also contains all global variables ******/

#ifndef __HEADERS_H_
#define __HEADERS_H_



// Interrupt library
// #include <Ticker.h>

// Library to get Internet time from an NTP Client
#include <NTPClient.h>

#include <ArduinoJson.h>

// Library to work with files system
#include "FS.h"

// Library to work with DHT (humidity/temperature sensor)
#include "DHT.h"



#include <WiFi.h>

#include <Arduino.h>

/****** Project private headers *****/
#include "ble.h"
#include "connectivity.h"
#include "initialisation.h"
#include "monitoring.h" //Contains all the sensors functions prototypes
#include "spiffs_functions.h"
#include "various_functions.h"
#include "web_socket_io.h"
#include "SocketIoClient.h"
#include "config.h"
#include "sensor.h"

/****** BLE (Bluetooth Low Energy) constants and extern variables *****/
#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
// extern bool isBleON;
// extern bool oldIsBleON;
// extern BLECharacteristic *pCharacteristic;
// extern BLEServer *pServer;
// extern bool isBLEConnected;
// extern bool oldIsBLEConnected;

extern BleInstance bleInstance;

// extern std::string rawBLEValueReceived;
// extern uint32_t valToNotifyBLE;
// extern uint32_t oldValToNotifyBLE;

/***** Wifi extern variables and constants *****/

// Wifi router connection timeout
#define WIFI_ROUTER_CONNECTION_TIMEOUT 4
//Define NTP Client to get time
extern WiFiUDP ntpUDP;
extern NTPClient timeClient;
// extern String routerSsid;
// extern String routerPassword;

/***** Extern monitoring variables and constants *****/

// DHT (humidity/temperature sensor) extern variables and constants
// #define DHTTYPE DHT22 //DHT 22  (AM2302), AM2321
// #define DHTPIN 4
// extern DHT humidityTemperatureSensor;
// extern int humidityTemperatureMeasureTickerDelay;
// extern Ticker startingHumidityTemperatureMeasureTicker;
// extern bool startingHumidityTemperatureMeasureFlag;

// TSL2561 (luminosity sensor) extern variables and constants
// extern Adafruit_TSL2561_Unified brightnessSensor;
// extern int brightnessMeasureTickerDelay;
// // extern Ticker startingBrightnessMeasureTicker;
// extern bool startingBrightnessMeasureFlag;

// List of modules sensors and their ids
// extern String sensors[];
// #define NUMBER_OF_MODULE_SENSORS 3

// Temperature sensor ID
// #define DHT22_TEMPERATURE_ID "5e81197a68819b45fce01000"

// Humidity sensor ID
// #define DHT22_HUMIDITY_ID "5e81197a68819b45fce01001"

// Luminosity sensor ID
// #define TSL2561_ID "5f4ec59b1f305e32f8f3e519"

/***** General module contants and extern variables *****/

// extern String MODULE_PRIVATE_ID;
// extern String MODULE_NAME;

// This led is on when the module is in the BLE mode
// #define BLE_STATUS_LED_PIN 13

// This led is on when the module is in the websockets mode
// #define SOCKET_STATUS_LED_PIN 12

// Communication speed with the serial monitor (bauds)
#define SERIAL_SPEED 115200

// Reset module button pin
// #define RESET_BUTTON_PIN 32
// extern unsigned long lastDebounceTime;
// extern bool resetModuleFlag;

/***** Extern Websocketio variables *****/
extern SocketIoClient webSocket;
extern Config moduleConfig;
#endif