#ifndef __AIR_TEMPERATURE_SENSOR_H
#define __AIR_TEMPERATURE_SENSOR_H

#include <Arduino.h>
#include "sensor.h"

// Library to work with DHT (humidity/temperature sensor)
#include "DHT.h"

// Specific class for temperature sensor
// Allow to add attributes and methods to the DHT object
class AirTemperatureSensor : public Sensor
{
private:
    // DHT : Digital Humidity and Temperature sensor
    DHT *sensor;

    // uC pin on which is connected the sensor
    int dhtPin;

    // DHT11 or DHT22
    int dhtType;

public:
    AirTemperatureSensor(DHT *dhtSensor, int dhtType, int pin, String id, String type, uint32_t timer, uint32_t repeat = 0, resolution_t resolution = MILLIS);
    ~AirTemperatureSensor();

    int getDhtPin(void);
    int getDhtType(void);

    // Realize the temperature measure
    float getMeasure(void) override;

    String toString(void) override;
};

#endif