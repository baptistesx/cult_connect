#include "sensors/brightness_sensor.h"

BrightnessSensor::BrightnessSensor(String id, String type, uint32_t timer, uint32_t repeat, resolution_t resolution) : Sensor(id, type, timer, repeat, resolution), sensor(TSL2561_ADDR_FLOAT, 12345) {}
BrightnessSensor::~BrightnessSensor() {}

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