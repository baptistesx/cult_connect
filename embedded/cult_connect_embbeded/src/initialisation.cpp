#include "initialisation.h"

void startSensorsTimers(void)
{
  for (uint8_t i = 0; i < moduleConfig.getNbSensors(); i++)
  {
    moduleConfig.sensors[i]->setISR();
  }
}

void serialPortInit(void)
{
  Serial.begin(SERIAL_SPEED); //8 data bits, no parity, one stop bit
}

void resetButtonInit(void)
{
  uint8_t buttonPin = moduleConfig.getResetButtonPin();
  pinMode(buttonPin, INPUT);

  attachInterrupt(digitalPinToInterrupt(buttonPin), resetButtonInterrupt, CHANGE);
}

bool SPIFFSInit(void)
{
  if (!SPIFFS.begin(FORMAT_SPIFFS_IF_FAILED))
    return false;

  // List all directories present at the SPIFFS root
  listDir(SPIFFS, "/", 0);

  return true;
}

void statusLedsInit()
{
  pinMode(moduleConfig.getBleStatusLedPin(), OUTPUT);
  pinMode(moduleConfig.getSocketStatusLedPin(), OUTPUT);
}

void NTPInit(void)
{
  timeClient.begin();
  //Set offset time in seconds to adjust for your timezone, for example:
  //GMT +1 = 3600
  //GMT -1 = -3600
  //GMT 0 = 0
  timeClient.setTimeOffset(7200);
}

void websocketioInit(void)
{
  // Setup 'on' listen events
  webSocket.on("connect", socketConnected);
  webSocket.on("event", socketEvent);
  webSocket.on("reply", messageEventHandler);
  webSocket.begin("Baptiste-PC", 8081, "/socket.io/?transport=websocket");
}