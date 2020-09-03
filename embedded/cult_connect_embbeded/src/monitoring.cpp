#include "monitoring.h" //Contains all the sensors functions prototypes

bool startingDHT22MeasureFlag = false;
bool startingBrightnessMeasureFlag = false;
String sensors[NUMBER_OF_SENSORS_GLOBALLY];

DHT dht(DHTPIN, DHTTYPE); //Sensor DHT22 object

/**********Interruption**********/
Ticker startingDHT22MeasureTicker;
Ticker startingBrightnessMeasureTicker;

int dhtMeasureTicker = 10;
int brightnessMeasureTicker = 20;
float dht22CelciusTemperature, dht22Humidity, tsl2561BrightnessLux;

Adafruit_TSL2561_Unified brightness_sensor = Adafruit_TSL2561_Unified(TSL2561_ADDR_FLOAT, 12345);

void sensorsInit(void)
{
  int dht22SensorIndex = 1;
  for (int i = 0; i < NUMBER_OF_SENSORS_GLOBALLY; i++)
  {
    String sensor = sensors[i];
    if (sensor == "")
      break;

    if ((sensor == DHT22_TEMPERATURE_ID || sensor == DHT22_HUMIDITY_ID) && dht22SensorIndex == 1)
    {
      Serial.println("le module contient un dht22");
      temperatureHumiditySensorInit();

      dht22SensorIndex++;
    }
    else if (sensor == TSL2561_ID)
    {
      Serial.println("le module contient un tsl2561");
      int res = brightnessSensorInit();
      if (res == 1)
      {
        //TODO: handle error
        /* There was a problem detecting the TSL2561 ... check your connections */
        Serial.print("Ooops, no TSL2561 detected ... Check your wiring or I2C ADDR!");
      }
      else
      {
      }
    }
  }
}

/**************Temperature/Humidity sensor (DHT22) functions**************/
bool measureTemperatureHumidity(void)
{ //Temperature/Humidity measure function
  /*  Reading temperature or humidity takes about 250 milliseconds!
    Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)*/
  dht22Humidity = dht.readHumidity();
  //Read temperature as Celsius (the default)
  dht22CelciusTemperature = dht.readTemperature();

  //Check if any reads failed and exit early (to try again).
  if (isnan(dht22Humidity) || isnan(dht22CelciusTemperature))
    return false;

  return true;
}

int sendDataSensors2Server(int numSensor)
{
  if (isInternetConnected())
  {
    if (timeClient.update())
    {
      switch (numSensor)
      {
      case 1:
      {
        bool res = measureTemperatureHumidity();

        if (res)
        {
          currentDateTime = timeClient.getFormattedDate();
          String dataToSend = "\"{'moduleId': '" + MODULE_NAME.substring(2, MODULE_NAME.length()-1) + "', 'sensorId': '5e81197a68819b45fce01000', 'data' : [ {'date' : '" + currentDateTime + "', 'value' : " + String(dht22CelciusTemperature) + "} ]}\"";
          webSocket.emit("newDataFromModule", dataToSend.c_str());
          dataToSend = "\"{'moduleId': '5e7a80125d33fe0d041ff8cb', 'sensorId': '5e81197a68819b45fce01001', 'data' : [ {'date' : '" + currentDateTime + "', 'value' : " + String(dht22Humidity) + "} ]}\"";
          webSocket.emit("newDataFromModule", dataToSend.c_str());

          return 0;
        }
        else
          return 3;
      }
      break;
      case 2:
      {
        bool res = measureBrightness();

        if (res)
        {
          currentDateTime = timeClient.getFormattedDate();
          String dataToSend = "\"{'moduleId': '" + MODULE_NAME.substring(2, MODULE_NAME.length() - 1) + "', 'sensorId': '5f4ec59b1f305e32f8f3e519', 'data' : [ {'date' : '" + currentDateTime + "', 'value' : " + String(tsl2561BrightnessLux) + "} ]}\"";
          webSocket.emit("newDataFromModule", dataToSend.c_str());

          return 0;
        }
        else
          return 3;
      }
      break;
      default:
        Serial.println("Unknown numSensor");
        break;
      }
    }
    else
      return 2;
  }
  else
    return 1;
}

//Initialize Temperature/Humidity sensor (DHT22)
void temperatureHumiditySensorInit(void)
{
  dht.begin();
  startingDHT22MeasureTicker.attach(dhtMeasureTicker, raiseDHT22MeasureFlag);
}

//Initialize brightness sensor (TSL2561)
int brightnessSensorInit(void)
{
  //use brightness_sensor.begin() to default to Wire,
  //brightness_sensor.begin(&Wire2) directs api to use Wire2, etc.
  if (!brightness_sensor.begin())
  {
    return 1;
  }

  /* Display some basic information on this sensor */
  // sensor_t b_sensor;
  // brightness_sensor.getSensor(&b_sensor);
  // Serial.println("------------------------------------");
  // Serial.print("Brightness Sensor:       ");
  // Serial.println(b_sensor.name);
  // Serial.print("Driver Ver:   ");
  // Serial.println(b_sensor.version);
  // Serial.print("Unique ID:    ");
  // Serial.println(b_sensor.sensor_id);
  // Serial.print("Max Value:    ");
  // Serial.print(b_sensor.max_value);
  // Serial.println(" lux");
  // Serial.print("Min Value:    ");
  // Serial.print(b_sensor.min_value);
  // Serial.println(" lux");
  // Serial.print("Resolution:   ");
  // Serial.print(b_sensor.resolution);
  // Serial.println(" lux");
  // Serial.println("------------------------------------");
  // Serial.println("");
  delay(500);

  /* Setup the sensor gain and integration time */
  /* You can also manually set the gain or enable auto-gain support */
  // brightness_sensor.setGain(TSL2561_GAIN_1X);      /* No gain ... use in bright light to avoid sensor saturation */
  // brightness_sensor.setGain(TSL2561_GAIN_16X);     /* 16x gain ... use in low light to boost sensitivity */
  brightness_sensor.enableAutoRange(true); /* Auto-gain ... switches automatically between 1x and 16x */

  /* Changing the integration time gives you better sensor resolution (402ms = 16-bit data) */
  brightness_sensor.setIntegrationTime(TSL2561_INTEGRATIONTIME_13MS); /* fast but low resolution */
  // brightness_sensor.setIntegrationTime(TSL2561_INTEGRATIONTIME_101MS);  /* medium resolution and speed   */
  // brightness_sensor.setIntegrationTime(TSL2561_INTEGRATIONTIME_402MS);  /* 16-bit data but slowest conversions */
  startingBrightnessMeasureTicker.attach(brightnessMeasureTicker, raiseBrightnessMeasureFlag);

  return 0;
}

bool measureBrightness(void)
{ //Brightness measure functions
  int i = 0;
  do
  {
    /* Get a new sensor event */
    sensors_event_t brightness_sensor_event;
    brightness_sensor.getEvent(&brightness_sensor_event);

    if (brightness_sensor_event.light)
    {
      tsl2561BrightnessLux = brightness_sensor_event.light;
      return true;
    }
    else
    {
      /* If brightness_sensor_event.light = 0 lux the sensor is probably saturated
         and no reliable data could be generated! */
      Serial.println("Réinitialisation du light sensor");
      int res = brightnessSensorInit();
      if (res == 1)
      {
        //TODO: handle error
      }
      i++;
      delay(1000);
    }
  } while (i < 5);
  tsl2561BrightnessLux = 0;
  return false;
}