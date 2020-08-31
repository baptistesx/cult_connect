#include "ble.h"

BLECharacteristic *pCharacteristic = NULL;
BLEServer *pServer = NULL;


String privateId = "";
bool deviceConnected = false;
bool oldDeviceConnected = false;
std::string value = "0";
std::string old_value = "0";
uint32_t valToNotify = 0;
uint32_t oldValToNotify = 0;

void ble_init()
{
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
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.descriptor.gatt.client_characteristic_configuration.xml
    // Create a BLE Descriptor
    pCharacteristic->addDescriptor(new BLE2902());

    pCharacteristic->setCallbacks(new MyCallbacks());

    pCharacteristic->setValue((uint8_t *)&valToNotify, 4);
    pService->start();

    BLEAdvertising *pAdvertising = pServer->getAdvertising();
    pAdvertising->start();

    isBleON = true;
}