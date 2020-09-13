#ifndef __SENSOR_H_
#define __SENSOR_H_

#include <Arduino.h>

// Interrupt library
// #include <Ticker.h>

// Library to work with DHT (humidity/temperature sensor)
#include "DHT.h"
// Adafruit library to work with various sensors
#include <Adafruit_Sensor.h>

// The TSL2561 is a luminosity sensor
#include <Adafruit_TSL2561_U.h>
/** Ticker internal resolution
 *
 * @param MICROS default, the resoöution is in micro seconds, max is 70 minutes, the real resoltuion is 4 microseconds at 16MHz CPU cycle
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

// typedef void (*fptr)();

class Sensor
{
private:
    String type;
    String id;
    bool startMeasureFlag;
    // int measureInterval;

    // Ticker startingMeasureTicker;

    bool tick();
    bool enabled;
    uint32_t timer;
    uint32_t repeat;
    resolution_t resolution = MICROS;
    uint32_t counts;
    status_t status;
    // fptr callback;
    uint32_t lastTime;
    uint32_t diffTime;

public:
    Sensor(String id, String type, uint32_t timer, uint32_t repeat = 0, resolution_t resolution = MICROS);
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
    void setStartMeasureFlag(bool val);
    bool getStartMeasureFlag(void);
    uint32_t getMeasureInterval(void);
    void setISR(void);
    String getId(void);
    void setType(String type);
    String getType(void);
    void raiseStartMeasureFlag(void);
    void lowerStartMeasureFlag(void);
    virtual float getMeasure(void){};
    int sendSensorData2Server();
    virtual String toString(){};
    virtual int getDhtPin(){};
    virtual int getDhtType(){};
    // virtual void init(void);
};

class AirTemperatureSensor : public Sensor
{
private:
    DHT sensor;
    int dhtPin;
    int dhtType;

public:
    AirTemperatureSensor(int dhtType, int pin, String id, String type, uint32_t timer, uint32_t repeat = 0, resolution_t resolution = MICROS);

    int getDhtPin(void);
    int getDhtType(void);
    float getMeasure(void) override;
    // int sendSensorData2Server(void);
    String toString(void) override;
};

class BrightnessSensor : public Sensor
{
private:
    Adafruit_TSL2561_Unified sensor;

public:
    BrightnessSensor(String id, String type, uint32_t timer, uint32_t repeat = 0, resolution_t resolution = MICROS);

    int init();
    float getMeasure(void) override;
    // int sendSensorData2Server(void);
    String toString(void) override;
};

// class AirTemperatureSensor : public Sensor
// {
// private:
//     DHT sensor;

// public:
//     AirTemperatureSensor(int dhtType, int pin, int interval, String id, String type);
//     float getMeasure(void) override;
//     int sendSensorData2Server(void);
//     String toString(void);
// };

#endif