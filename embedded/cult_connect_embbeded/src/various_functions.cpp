#include "various_functions.h"
#include <Arduino.h>

void resetButtonInterrupt()
{
  uint32_t pressedTime;
  uint32_t reading = digitalRead(moduleConfig.getResetButtonPin());
  if (reading != HIGH)
  {
    moduleConfig.setLastDebounceTime(millis()); //reset the debouncing timer
  }
  pressedTime = (millis() - moduleConfig.getLastDebounceTime());
  if (pressedTime > 50)
  {
    Serial.print(pressedTime);
    Serial.println("ms");
    if (pressedTime > 2000)
      moduleConfig.setResetModuleFlag(true);
    else
      moduleConfig.setResetModuleFlag(false);
  }
}