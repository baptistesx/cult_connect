#ifndef __CONFIG_H_
#define __CONFIG_H_

// #include "main.h"
#include "Arduino.h"
#include "sensor.h"
#include <vector>

class Config
{
private:
    uint8_t RESET_BUTTON_PIN;
    uint8_t BLE_STATUS_LED_PIN;
    uint8_t SOCKET_STATUS_LED_PIN;
    bool resetModuleFlag;
    unsigned long lastDebounceTime;

public:
    Sensor *sensorFocused;
    String routerSSID;
    String routerPassword;
    String id;
    String name;
    String privateId;
    int nbSensors;
    std::vector<Sensor *> sensors;

    Config();

    void setLastDebounceTime(unsigned long value);
    unsigned long getLastDebounceTime(void);
    void setResetModuleFlag(bool value);
    bool getResetModuleFlag(void);
    void setRouterInfo(String routerSSID, String routerPassword);
    void setModuleInfo(String id, String privateId);
    void setResetButtonPin(uint8_t pin);
    void setBleStatusLedPin(uint8_t pin);
    void setSocketStatusLedPin(uint8_t pin);
    uint8_t getResetButtonPin(void);
    uint8_t getBleStatusLedPin(void);
    uint8_t getSocketStatusLedPin(void);
    String getRouterSSID();
    String getRouterPassword();
    String getId();
    String getName();
    String getPrivateId();
    String toString();
    int getNbSensors();
    void setSensorsSize(int size);
    // setModuleName(String moduleId);
    // setSensors(Sensor sensorsList[])
};

#endif