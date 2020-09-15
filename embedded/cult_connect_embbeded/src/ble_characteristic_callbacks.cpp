#include "ble_characteristic_callbacks.h"
#include "main.h"

BleServerCharacteristicCallbacks::BleServerCharacteristicCallbacks() {}

BleServerCharacteristicCallbacks::~BleServerCharacteristicCallbacks() {}

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
        bleInstance.parseRawBLEValue(rawBLEValueReceived, &routerSsidReceived, &routerPasswordReceived, &privateIdReceived);

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