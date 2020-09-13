#include "initialisation.h"

void test() {}
// Initialize all the module sensors

void sensorsInit(void)
{
  for (int i = 0; i < moduleConfig.getNbSensors(); i++)
  {
    Serial.print("init isr: ");
    // Serial.println(moduleConfig.sensors[i]->getId());
    moduleConfig.sensors[i]->setISR();
  }
  // int dht22SensorIndex = 1;
  // for (int i = 0; i < NUMBER_OF_MODULE_SENSORS; i++)
  // {
  //   String sensor = sensors[i];
  //   if (sensor == "")
  //     break;

  //   if ((sensor == DHT22_TEMPERATURE_ID || sensor == DHT22_HUMIDITY_ID) && dht22SensorIndex == 1)
  //   {
  //     Serial.println("le module contient un dht22");
  //     temperatureHumiditySensorInit();

  //     dht22SensorIndex++;
  //   }
  //   else if (sensor == TSL2561_ID)
  //   {
  //     Serial.println("le module contient un tsl2561");
  //     int res = brightnessSensorInit();
  //     if (res == 1)
  //     {
  //       //TODO: handle error
  //       /* There was a problem detecting the TSL2561 ... check your connections */
  //       Serial.print("Ooops, no TSL2561 detected ... Check your wiring or I2C ADDR!");
  //     }
  //     else
  //     {
  //     }
  //   }
  // }
}

//Initialize Temperature/Humidity sensor (DHT22)
void temperatureHumiditySensorInit(void)
{
  // humidityTemperatureSensor.begin();
  //TODO: check
  // startingHumidityTemperatureMeasureTicker.attach(humidityTemperatureMeasureTickerDelay, raiseHumidityTemperatureMeasureFlag);
}

//Initialize brightness sensor (TSL2561)
int brightnessSensorInit(void)
{
  //use brightnessSensor.begin() to default to Wire,
  //brightnessSensor.begin(&Wire2) directs api to use Wire2, etc.
  // if (!brightnessSensor.begin())
  // {
  //   return 1;
  // }

  // /* Display some basic information on this sensor */
  // // sensor_t b_sensor;
  // // brightnessSensor.getSensor(&b_sensor);
  // // Serial.println("------------------------------------");
  // // Serial.print("Brightness Sensor:       ");
  // // Serial.println(b_sensor.name);
  // // Serial.print("Driver Ver:   ");
  // // Serial.println(b_sensor.version);
  // // Serial.print("Unique ID:    ");
  // // Serial.println(b_sensor.sensor_id);
  // // Serial.print("Max Value:    ");
  // // Serial.print(b_sensor.max_value);
  // // Serial.println(" lux");
  // // Serial.print("Min Value:    ");
  // // Serial.print(b_sensor.min_value);
  // // Serial.println(" lux");
  // // Serial.print("Resolution:   ");
  // // Serial.print(b_sensor.resolution);
  // // Serial.println(" lux");
  // // Serial.println("------------------------------------");
  // // Serial.println("");
  // delay(500);

  // /* Setup the sensor gain and integration time */
  // /* You can also manually set the gain or enable auto-gain support */
  // // brightnessSensor.setGain(TSL2561_GAIN_1X);      /* No gain ... use in bright light to avoid sensor saturation */
  // // brightnessSensor.setGain(TSL2561_GAIN_16X);     /* 16x gain ... use in low light to boost sensitivity */
  // brightnessSensor.enableAutoRange(true); /* Auto-gain ... switches automatically between 1x and 16x */

  // /* Changing the integration time gives you better sensor resolution (402ms = 16-bit data) */
  // brightnessSensor.setIntegrationTime(TSL2561_INTEGRATIONTIME_13MS); /* fast but low resolution */
  // brightnessSensor.setIntegrationTime(TSL2561_INTEGRATIONTIME_101MS);  /* medium resolution and speed   */
  // brightnessSensor.setIntegrationTime(TSL2561_INTEGRATIONTIME_402MS);  /* 16-bit data but slowest conversions */
  //TODO: check
  // startingBrightnessMeasureTicker.attach(brightnessMeasureTickerDelay, raiseBrightnessMeasureFlag);

  return 0;
}

//Initialize the serial communication with the computer
void serialPortInit(void)
{
  Serial.begin(SERIAL_SPEED); //8 data bits, no parity, one stop bit
}

//Reset button init
//Button used in interruption to reinit SPIFFS memory that stores the internet router ids
void resetButtonInit(void)
{
  uint8_t buttonPin = moduleConfig.getResetButtonPin();
  Serial.println("button pin set: " + String(buttonPin));
  pinMode(buttonPin, INPUT);

  attachInterrupt(digitalPinToInterrupt(buttonPin), resetButtonInterrupt, CHANGE);
}

//Initialize the SPIFFS memory
bool SPIFFSInit(void)
{
  if (!SPIFFS.begin(FORMAT_SPIFFS_IF_FAILED))
    return false;

  // List all directories present at the SPIFFS root
  listDir(SPIFFS, "/", 0);

  return true;
}

// Initialize the module status leds
void statusLedsInit()
{
  pinMode(moduleConfig.getBleStatusLedPin(), OUTPUT);
  pinMode(moduleConfig.getSocketStatusLedPin(), OUTPUT);
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

void websocketioInit(void)
{
  // Setup 'on' listen events
  webSocket.on("connect", socketConnected);
  webSocket.on("event", socketEvent);
  webSocket.on("reply", messageEventHandler);
  webSocket.begin("Baptiste-PC", 8081, "/socket.io/?transport=websocket");
}