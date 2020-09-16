#include "ble/ble_server_callbacks.h"
#include "main.h"

BleServerCallbacks::BleServerCallbacks() {}

BleServerCallbacks::~BleServerCallbacks(){}

void BleServerCallbacks::onConnect(BLEServer *pServer)
{
    Serial.println("BLE Connected");
    bleInstance.setIsBleConnected(true);
};

void BleServerCallbacks::onDisconnect(BLEServer *pServer)
{
    Serial.println("BLE Disonnected");
    bleInstance.setIsBleConnected(false);
}