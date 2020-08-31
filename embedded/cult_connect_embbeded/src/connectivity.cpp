#include "connectivity.h"

String routerSsid = "";
String routerPassword = "";

bool connection_to_internet_router(void)
{
    String s = "==========Check connection to internet router==========\n";

    s += "\t\t\trouterSsid: " + routerSsid + "\n";
    s += "\t\t\trouterPassword: " + routerPassword + "\n";
    Serial.println(s);

    int timeout_internet_connection = 0;

    //Initialize the connection
    //c_str() method that converts the content of a string as a c-style => pointer on a char array
    WiFi.begin(routerSsid.c_str(), routerPassword.c_str());

    //Try to connect every second while is not connected or no timeout
    while (!is_internet_connected())
    {
        if (timeout_internet_connection == TIMEOUT)
        {
            Serial.printf("Timeout\n");

            WiFi.disconnect();

            return false;
        }

        delay(1000);

        s += ".";

        timeout_internet_connection++;
    }

    //TODO: init time
    // init_time();

    return true;
}

//Return true if the connection to the internet router is established
bool is_internet_connected(void)
{
    return WiFi.status() == WL_CONNECTED;
}