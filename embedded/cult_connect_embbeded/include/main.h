/****** Header file containing all the other project private headers
    It also contains all global variables ******/

#ifndef __HEADERS_H_
#define __HEADERS_H_

#include <Arduino.h>

// Library to get Internet time from an NTP Client
#include <NTPClient.h>

// Library to manipulate json documents
#include <ArduinoJson.h>

// Library to work with files system
#include "FS.h"

// Library to work with DHT (humidity/temperature sensor)
#include "DHT.h"

#include <WiFi.h>

/****** Project private headers *****/
#include "ble.h"
#include "connectivity.h"
#include "initialisation.h"
#include "spiffs_functions.h"
#include "various_functions.h"
#include "web_socket_io.h"
#include "SocketIoClient.h"
#include "config.h"
#include "sensor.h"

/****** BLE (Bluetooth Low Energy) constants and extern variables *****/
// TODO: put these two constants in the bleInstance?
#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

extern BleInstance bleInstance;

/***** Wifi extern variables and constants *****/

// Wifi router connection timeout
#define WIFI_ROUTER_CONNECTION_TIMEOUT 4

extern WiFiUDP ntpUDP;
extern NTPClient timeClient;

/***** General module contants and extern variables *****/

// Communication speed with the serial monitor (bauds)
#define SERIAL_SPEED 115200

/***** Extern Websocketio variables *****/
extern SocketIoClient webSocket;
extern Config moduleConfig;

#endif