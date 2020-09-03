#include "connectivity.h"

// extern bool startingDHT22MeasureFlag;
// extern bool startingBrightnessMeasureFlag;
extern bool oldIsBleON;
extern bool isBleON;
extern Ticker startingDHT22MeasureTicker;
extern Ticker startingBrightnessMeasureTicker;

String routerSsid = "";
String routerPassword = "";

String currentDateTime;

//Define NTP Client to get time
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP);

bool connection2InternetRouter(String ssid, String password)
{
    int timeout_internet_connection = 0;

    //Initialize the connection
    //c_str() method that converts the content of a string as a c-style => pointer on a char array
    WiFi.begin(ssid.c_str(), password.c_str());

    //Try to connect every second while is not connected or no timeout
    while (!isInternetConnected())
    {
        if (timeout_internet_connection == TIMEOUT)
        {
            Serial.printf("Timeout\n");

            WiFi.disconnect();

            return false;
        }

        delay(1000);

        timeout_internet_connection++;
    }
    return true;
}

//Return true if the connection to the internet router is established
bool isInternetConnected(void)
{
    return WiFi.status() == WL_CONNECTED;
}

void updateCurrentDateTime(void)
{
    if (timeClient.update())
        currentDateTime = timeClient.getFormattedDate();
}

