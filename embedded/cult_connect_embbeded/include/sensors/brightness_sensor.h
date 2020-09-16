#ifndef __BRIGHTNESS_SENSOR_H
#define __BRIGHTNESS_SENSOR_H

// Adafruit library to work with various sensors
#include <Adafruit_Sensor.h>

// The TSL2561 is a luminosity sensor
#include <Adafruit_TSL2561_U.h>

#include "sensors/sensor.h"

// Specific class for brightness sensor
// Allows to add attributes and methods to the Adafruit_TSL2561_Unified sensor
class BrightnessSensor : public Sensor
{
private:
    Adafruit_TSL2561_Unified sensor;

public:
    BrightnessSensor(String id, String type, uint32_t timer, uint32_t repeat = 0, resolution_t resolution = MILLIS);
    ~BrightnessSensor();

    // Initialize the sensor
    int init();

    // Realize the measure
    float getMeasure(void) override;

    String toString(void) override;
};

#endif