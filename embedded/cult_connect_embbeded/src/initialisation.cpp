#include "initialisation.h"

//Define NTP Client to get time
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP);
//Date variables
String formattedDate, dayStamp, timeStamp;
//Initialize the serial communication with the computer
void serial_port_init(void)
{
  Serial.begin(SERIAL_SPEED); //8 data bits, no parity, one stop bit
}

//Initialize the SPIFF memory
bool SPIFF_init(void)
{
  printf("==========SPIFF init==========\n");

  if (!SPIFFS.begin(FORMAT_SPIFFS_IF_FAILED))
    return false;

  printf("The SPIFF memory contains:\n");

  listDir(SPIFFS, "/", 0);

  printf("SPIFF init: OK\n\n");

  return true;
}

//Initialize a NTPClient to get date and time
void init_NTP(void)
{
  String s = "===========Time init (NTP)===========\n";

  timeClient.begin();
  //Set offset time in seconds to adjust for your timezone, for example:
  //GMT +1 = 3600
  //GMT -1 = -3600
  //GMT 0 = 0
  timeClient.setTimeOffset(7200);
  s += "\t\t\tTime init: OK\n\n";
  Serial.println(s);
}