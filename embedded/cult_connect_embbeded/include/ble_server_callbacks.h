#ifndef __BLE_SERVER_CALLBACKS_H_
#define __BLE_SERVER_CALLBACKS_H_

#include <Arduino.h>

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

class BleServerCallbacks : public BLEServerCallbacks
{
public:
    BleServerCallbacks();
    ~BleServerCallbacks();

    // Callback called when the module is connected to another device
    void onConnect(BLEServer *pServer);

    // Callback called when the module is disconnected
    void onDisconnect(BLEServer *pServer);
};

#endif