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
    Serial.println("iniit BLLEE");
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
    // oldValToNotifyBLE = valToNotifyBLE;

    Serial.println("*********");

    // Read the received value
    std::string rawBLEValueReceived = bleInstance.getPCharacteristic()->getValue();

    if (rawBLEValueReceived.length() > 0)
    {
        parseRawBLEValue(rawBLEValueReceived, &routerSsidReceived, &routerPasswordReceived, &privateIdReceived);

        delay(500); //TODO: to reduce

        //TODO: use global constants for values to notify
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

                File file = SPIFFS.open(CONFIG_FILE_PATH_IN_SPIFFS, FILE_WRITE);

                const size_t capacity = JSON_ARRAY_SIZE(2) + JSON_OBJECT_SIZE(3) + JSON_OBJECT_SIZE(5) + JSON_OBJECT_SIZE(9);
                DynamicJsonDocument doc(3000);

                doc["routerSSID"] = moduleConfig.getRouterSSID();
                doc["routerPassword"] = moduleConfig.getRouterPassword();
                doc["id"] = moduleConfig.getId();
                doc["privateId"] = moduleConfig.getPrivateId();
                doc["resetButtonPin"] = moduleConfig.getResetButtonPin();
                doc["bleStatusLedPin"] = moduleConfig.getBleStatusLedPin();
                doc["socketStatusLedPin"] = moduleConfig.getSocketStatusLedPin();
                doc["nbSensors"] = moduleConfig.getNbSensors();

                JsonArray sensors = doc.createNestedArray("sensors");

                for (int i = 0; i < moduleConfig.getNbSensors(); i++)
                {
                    Serial.print("for loop: ");
                    Serial.println(i);
                    JsonObject sensor = sensors.createNestedObject();

                    char charBuf[50];
                    moduleConfig.sensors[i]->getId().toCharArray(charBuf, 50);

                    sensor["id"] = moduleConfig.sensors[i]->getId();
                    sensor["type"] = moduleConfig.sensors[i]->getType();
                    sensor["intervalMeasure"] = moduleConfig.sensors[i]->getMeasureInterval();

                    if (String(moduleConfig.sensors[i]->getType()) == "temperature")
                    {
                        sensor["pin"] = moduleConfig.sensors[i]->getDhtPin();
                        sensor["dhtType"] = moduleConfig.sensors[i]->getDhtType();
                        Serial.println(sensor["pin"].as<int>());
                        Serial.println(sensor["dhtType"].as<int>());
                    }
                    if (String(moduleConfig.sensors[i]->getType()) == "luminosity")
                    {
                        Serial.println("luminosity sensor");
                    }
                }

                // Serialize JSON to file
                if (serializeJson(doc, file) == 0)
                {
                    Serial.println(F("Failed to write to file"));
                }

                // Router ids and private ids match => OK
                // => turn off BLE mode
                bleInstance.setIsBleOn(false);
                // routerSsid = routerSsidReceived;
                // routerPassword = routerPasswordReceived;
                Serial.println("Internet router ids received: OK");
                Serial.println("val to notify: 1");
                bleInstance.getPCharacteristic()->setValue("1");

                // int res = readConfigFileFromSPIFFS();
                // //TODO: todo
                // // if (rawint res = readConfigFileFromSPIFFS();
                // switch (res)
                // {
                // case 0:
                //     Serial.println("[INIT] Module configuration from config.json file: OK");
                //     Serial.println(moduleConfig.toString());
                //     break;
                // case 1:
                //     Serial.println("[ERROR] Module configuration from config.json file: KO, no config file found!");
                //     Serial.println("Reboot..");
                //     ESP.restart();
                //     break;
                // case 2:
                //     Serial.println("[ERROR] Module configuration from config.json file: KO, error while parsing the config file!");
                //     Serial.println("Reboot..");
                //     ESP.restart();
                //     break;
                // default:
                //     break;
                // }
                // String string2Store = routerSsidReceived + "&" + routerPasswordReceived;
                // writeFile(SPIFFS, ROUTER_IDS_FILE_PATH_IN_SPIFFS, string2Store.c_str());
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

void BLEInit(void)
{
    // digitalWrite(moduleConfig.getBleStatusLedPin(), HIGH);
    // digitalWrite(moduleConfig.getSocketStatusLedPin(), LOW);

    // BLEDevice::init(moduleConfig.getName().c_str());
    // pServer = BLEDevice::createServer();
    // pServer->setCallbacks(new BleServerCallbacks());

    // BLEService *pService = pServer->createService(SERVICE_UUID);

    // pCharacteristic = pService->createCharacteristic(
    //     CHARACTERISTIC_UUID,
    //     BLECharacteristic::PROPERTY_READ |
    //         BLECharacteristic::PROPERTY_WRITE |
    //         BLECharacteristic::PROPERTY_READ |
    //         BLECharacteristic::PROPERTY_NOTIFY);

    // // Create a BLE Descriptor
    // pCharacteristic->addDescriptor(new BLE2902());

    // pCharacteristic->setCallbacks(new BleServerCharacteristicCallbacks());

    // uint32_t valToNotifyBLE = 0;
    // pCharacteristic->setValue((uint8_t *)&valToNotifyBLE, 4);
    // pService->start();

    // BLEAdvertising *pAdvertising = pServer->getAdvertising();
    // pAdvertising->start();

    // isBleON = true;
    // oldIsBleON = true;
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