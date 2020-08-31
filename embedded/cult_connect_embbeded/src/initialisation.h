#ifndef INITIALISATION_H
#define INITIALISATION_H

#define MODULE_NAME "M_5e7a80125d33fe0d041ff8cb"
#define PRIVATE_ID "123"
#define SERIAL_SPEED 115200

#include "initialisation.h"
#include "connectivity.h"
#include "spiff_functions.h"
#include "ble.h"
#include <NTPClient.h>
extern WiFiUDP ntpUDP;
extern NTPClient timeClient;
extern String formattedDate, dayStamp, timeStamp;
extern bool isBleON;
bool SPIFF_init(void);
void serial_port_init(void);
void init_NTP(void);

#endif