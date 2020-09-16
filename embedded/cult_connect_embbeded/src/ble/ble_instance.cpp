#include "ble/ble_instance.h"
#include "main.h"
#include "ble/ble_server_callbacks.h"
#include "ble/ble_characteristic_callbacks.h"

BleInstance::BleInstance()
{
    this->isBleON = false;
    this->oldIsBleON = false;
    this->isBleConnected = false;
    this->oldIsBleConnected = false;
    this->pCharacteristic = NULL;
    this->pServer = NULL;
}

BleInstance::~BleInstance() {}

void BleInstance::setIsBleOn(bool value) { this->isBleON = value; }
void BleInstance::setOldIsBleOn(bool value) { this->oldIsBleON = value; }
void BleInstance::setIsBleConnected(bool value) { this->isBleConnected = value; }
void BleInstance::setOldIsBleConnected(bool value) { this->oldIsBleConnected = value; }
bool BleInstance::getIsBleOn(void) { return this->isBleON; }
bool BleInstance::getOldIsBleOn(void) { return this->oldIsBleON; }
bool BleInstance::getIsBleConnected(void) { return this->isBleConnected; }
bool BleInstance::getOldIsBleConnected(void) { return this->oldIsBleConnected; }
void BleInstance::setPCharacteristic(BLECharacteristic *characteristic) { this->pCharacteristic = characteristic; }
void BleInstance::setPServer() { this->pServer = BLEDevice::createServer(); }
BLECharacteristic *BleInstance::getPCharacteristic(void) { return this->pCharacteristic; }
BLEServer *BleInstance::getPServer(void) { return this->pServer; }

void BleInstance::init(void)
{
    // Indicate with LEDs, the BLE mode is ON
    digitalWrite(moduleConfig.getBleStatusLedPin(), HIGH);
    digitalWrite(moduleConfig.getSocketStatusLedPin(), LOW);

    // Initialize the BLE on the module, then initialize the server
    // in order user via mobile app can connect to the module
    BLEDevice::init(moduleConfig.getName().c_str());
    this->setPServer();

    // The callbacks will be triggered with events of the BLE state
    this->getPServer()->setCallbacks(new BleServerCallbacks());

    BLEService *pService = this->getPServer()->createService(SERVICE_UUID);

    // Instanciate the characteristic which is equivalent to a communication canal
    // between the module and the paired devices
    this->setPCharacteristic(pService->createCharacteristic(
        CHARACTERISTIC_UUID,
        BLECharacteristic::PROPERTY_READ |
            BLECharacteristic::PROPERTY_WRITE |
            BLECharacteristic::PROPERTY_READ |
            BLECharacteristic::PROPERTY_NOTIFY));

    // Create a BLE Descriptor
    this->getPCharacteristic()->addDescriptor(new BLE2902());

    this->getPCharacteristic()->setCallbacks(new BleServerCharacteristicCallbacks());

    uint32_t valToNotifyBLE = 0;
    this->getPCharacteristic()->setValue((uint8_t *)&valToNotifyBLE, 4);
    pService->start();

    BLEAdvertising *pAdvertising = this->getPServer()->getAdvertising();
    pAdvertising->start();

    this->setIsBleOn(true);
    this->setOldIsBleOn(true);
}

void BleInstance::parseRawBLEValue(std::string rawBLEValueReceived, String *routerSsidReceived, String *routerPasswordReceived, String *privateIdReceived)
{
    uint8_t n = 0;

    Serial.print("New rawBLEValueReceived: ");

    //TODO: use json
    // Raw format: ssid;password;privateId
    for (uint32_t i = 0; i < rawBLEValueReceived.length(); i++)
    {
        Serial.print(rawBLEValueReceived[i]);
        if (rawBLEValueReceived[i] == ';')
            n++;
        else
        {
            if (n == 0)
                *routerSsidReceived = String(*routerSsidReceived + rawBLEValueReceived[i]);
            else if (n == 1)
                *routerPasswordReceived = String(*routerPasswordReceived + rawBLEValueReceived[i]);
            else
                *privateIdReceived = String(*privateIdReceived + rawBLEValueReceived[i]);
        }
    }
    Serial.println();
}