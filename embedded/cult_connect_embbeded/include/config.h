#ifndef __CONFIG_H_
#define __CONFIG_H_

#include "Arduino.h"
#include "sensors/sensor.h"
#include <vector>

// Class containing all module infos and the sensors the module contains
class Config
{
private:
    uint8_t RESET_BUTTON_PIN;
    uint8_t BLE_STATUS_LED_PIN;
    uint8_t SOCKET_STATUS_LED_PIN;
    bool resetModuleFlag;
    unsigned long lastDebounceTime;
    String routerSSID;
    String routerPassword;
    String id;
    String name;
    String privateId;
    uint8_t nbSensors;

public:
    // TODO: needs to be private?
    std::vector<Sensor *> sensors;

    Config();
    ~Config();

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
    uint8_t getNbSensors();
    void setSensorsSize(uint8_t size);
    String toString();
};

#endif