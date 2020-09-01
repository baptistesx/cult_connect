//BLE: Bluetooth Low Energy

#include "ble.h"

BLECharacteristic *pCharacteristic = NULL;
BLEServer *pServer = NULL;

bool isBLEConnected = false;
bool oldIsBLEConnected = false;

std::string rawValueReceived = "0";
uint32_t valToNotify = 0;
uint32_t oldValToNotify = 0;

bool oldIsBleON = false;
bool isBleON = false;

void BLEInit()
{
    digitalWrite(BLE_STATUS_LED_PIN, HIGH);
    digitalWrite(SOCKET_STATUS_LED_PIN, LOW);

    BLEDevice::init(MODULE_NAME);
    pServer = BLEDevice::createServer();
    pServer->setCallbacks(new MyServerCallbacks());

    BLEService *pService = pServer->createService(SERVICE_UUID);

    pCharacteristic = pService->createCharacteristic(
        CHARACTERISTIC_UUID,
        BLECharacteristic::PROPERTY_READ |
            BLECharacteristic::PROPERTY_WRITE |
            BLECharacteristic::PROPERTY_READ |
            BLECharacteristic::PROPERTY_NOTIFY);

    // Create a BLE Descriptor
    pCharacteristic->addDescriptor(new BLE2902());

    pCharacteristic->setCallbacks(new MyCallbacks());

    pCharacteristic->setValue((uint8_t *)&valToNotify, 4);
    pService->start();

    BLEAdvertising *pAdvertising = pServer->getAdvertising();
    pAdvertising->start();

    isBleON = true;
    oldIsBleON = true;
}