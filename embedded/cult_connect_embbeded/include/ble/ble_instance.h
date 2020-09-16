//BLE: Bluetooth Low Energy
#ifndef __BLE_INSTANCE_H_
#define __BLE_INSTANCE_H_

#include <Arduino.h>

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

// BLE instance containing BLE state, the server and the characteristic
class BleInstance
{
private:
    // Current BLE state
    bool isBleON;

    // Previous BLE state
    bool oldIsBleON;

    // Current BLE connection with device state
    bool isBleConnected;

    // Previous BLE connection with device state
    bool oldIsBleConnected;

    // Characteristic: equivalent to a communication canal between the module and the paired device
    BLECharacteristic *pCharacteristic;

    // BLE server representing the module on other devices
    BLEServer *pServer;

public:
    BleInstance();
    ~BleInstance();

    // Initialize the server and the characteristic to be available
    void init(void);

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

    // TODO: use json
    // Parse the internet router ids and the private id received by the paired device
    void parseRawBLEValue(std::string rawBLEValueReceived, String *routerSsidReceived, String *routerPasswordReceived, String *privateIdReceived);
};

#endif