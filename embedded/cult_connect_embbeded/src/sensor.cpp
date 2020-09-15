#include "sensor.h"
#include "config.h"
#include "connectivity.h"

Sensor::Sensor(String id, String type, uint32_t timer, uint32_t repeat, resolution_t resolution)
{
    // Initialize the sensors ticker
    this->resolution = resolution;
    if (resolution == MICROS)
        timer = timer * 1000000;

    this->timer = timer*1000;
    this->repeat = repeat;
    enabled = false;
    lastTime = 0;
    counts = 0;

    this->type = type;
    this->id = id;
}

Sensor::~Sensor() {}

String Sensor::getId(void) { return this->id; }

void Sensor::setISR(void) { this->start(); }

uint32_t Sensor::getMeasureInterval(void)
{
    return this->timer;
}

String Sensor::getType(void) { return this->type; }

void Sensor::setType(String type) { this->type = type; }

void Sensor::start()
{
    Serial.println("isr started");
    if (resolution == MILLIS)
        lastTime = millis();
    else
        lastTime = micros();
    enabled = true;
    counts = 0;
    status = RUNNING;
}

void Sensor::resume()
{
    if (resolution == MILLIS)
        lastTime = millis() - diffTime;
    else
        lastTime = micros() - diffTime;
    if (status == STOPPED)
        counts = 0;
    enabled = true;
    status = RUNNING;
}

void Sensor::stop()
{
    enabled = false;
    counts = 0;
    status = STOPPED;
}

void Sensor::pause()
{
    if (resolution == MILLIS)
        diffTime = millis() - lastTime;
    else
        diffTime = micros() - lastTime;
    enabled = false;
    status = PAUSED;
}

