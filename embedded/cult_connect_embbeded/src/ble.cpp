#include "ble.h"
#include "main.h"

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
    digitalWrite(moduleConfig.getBleStatusLedPin(), HIGH);
    digitalWrite(moduleConfig.getSocketStatusLedPin(), LOW);

    BLEDevice::init(moduleConfig.getName().c_str());
    this->setPServer();
    this->getPServer()->setCallbacks(new BleServerCallbacks());

    BLEService *pService = this->getPServer()->createService(SERVICE_UUID);

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

void BleServerCharacteristicCallbacks::onWrite(BLECharacteristic *pCharacteristic)
{
    String routerSsidReceived = "";
    String routerPasswordReceived = "";
    String privateIdReceived = "";

    Serial.println("*********");

    // Read the received value
    std::string rawBLEValueReceived = bleInstance.getPCharacteristic()->getValue();

    if (rawBLEValueReceived.length() > 0)
    {
        parseRawBLEValue(rawBLEValueReceived, &routerSsidReceived, &routerPasswordReceived, &privateIdReceived);

        delay(500); //TODO: to reduce

        //TODO: use type def constants for values to notify
        // The privateId received match MODULE_PRIVATE_ID
        // => the user is well trying to add this module
        if (privateIdReceived == moduleConfig.getPrivateId())
        {
            Serial.println("Private Id received: OK");
            // Test the internet router ids received
            if (!connection2InternetRouter(routerSsidReceived, routerPasswordReceived))
            {
                Serial.println("[ERROR] Unable to connect to the internet router with the ids received");
                Serial.println("val to notify: 0");
                bleInstance.getPCharacteristic()->setValue("0");
            }
            else
            {
                moduleConfig.setRouterInfo(routerSsidReceived, routerPasswordReceived);

                saveRouterInfoInSPIFFS();

                // Router ids and private ids match => OK
                // => turn off BLE mode
                bleInstance.setIsBleOn(false);

                Serial.println("Internet router ids received: OK");
                Serial.println("val to notify: 1");
                bleInstance.getPCharacteristic()->setValue("1");
            }
        }
        else
        {
            Serial.println("[ERROR] Private id recevied: KO");
            Serial.println("val to notify: 2");
            bleInstance.getPCharacteristic()->setValue("2");
        }

        Serial.println("*********");
    }
    else
    {
        Serial.println("[ERROR] BLE value received is empty!");
        Serial.println("val to notify: 3");
        bleInstance.getPCharacteristic()->setValue("3");
    }
}

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

void parseRawBLEValue(std::string rawBLEValueReceived, String *routerSsidReceived, String *routerPasswordReceived, String *privateIdReceived)
{
    int n = 0;

    Serial.print("New rawBLEValueReceived: ");

    //TODO: use json
    // Raw format: ssid;password;privateId
    for (int i = 0; i < rawBLEValueReceived.length(); i++)
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