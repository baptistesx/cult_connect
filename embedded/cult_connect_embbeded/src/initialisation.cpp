#include "initialisation.h"

int buttonState,                    //Reset button state
    lastButtonState = HIGH;         //Initialisé à HIGH car pull-up, the previous reading from the input pin
bool resetModuleFlag = false;       //When this flag is high => reset SPIFFS
unsigned long lastDebounceTime = 0, //the last time the output pin was toggled
    debounceDelay = 50;             //the debounce time; increase if the output flickers
String PRIVATE_ID = "";
String MODULE_NAME = "";
//Initialize the serial communication with the computer
void serialPortInit(void)
{
  Serial.begin(SERIAL_SPEED); //8 data bits, no parity, one stop bit
}

//Reset button init
//Button used in interruption to reinit eeprom memory that stores the current system configuration (internet router identifiers, thresholds for actuators ect..)
void resetButtonInit(void)
{
  pinMode(RESET_BUTTON_PIN, INPUT);

  attachInterrupt(digitalPinToInterrupt(RESET_BUTTON_PIN), resetButtonInterrupt, CHANGE);
}

//TODO: effectuer le reset dans l'interruption car sinon obligé d'attendre la fin de l'init
void resetButtonInterrupt()
{
  int pressedTime;
  int reading = digitalRead(RESET_BUTTON_PIN);
  if (reading != lastButtonState)
  {
    if (reading != LOW)
      Serial.print("Bouton de reset appuyé: ");
    lastDebounceTime = millis(); //reset the debouncing timer
  }
  pressedTime = (millis() - lastDebounceTime);
  if (pressedTime > debounceDelay)
  {
    Serial.print(pressedTime);
    Serial.println("ms");
    if (pressedTime > 2000)
      resetModuleFlag = true;
    else
      resetModuleFlag = false;
  }
}

//Initialize the SPIFF memory
bool SPIFFSInit(void)
{
  if (!SPIFFS.begin(FORMAT_SPIFFS_IF_FAILED))
    return false;
  listDir(SPIFFS, "/", 0);

  return true;
}

void statusLedsInit()
{
  pinMode(BLE_STATUS_LED_PIN, OUTPUT);
  pinMode(SOCKET_STATUS_LED_PIN, OUTPUT);
}

//Initialize a NTPClient to get date and time
void NTPInit(void)
{
  timeClient.begin();
  //Set offset time in seconds to adjust for your timezone, for example:
  //GMT +1 = 3600
  //GMT -1 = -3600
  //GMT 0 = 0
  timeClient.setTimeOffset(7200);
}

//Raise the flag for new measures
void raiseDHT22MeasureFlag(void)
{
  startingDHT22MeasureFlag = true;
}

//Raise the flag for new measures
void raiseBrightnessMeasureFlag(void)
{
  Serial.println("flag tsl");
  startingBrightnessMeasureFlag = true;
}