#include "sensors/air_humidity_sensor.h"

AirHumiditySensor::AirHumiditySensor(DHT *dhtSensor, uint8_t dhtType, uint8_t pin, String id, String type, uint32_t timer, uint32_t repeat, resolution_t resolution) : Sensor(id, type, timer, repeat, resolution)
{
    this->sensor = dhtSensor;
    this->dhtPin = pin;
    this->dhtType = dhtType;
}
AirHumiditySensor::~AirHumiditySensor() {}

float AirHumiditySensor::getMeasure(void)
{
    /*  Reading temperature or humidity takes about 250 milliseconds!
    Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)*/
    float humidity = this->sensor->readHumidity();
    return isnan(humidity) ? -1 : humidity;
}
uint8_t AirHumiditySensor::getDhtPin(void) { return this->dhtPin; }

uint8_t AirHumiditySensor::getDhtType(void) { return this->dhtType; }

String AirHumiditySensor::toString(void)
{
    return String("type: " + this->getType() + "; measureInterval: " + String(this->getMeasureInterval()) + " ; id: " + this->getId());
}