int Sensor::sendSensorData2Server()
{
    if (isInternetConnected())
    {
        if (timeClient.update())
        {
            float value = this->getMeasure();

            if (value != -1)
            {
                String dataToSend = "\"{'moduleId': '" + moduleConfig.getId() + "', 'sensorId': '" + this->getId() + "', 'data' : {'date' : '" + timeClient.getFormattedDate() + "', 'value' : " + String(value) + "}}\"";
                Serial.println(dataToSend);
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

void Sensor::update()
{
    if (tick())
    {
        int res = this->sendSensorData2Server();

        switch (res)
        {
        case 0:
            Serial.println("Data sent to the server with Success!");
            break;
        case 1:
            Serial.println("[ERROR] No internet connection: failed to send data sensors to the server! ");
            break;
        case 2:
            Serial.println("[ERROR] Failed to get the current time! ");
            break;
        case 3:
            Serial.println("[ERROR] Failed to read " + this->getType() + " sensor!");
            break;
        case 4:
            Serial.println("[ERROR] Unknown sensor!");
            break;
        default:
            Serial.println("[ERROR] Unkown error while sending data to the server!");
            break;
        }
    }
}

bool Sensor::tick()
{
    if (!enabled)
        return false;
    if (resolution == MILLIS)
    {
        if ((millis() - lastTime) >= timer)
        {
            lastTime = millis();
            if (repeat - counts == 1)
                enabled = false;
            counts++;
            return true;
        }
    }
    else
    {
        if ((micros() - lastTime) >= timer)
        {
            lastTime = micros();
            if (repeat - counts == 1)
                enabled = false;
            counts++;
            return true;
        }
    }
    return false;
}

void Sensor::interval(uint32_t timer)
{
    // timer is received in seconds
    if (resolution == MICROS)
        timer = timer * 1000000;
    this->timer = timer*1000;
}

uint32_t Sensor::elapsed()
{
    if (resolution == MILLIS)
        return millis() - lastTime;
    else
        return micros() - lastTime;
}

status_t Sensor::state()
{
    return status;
}

uint32_t Sensor::counter()
{
    return counts;
}

// TODO: put specific sensors classes in different files?
AirTemperatureSensor::AirTemperatureSensor(DHT *dhtSensor, int dhtType, int pin, String id, String type, uint32_t timer, uint32_t repeat, resolution_t resolution) : Sensor(id, type, timer, repeat, resolution)
{
    this->sensor = dhtSensor;
    this->dhtPin = pin;
    this->dhtType = dhtType;
}

float AirTemperatureSensor::getMeasure(void)
{
    /*  Reading temperature or humidity takes about 250 milliseconds!
    Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)*/
    float temperature = this->sensor->readTemperature();
    return isnan(temperature) ? -1 : temperature;
}
int AirTemperatureSensor::getDhtPin(void) { return this->dhtPin; }

int AirTemperatureSensor::getDhtType(void) { return this->dhtType; }

String AirTemperatureSensor::toString(void)
{
    return String("type: " + this->getType() + "; measureInterval: " + String(this->getMeasureInterval()) + " ; id: " + this->getId());
}

AirHumiditySensor::AirHumiditySensor(DHT *dhtSensor, int dhtType, int pin, String id, String type, uint32_t timer, uint32_t repeat, resolution_t resolution) : Sensor(id, type, timer, repeat, resolution)
{
    this->sensor = dhtSensor;
    this->dhtPin = pin;
    this->dhtType = dhtType;
}

float AirHumiditySensor::getMeasure(void)
{
    /*  Reading temperature or humidity takes about 250 milliseconds!
    Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)*/
    float humidity = this->sensor->readHumidity();
    return isnan(humidity) ? -1 : humidity;
}
int AirHumiditySensor::getDhtPin(void) { return this->dhtPin; }

int AirHumiditySensor::getDhtType(void) { return this->dhtType; }

String AirHumiditySensor::toString(void)
{
    return String("type: " + this->getType() + "; measureInterval: " + String(this->getMeasureInterval()) + " ; id: " + this->getId());
}

BrightnessSensor::BrightnessSensor(String id, String type, uint32_t timer, uint32_t repeat, resolution_t resolution) : Sensor(id, type, timer, repeat, resolution), sensor(TSL2561_ADDR_FLOAT, 12345) {}

int BrightnessSensor::init()
{
    //use brightnessSensor.begin() to default to Wire,
    //brightnessSensor.begin(&Wire2) directs api to use Wire2, etc.
    if (!this->sensor.begin())
    {
        return 1;
    }

    /* Display some basic information on this sensor */
    // sensor_t b_sensor;
    // brightnessSensor.getSensor(&b_sensor);
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
    // brightnessSensor.setGain(TSL2561_GAIN_1X);      /* No gain ... use in bright light to avoid sensor saturation */
    // brightnessSensor.setGain(TSL2561_GAIN_16X);     /* 16x gain ... use in low light to boost sensitivity */
    this->sensor.enableAutoRange(true); /* Auto-gain ... switches automatically between 1x and 16x */

    /* Changing the integration time gives you better sensor resolution (402ms = 16-bit data) */
    this->sensor.setIntegrationTime(TSL2561_INTEGRATIONTIME_13MS); /* fast but low resolution */
    // brightnessSensor.setIntegrationTime(TSL2561_INTEGRATIONTIME_101MS);  /* medium resolution and speed   */
    // brightnessSensor.setIntegrationTime(TSL2561_INTEGRATIONTIME_402MS);  /* 16-bit data but slowest conversions */

    return 0;
}

float BrightnessSensor::getMeasure(void)
{
    int i = 0;
    do
    {
        /* Get a new sensor event */
        sensors_event_t brightnessSensorEvent;
        this->sensor.getEvent(&brightnessSensorEvent);

        if (brightnessSensorEvent.light)
        {
            return brightnessSensorEvent.light;
        }
        else
        {
            /* If brightnessSensorEvent.light = 0 lux the sensor is probably saturated
         and no reliable data could be generated! */
            Serial.println("Réinitialisation du light sensor");
            int res = this->init();
            if (res == 1)
            {
                //TODO: handle error
            }
            i++;
            delay(1000);
        }
    } while (i < 5);
    return 0;
}

String BrightnessSensor::toString(void)
{
    return String("type: " + this->getType() + "; measureInterval: " + String(this->getMeasureInterval()) + " ; id: " + this->getId());
}