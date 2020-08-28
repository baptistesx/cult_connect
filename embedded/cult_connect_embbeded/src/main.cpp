/*
    Based on Neil Kolban example for IDF: https://github.com/nkolban/esp32-snippets/blob/master/cpp_utils/tests/BLE%20Tests/SampleWrite.cpp
    Ported to Arduino ESP32 by Evandro Copercini
*/

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

#include <Arduino.h>

#define MODULE_NAME "M_5e7a80125d33fe0d041ff8cb"
#define PRIVATE_ID "123"
// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
BLECharacteristic *pCharacteristic = NULL;
BLEServer *pServer = NULL;

String ssid = "";
String pwd = "";
String privateId = "";
bool deviceConnected = false;
bool oldDeviceConnected = false;
std::string value = "0";
std::string old_value = "0";
uint32_t valToNotify = 0;
uint32_t oldValToNotify = 0;
class MyCallbacks : public BLECharacteristicCallbacks
{

    void onWrite(BLECharacteristic *pCharacteristic)
    {
        oldValToNotify = valToNotify;
        // old_value = value;
        value = pCharacteristic->getValue();

        int n = 0;
        if (value.length() > 0)
        {

            Serial.println("*********");
            Serial.print("New value: ");
            for (int i = 0; i < value.length(); i++)
            {
                Serial.print(value[i]);
                if (value[i] == ';')
                    n++;
                else
                {
                    if (n == 0)
                    {
                        ssid = String(ssid + value[i]);
                    }
                    else if (n == 1)
                    {
                        pwd = String(pwd + value[i]);
                    }
                    else
                    {
                        privateId = String(privateId + value[i]);
                    }
                }
            }
            delay(3000);
            Serial.print("privateId: ");
            Serial.println(privateId);
            Serial.print("PRIVATE_ID: ");
            Serial.println(PRIVATE_ID);
            if (privateId == PRIVATE_ID)
            {
                if (ssid == "toto" && pwd == "tata")
                {
                    // valToNotify = 1;
                    // pCharacteristic->setValue("1");
                    pCharacteristic->setValue("0");
                    Serial.printf("val to notify: 0");
                }
                else
                {
                    // valToNotify = 0;
                    // pCharacteristic->setValue("0");
                    pCharacteristic->setValue("1");
                    Serial.printf("val to notify: 1");
                }
            }
            else
            {
                // valToNotify = 0;
                // pCharacteristic->setValue("0");
                pCharacteristic->setValue("2");
                Serial.printf("val to notify: 2");
            }

            Serial.println();
            Serial.println("*********");
            Serial.printf("ssid: %s et pwd: %s\n", ssid, pwd);
            ssid = "";
            pwd = "";
            privateId = "";
        }
    }
};
class MyServerCallbacks : public BLEServerCallbacks
{
    void onConnect(BLEServer *pServer)
    {
        Serial.print("onConnect");
        deviceConnected = true;
    };

    void onDisconnect(BLEServer *pServer)
    {
        Serial.print("onDisConnect");

        deviceConnected = false;
    }
};
void setup()
{
    Serial.begin(115200);

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
    Serial.println("setup done");
}

void loop()
{
    // if (deviceConnected)
    // {
    //     // Serial.print("[");
    //     // for (int i = 0; i < valToNotify.length(); i++)
    //     // {
    //     Serial.printf("%d", valToNotify);
    //     // }
    //     Serial.print("]");
    //     pCharacteristic->setValue((uint8_t *)&valToNotify, 4);
    //     pCharacteristic->notify();
    //     // Serial.printf("val to notify: %d", valToNotify);
    //     delay(2000); // bluetooth stack will go into congestion, if too many packets are sent, in 6 hours test i was able to go as low as 3ms
    //     // }
    // }
    // disconnecting
    if (!deviceConnected && oldDeviceConnected)
    {
        Serial.println("Disconected");
        delay(500);                  // give the bluetooth stack the chance to get things ready
        pServer->startAdvertising(); // restart advertising
        Serial.println("start advertising");
        oldDeviceConnected = deviceConnected;
    }
    // connecting
    if (deviceConnected && !oldDeviceConnected)
    {
        // do stuff here on connecting
        Serial.println("Connected");
        oldDeviceConnected = deviceConnected;
    }
    delay(150);
}