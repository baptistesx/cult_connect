#include "monitoring.h" //Contains all the sensors functions prototypes

bool startingDHT22MeasureFlag = false;

DHT dht(DHTPIN, DHTTYPE); //Sensor DHT22 object

/**********Interruption**********/
Ticker startingDHT22MeasureTicker;

int dhtMeasureTicker = 1800;
float dht22CelciusTemperature, dht22Humidity;

void sensorsInit(void)
{
  temperatureHumiditySensorInit();
}

/**************Temperature/Humidity sensor (DHT22) functions**************/
bool measureTemperatureHumidity(float *temp_celcius, float *humidity)
{ //Temperature/Humidity measure function
  /*  Reading temperature or humidity takes about 250 milliseconds!
    Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)*/
  *humidity = dht.readHumidity();
  //Read temperature as Celsius (the default)
  *temp_celcius = dht.readTemperature();

  //Check if any reads failed and exit early (to try again).
  if (isnan(*humidity) || isnan(*temp_celcius))
    return false;

  Serial.print("temp: ");
  Serial.println(*temp_celcius);
  Serial.print("hum: ");
  Serial.println(*humidity);
  return true;
}

int sendDataSensors2Server(void)
{
    if (isInternetConnected())
    {
        if (timeClient.update())
        {
            bool res = measureTemperatureHumidity(&dht22CelciusTemperature, &dht22Humidity);

            if (res)
            {
                currentDateTime = timeClient.getFormattedDate();
                String dataToSend = "\"{'moduleId': '5e7a80125d33fe0d041ff8cb', 'sensorId': '5e81197a68819b45fce01000', 'data' : [ {'date' : '" + currentDateTime + "', 'value' : " + String(dht22CelciusTemperature) + "} ]}\"";
                webSocket.emit("newDataFromModule", dataToSend.c_str());
                dataToSend = "\"{'moduleId': '5e7a80125d33fe0d041ff8cb', 'sensorId': '5e81197a68819b45fce01001', 'data' : [ {'date' : '" + currentDateTime + "', 'value' : " + String(dht22Humidity) + "} ]}\"";
                webSocket.emit("newDataFromModule", dataToSend.c_str());

                return 0;
            }
            else
                return 3;
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