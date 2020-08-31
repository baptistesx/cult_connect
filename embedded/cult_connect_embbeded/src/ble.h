#ifndef BLE_H
#define BLE_H

#include "initialisation.h"
#include "spiff_functions.h"

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>

#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

extern BLECharacteristic *pCharacteristic;
extern BLEServer *pServer;

extern String routerSsid;
extern String routerPassword;
extern String privateId;
extern bool deviceConnected;
extern bool oldDeviceConnected;
extern std::string value;
extern std::string old_value;
extern uint32_t valToNotify;
extern uint32_t oldValToNotify;

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
                        routerSsid = String(routerSsid + value[i]);
                    }
                    else if (n == 1)
                    {
                        routerPassword = String(routerPassword + value[i]);
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
                if (!connection_to_internet_router())
                {
                    String s = "\nUnable to connect to the internet router\n";
                    s += "Timer config to retry later...\n";
                    Serial.printf("%s", s.c_str());

                    // start_new_try.attach(TEMPO_NEW_TRY, new_try);

                    // valToNotify = 1;
                    // pCharacteristic->setValue("1");
                    pCharacteristic->setValue("0");
                    Serial.printf("val to notify: 0");
                    isBleON = false;
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
            Serial.printf("ssid: %s et pwd: %s\n", routerSsid, routerPassword);
            routerSsid = "";
            routerPassword = "";
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

void ble_init();

#endif