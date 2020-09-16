#include "connectivity.h"

bool connection2InternetRouter(String ssid, String password)
{
    uint8_t internetConnectionTimeout = 0;

    //Initialize the connection
    //c_str() method that converts the content of a string as a c-style => pointer on a char array
    WiFi.begin(ssid.c_str(), password.c_str());

    //Try to connect every second while is not connected or no timeout
    while (!isInternetConnected())
    {
        if (internetConnectionTimeout == WIFI_ROUTER_CONNECTION_TIMEOUT)
        {
            Serial.printf("Timeout\n");

            WiFi.disconnect();

            return false;
        }

        delay(1000);

        internetConnectionTimeout++;
    }
    return true;
}

bool isInternetConnected(void)
{
    return WiFi.status() == WL_CONNECTED;
}