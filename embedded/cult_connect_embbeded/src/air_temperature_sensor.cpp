#include "air_temperature_sensor.h"

AirTemperatureSensor::AirTemperatureSensor(DHT *dhtSensor, int dhtType, int pin, String id, String type, uint32_t timer, uint32_t repeat, resolution_t resolution) : Sensor(id, type, timer, repeat, resolution)
{
    this->sensor = dhtSensor;
    this->dhtPin = pin;
    this->dhtType = dhtType;
}

AirTemperatureSensor::~AirTemperatureSensor() {}

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