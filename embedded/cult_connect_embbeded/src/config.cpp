#include "config.h"

Config::Config() : resetModuleFlag(false), lastDebounceTime(0), routerSSID(""), routerPassword(""), id(""), name(""), privateId("") {}

void Config::setResetModuleFlag(bool value)
{
    this->resetModuleFlag = value;
}

bool Config::getResetModuleFlag(void)
{
    return this->resetModuleFlag;
}

void Config::setLastDebounceTime(unsigned long value)
{
    this->lastDebounceTime = value;
}

unsigned long Config::getLastDebounceTime(void)
{
    return this->lastDebounceTime;
}

void Config::setRouterInfo(String routerSSID, String routerPassword)
{
    this->routerSSID = routerSSID;
    this->routerPassword = routerPassword;
}

void Config::setModuleInfo(String id, String privateId)
{
    this->id = id;
    this->name = "M_" + id;
    this->privateId = privateId;
}

void Config::setResetButtonPin(uint8_t pin)
{
    this->RESET_BUTTON_PIN = pin;
}

void Config::setBleStatusLedPin(uint8_t pin)
{
    this->BLE_STATUS_LED_PIN = pin;
}

void Config::setSocketStatusLedPin(uint8_t pin)
{
    this->SOCKET_STATUS_LED_PIN = pin;
}

uint8_t Config::getResetButtonPin(void)
{
    return this->RESET_BUTTON_PIN;
}

uint8_t Config::getBleStatusLedPin(void)
{
    return this->BLE_STATUS_LED_PIN;
}

uint8_t Config::getSocketStatusLedPin(void)
{
    return this->SOCKET_STATUS_LED_PIN;
}

String Config::getRouterSSID() { return this->routerSSID; }

int Config::getNbSensors() { return this->nbSensors; }

String Config::getRouterPassword() { return this->routerPassword; }

String Config::getId() { return this->id; }

String Config::getName() { return this->name; }

String Config::getPrivateId() { return this->privateId; }

String Config::toString()
{
    return "routerSSId: " + this->getRouterSSID() + " ; routerPassword: " + this->getRouterPassword() + " ; id: " + this->getId() + " ; name: " + this->getName() + " ; privateId: " + this->getPrivateId() + "; nbSensors: " + String(this->getNbSensors()) + "; button pin:" + String(this->getResetButtonPin()) + "; ble led:" + String(this->getBleStatusLedPin()) + ";socket led:" + String(this->getSocketStatusLedPin());
}

void Config::setSensorsSize(int size)
{
    this->nbSensors = size;
    this->sensors.reserve(size);
}
