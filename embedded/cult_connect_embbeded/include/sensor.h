#ifndef __SENSOR_H_
#define __SENSOR_H_

#include <Arduino.h>

// Library to work with DHT (humidity/temperature sensor)
#include "DHT.h"

// Adafruit library to work with various sensors
#include <Adafruit_Sensor.h>

// The TSL2561 is a luminosity sensor
#include <Adafruit_TSL2561_U.h>

// The content of the library Ticker has been extracted and use directly in th Sensor class
// in order to be more flexible on the ISR

/** Ticker internal resolution
 *
 * @param MICROS default, the resolution is in micro seconds, max is 70 minutes, the real resoltuion is 4 microseconds at 16MHz CPU cycle
 * @param MILLIS set the resolution to millis, for longer cycles over 70 minutes
 *
 */
enum resolution_t
{
    MICROS,
    MILLIS,
    MICROS_MICROS
};

/** Ticker status
 *
 * @param STOPPED default, ticker is stopped
 * @param RUNNIBG ticker is running
 * @param PAUSED ticker is paused
 *
 */
enum status_t
{
    STOPPED,
    RUNNING,
    PAUSED
};

// Global Sensor class, the specific sensors class will extends this one
class Sensor
{
private:
    // Type of the measure (temperature, humidity etc...)
    String type;

    // Sensor id (same as in database)
    String id;

    // Returns mesure timer flag
    bool tick();

    // Enable tick()
    bool enabled;

    // Measure period
    uint32_t timer;
    uint32_t repeat;
    resolution_t resolution;
    uint32_t counts;
    status_t status;
    uint32_t lastTime;
    uint32_t diffTime;

public:
    Sensor(String id, String type, uint32_t timer, uint32_t repeat = 0, resolution_t resolution = MILLIS);

    ~Sensor();
    /** start the ticker
	 *
	 */
    void start();

    /** resume the ticker. If not started, it will start it.
	 *
	 */
    void resume();

    /** pause the ticker
	 *
	 */
    void pause();

    /** stops the ticker
	 *
	 */
    void stop();

    /** must to be called in the main loop(), it will check the Ticker, and if necessary, will run the callback
	 *
	 */
    void update();

    /**
	 * @brief set the interval timer
	 * 
	 * @param timer interval length in ms or us
	 */
    void interval(uint32_t timer);

    /** actual ellapsed time
	 *
	 * @returns the elapsed time after the last tick
	 *
	 */
    uint32_t elapsed();

    /** get the state of the ticker
	 *
	 * @returns the state of the ticker: STOPPED, RUNNING or PAUSED
	 */
    status_t state();

    /** get the numbers of executed repeats
	 *
	 * @returns the number of executed repeats
	 *
	 */
    uint32_t counter();

    // Get the timer attribut (period between measures)
    uint32_t getMeasureInterval(void);

    // Enable timer interruption
    void setISR(void);

    // Get sensor id
    String getId(void);

    void setType(String type);
    String getType(void);

    // Once the measure is realized, send data to the server to store them
    int sendSensorData2Server();

    // Virutal method that specific sensors will implement
    virtual float getMeasure(void){};

    // TODO: move to TemperatureSensor class but when  loop on moduleConfig.sensors =>issue cause it iterates on Sensor objects and not on specific sensors
    virtual int getDhtPin(){};
    virtual int getDhtType(){};

    virtual String toString(){};
};

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

    int getDhtPin(void);
    int getDhtType(void);

    // Realize the temperature measure
    float getMeasure(void) override;

    String toString(void) override;
};

// Specific class for temperature sensor
// Allow to add attributes and methods to the DHT object
class AirHumiditySensor : public Sensor
{
private:
    // DHT : Digital Humidity and Temperature sensor
    DHT *sensor;

    // uC pin on which is connected the sensor
    int dhtPin;

    // DHT11 or DHT22
    int dhtType;

public:
    AirHumiditySensor(DHT *dhtSensor, int dhtType, int pin, String id, String type, uint32_t timer, uint32_t repeat = 0, resolution_t resolution = MILLIS);

    int getDhtPin(void);
    int getDhtType(void);

    // Realize the humidity measure
    float getMeasure(void) override;

    String toString(void) override;
};

// Specific class for brightness sensor
// Allows to add attributes and methods to the Adafruit_TSL2561_Unified sensor
class BrightnessSensor : public Sensor
{
private:
    Adafruit_TSL2561_Unified sensor;

public:
    BrightnessSensor(String id, String type, uint32_t timer, uint32_t repeat = 0, resolution_t resolution = MILLIS);

    // Initialize the sensor
    int init();

    // Realize the measure
    float getMeasure(void) override;

    String toString(void) override;
};

#endif