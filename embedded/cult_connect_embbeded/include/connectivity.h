#ifndef __CONNECTIVITY_H_
#define __CONNECTIVITY_H_

#include "main.h"

/* Connect the module to the router to have internet access
    Return:
        - true: connection with the router is established
        - false: else
*/
bool connection2InternetRouter(String ssid, String password);

/* Return
        - true: Wifi status connected
        - false: else
bool isInternetConnected(void);

#endif