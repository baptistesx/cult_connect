#ifndef BLE_H_
#define BLE_H_

#include "initialisation.h"
// #include "spiffs_functions.h"
#include "connectivity.h"

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <BLE2902.h>
extern String PRIVATE_ID;
extern String MODULE_NAME;
//TODO: change following the module
// #define PRIVATE_ID "456"

#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"


extern BLECharacteristic *pCharacteristic;
extern BLEServer *pServer;

extern String routerSsid;
extern String routerPassword;

extern bool isBLEConnected;
extern bool oldIsBLEConnected;

extern std::string rawValueReceived;
extern uint32_t valToNotify;
extern uint32_t oldValToNotify;

class MyCallbacks : public BLECharacteristicCallbacks
{
    void onWrite(BLECharacteristic *pCharacteristic)
    {
        String routerSsidReceived = "";
        String routerPasswordReceived = "";
        String privateIdReceived = "";
        oldValToNotify = valToNotify;

        rawValueReceived = pCharacteristic->getValue();

        int n = 0;
        if (rawValueReceived.length() > 0)
        {
            Serial.println("*********");
            Serial.print("New rawValueReceived: ");
            for (int i = 0; i < rawValueReceived.length(); i++)
            {
                Serial.print(rawValueReceived[i]);
                if (rawValueReceived[i] == ';')
                    n++;
                else
                {
                    if (n == 0)
                        routerSsidReceived = String(routerSsidReceived + rawValueReceived[i]);
                    else if (n == 1)
                        routerPasswordReceived = String(routerPasswordReceived + rawValueReceived[i]);
                    else
                        privateIdReceived = String(privateIdReceived + rawValueReceived[i]);
                }
            }

            delay(3000); //TODO: to reduce

            if (privateIdReceived == PRIVATE_ID)
            {
                if (!connection2InternetRouter(routerSsidReceived, routerPasswordReceived))
                {
                    String s = "\nUnable to connect to the internet router\n";
                    s += "Timer config to retry later...\n";
                    Serial.printf("%s", s.c_str());
                    pCharacteristic->setValue("0");
                    Serial.printf("val to notify: 0");
                }
                else
                {
                    //router ids and private ids match => OK
                    isBleON = false;
                    routerSsid = routerSsidReceived;
                    routerPassword = routerPasswordReceived;
                    pCharacteristic->setValue("1");
                    Serial.printf("val to notify: 1");
                }
            }
            else
            {
                pCharacteristic->setValue("2");
                Serial.printf("val to notify: 2");
            }

            Serial.println("*********");
        }
    }
};

class MyServerCallbacks : public BLEServerCallbacks
{
    void onConnect(BLEServer *pServer)
    {
        Serial.print("onConnect");
        isBLEConnected = true;
    };

    void onDisconnect(BLEServer *pServer)
    {
        Serial.print("onDisConnect");

        isBLEConnected = false;
    }
};

void BLEInit();

#endif