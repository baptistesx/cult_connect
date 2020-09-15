#ifndef __BLE_CHARACTERISTIC_CALLBACKS_H_
#define __BLE_CHARACTERISITC_CALLBACKS_H_

#include <Arduino.h>

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

class BleServerCharacteristicCallbacks : public BLECharacteristicCallbacks
{
public:
    BleServerCharacteristicCallbacks();
    ~BleServerCharacteristicCallbacks();
    // Callback called when a value is received
    void onWrite(BLECharacteristic *pCharacteristic);
};

#endif