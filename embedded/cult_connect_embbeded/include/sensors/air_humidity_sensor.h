#ifndef __AIR_HUMIDITY_SENSOR_H
#define __AIR_HUMIDITY_SENSOR_H

#include <Arduino.h>
#include "sensors/sensor.h"

// Library to work with DHT (humidity/temperature sensor)
#include "DHT.h"

// Specific class for temperature sensor
// Allow to add attributes and methods to the DHT object
class AirHumiditySensor : public Sensor
{
private:
    // DHT : Digital Humidity and Temperature sensor
    DHT *sensor;

    // uC pin on which is connected the sensor
    uint8_t dhtPin;

    // DHT11 or DHT22
    uint8_t dhtType;

public:
    AirHumiditySensor(DHT *dhtSensor, uint8_t dhtType, uint8_t pin, String id, String type, uint32_t timer, uint32_t repeat = 0, resolution_t resolution = MILLIS);
    ~AirHumiditySensor();

    uint8_t getDhtPin(void);
    uint8_t getDhtType(void);

    // Realize the humidity measure
    float getMeasure(void) override;

    String toString(void) override;
};

#endif