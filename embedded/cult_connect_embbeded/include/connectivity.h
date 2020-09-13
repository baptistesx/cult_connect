#ifndef __CONNECTIVITY_H_
#define __CONNECTIVITY_H_

#include "main.h"

// Connect the module to the router to have internet access
// Return true if the connection with the router is established
// else return false
bool connection2InternetRouter(String ssid, String password);

// Return true if the module has internet access
bool isInternetConnected(void);

// void updateCurrentDateTime(void);

// Reset routerId and routerPassword global variables
// void clearRouterIds(void);

#endif