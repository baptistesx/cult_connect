//BLE: Bluetooth Low Energy
#ifndef __BLE_H_
#define __BLE_H_

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>
#include <Arduino.h>

class BleInstance
{
private:
    bool isBleON;
    bool oldIsBleON;
    bool isBleConnected;
    bool oldIsBleConnected;

    BLECharacteristic *pCharacteristic;
    BLEServer *pServer;

public:
    BleInstance();

    void setIsBleOn(bool value);
    void setOldIsBleOn(bool value);
    void setIsBleConnected(bool value);
    void setOldIsBleConnected(bool value);
    bool getIsBleOn(void);
    bool getOldIsBleOn(void);
    bool getIsBleConnected(void);
    bool getOldIsBleConnected(void);
    void setPCharacteristic(BLECharacteristic *characteristic);
    void setPServer();
    BLECharacteristic *getPCharacteristic(void);
    BLEServer *getPServer(void);
    void init(void);
};

class BleServerCallbacks : public BLEServerCallbacks
{
public:
    // Callback called when the module is connected to another device
    void onConnect(BLEServer *pServer);

    // Callback called when the module is disconnected
    void onDisconnect(BLEServer *pServer);
};

class BleServerCharacteristicCallbacks : public BLECharacteristicCallbacks
{
public:
    // Callback called when a value is received
    void onWrite(BLECharacteristic *pCharacteristic);
};

// Initialize the Bluetooh Low Energy server and its characteristics etc...
void BLEInit(void);
void parseRawBLEValue(std::string rawBLEValueReceived, String *routerSsidReceived, String *routerPasswordReceived, String *privateIdReceived);

#endif