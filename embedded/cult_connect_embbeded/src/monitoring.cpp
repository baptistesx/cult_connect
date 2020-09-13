#include "monitoring.h" //Contains all the sensors functions prototypes

/**************Temperature/Humidity sensor (DHT22) functions**************/
bool measureTemperatureHumidity(float *celciusTemperatureFromDHT22, float *humidityFromDHT22)
{ //Temperature/Humidity measure function
  /*  Reading temperature or humidity takes about 250 milliseconds!
    Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)*/
    //TODO: to check
  // *humidityFromDHT22 = humidityTemperatureSensor.readHumidity();
  //Read temperature as Celsius (the default)
  // *celciusTemperatureFromDHT22 = humidityTemperatureSensor.readTemperature();

  //Check if any reads failed and exit early (to try again).
  if (isnan(*humidityFromDHT22) || isnan(*celciusTemperatureFromDHT22))
    return false;

  return true;
}

int sendSensorsData2Server(int numSensor)
{
  if (isInternetConnected())
  {
    if (timeClient.update())
    {
      switch (numSensor)
      {
      case 1:
      {
        float celciusTemperatureFromDHT22;
        float humidityFromDHT22;
        bool res = measureTemperatureHumidity(&celciusTemperatureFromDHT22, &humidityFromDHT22);

        if (res)
        {
          String currentDateTime = timeClient.getFormattedTime();
          String dataToSend = "\"{'moduleId': '" + moduleConfig.getId() + "', 'sensorId': '5e81197a68819b45fce01000', 'data' : [ {'date' : '" + currentDateTime + "', 'value' : " + String(celciusTemperatureFromDHT22) + "} ]}\"";
          webSocket.emit("newDataFromModule", dataToSend.c_str());
          dataToSend = "\"{'moduleId': '" + moduleConfig.getId() + "', 'sensorId': '5e81197a68819b45fce01001', 'data' : [ {'date' : '" + currentDateTime + "', 'value' : " + String(humidityFromDHT22) + "} ]}\"";
          webSocket.emit("newDataFromModule", dataToSend.c_str());

          return 0;
        }
        else
          return 3;
      }
      break;
      case 2:
      {
        float brightnessLuxFromTSL2561;
        bool res = measureBrightness(&brightnessLuxFromTSL2561);

        if (res)
        {
          String currentDateTime = timeClient.getFormattedDate();
          String dataToSend = "\"{'moduleId': '" + moduleConfig.getId() + "', 'sensorId': '5f4ec59b1f305e32f8f3e519', 'data' : [ {'date' : '" + currentDateTime + "', 'value' : " + String(brightnessLuxFromTSL2561) + "} ]}\"";
          webSocket.emit("newDataFromModule", dataToSend.c_str());

          return 0;
        }
        else
          return 3;
      }
      break;
      default:
        Serial.println("Unknown numSensor");
        return 4;
        break;
      }
    }
    else
      return 2;
  }
  else
    return 1;
}

//Raise the flag for new measures
void raiseHumidityTemperatureMeasureFlag(void)
{
  // startingHumidityTemperatureMeasureFlag = true;
}

//Raise the flag for new measures
void raiseBrightnessMeasureFlag(void)
{
  Serial.println("flag tsl");
  // startingBrightnessMeasureFlag = true;
}

bool measureBrightness(float *brightnessLuxFromTSL2561)
{ //Brightness measure functions
  // int i = 0;
  // do
  // {
  //   /* Get a new sensor event */
  //   sensors_event_t brightnessSensorEvent;
  //   brightnessSensor.getEvent(&brightnessSensorEvent);

  //   if (brightnessSensorEvent.light)
  //   {
  //     *brightnessLuxFromTSL2561 = brightnessSensorEvent.light;
  //     return true;
  //   }
  //   else
  //   {
  //     /* If brightnessSensorEvent.light = 0 lux the sensor is probably saturated
  //        and no reliable data could be generated! */
  //     Serial.println("Réinitialisation du light sensor");
  //     int res = brightnessSensorInit();
  //     if (res == 1)
  //     {
  //       //TODO: handle error
  //     }
  //     i++;
  //     delay(1000);
  //   }
  // } while (i < 5);
  // *brightnessLuxFromTSL2561 = 0;
  return false;
}