#ifndef CONNECTIVITY_H
#define CONNECTIVITY_H

#include <Arduino.h>
#include <WiFi.h>
/***********Constantes***********/
#define TIMEOUT 4
extern bool isBleON;
bool connection_to_internet_router(void);
bool is_internet_connected(void);

#endif