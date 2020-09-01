#include "headers.h"

//First executed function when the module starts <=> initialisation
void setup()
{
    serialPortInit();
    Serial.printf("=============================\nStarting setup\n=============================\n\n");

    Serial.println("[INIT] Serial communication (" + String(SERIAL_SPEED) + " bauds, 8 data bits, no parity, 1 stop bit): OK");

    statusLedsInit();
    Serial.println("[INIT] Status LEDs: OK");

    resetButtonInit();
    Serial.println("[INIT] Reset button on PIN " + String(RESET_BUTTON_PIN) + " (press over 2s to reset): OK");

    if (!SPIFFSInit()) //Init error case
    {
        printf("[INIT] SPIFFS: KO, SPIFFS Mount Failed -> Reboot...\n");

        ESP.restart();
    }
    Serial.println("[INIT] SPIFFS: OK");

    //TODO: to delete
    // writeFile(SPIFFS, ROUTER_IDS_FILE_PATH, "SFR_89B8&58baqh5jkg88xtvx7cih");
    // deleteFile(SPIFFS, ROUTER_IDS_FILE_PATH);

    if (getRouterIdFromSPIFFS() == 1)
    {
        Serial.println("No internet router ids stored in memory");
        Serial.println("\t=> BLE mode");
        BLEInit();
        Serial.println("[INIT] BLE: OK");
    }
    else
    {
        if (!connection2InternetRouter(routerSsid, routerPassword))
        {
            Serial.println("[INIT] Connection to the internet router: KO");
            Serial.println("=> ssid: " + routerSsid + " & password: " + routerPassword);

            //TODO: todo
            // Serial.println("\tTimer configuration to retry later");
            // start_new_try.attach(TEMPO_NEW_TRY, new_try);
        }
        else
        {
            Serial.println("[INIT] Connection to the internet router: OK");
            digitalWrite(BLE_STATUS_LED_PIN, LOW);
            digitalWrite(SOCKET_STATUS_LED_PIN, HIGH);

            Serial.println("=>Socket mode");

            NTPInit();
            updateCurrentDateTime();
            Serial.println("[INIT] NTP client (time): OK");

            websocketioInit();
            Serial.println("[INIT] WebSocketIo: OK");
        }
    }

    sensorsInit();
    //TODO: list sensors
    Serial.println("[INIT] Sensors: OK");

    Serial.printf("=============================\nSetup done\n=============================\n\n");
}

void loop()
{
    // If the flag to reset the module is up
    if (resetModuleFlag)
    {
        //Clear the SPIFFS memory then reboot
        resetSPIFFS();

        Serial.println("Reboot..");

        ESP.restart();
    }

    //BLE mode
    if (isBleON)
    {
        digitalWrite(BLE_STATUS_LED_PIN, HIGH);
        digitalWrite(SOCKET_STATUS_LED_PIN, LOW);

        if (!oldIsBleON)
            oldIsBleON = true;

        //disconnecting
        if (!isBLEConnected && oldIsBLEConnected)
        {
            Serial.println("BLE Disconnected");
            delay(500); // give the bluetooth stack the chance to get things ready
            // pServer->startAdvertising(); // restart advertising
            // Serial.println("start advertising");
            // oldIsBLEConnected = isBLEConnected;
            Serial.println("Reboot..");

            ESP.restart();
        }
        // connecting
        if (isBLEConnected && !oldIsBLEConnected)
        {
            // do stuff here on connecting
            Serial.println("BLE Connected");
            oldIsBLEConnected = isBLEConnected;
        }
    }
    //WebSocket mode
    else
    {
        //If it was in the BLE mode right before
        if (oldIsBleON)
        {
            oldIsBleON = false;

            //TODO: move to BLE callback when success
            String string2Store = routerSsid + "&" + routerPassword;
            writeFile(SPIFFS, ROUTER_IDS_FILE_PATH, string2Store.c_str());

            delay(3000);
            //Restart to initialize the WebSocket mode
            ESP.restart();

            // Serial.println("\t=> Socket mode");

            // NTPInit();

            // if (timeClient.update())
            // {
            //     currentDateTime = timeClient.getFormattedDate();
            //     Serial.println(currentDateTime);
            //     // res = true;
            // }

            // // Setup 'on' listen events
            // webSocket.on("connect", socket_Connected);
            // webSocket.on("event", socket_event);
            // webSocket.on("reply", messageEventHandler);
            // webSocket.begin(host, 8081, path);
            // Serial.println("Socket initialized");
            // /*****************Setup of the timer for measures*******************/
            // Serial.println("Timer in interruption for new measures (init): ");

            // startingDHT22MeasureTicker.attach(dhtMeasureTicker, raiseDHT22MeasureFlag);
            // delay(500);
        }

        //Check if there is someting to do with the WebSocket
        webSocket.loop();

        //If the flag for a new measure is up => sensors reading
        if (startingDHT22MeasureFlag)
        {
            startingDHT22MeasureTicker.detach(); //Disable interruption for new measures

            int res = sendDataSensors2Server();

            switch (res)
            {
            case 0:
                Serial.println("Data sent to the server with Success!");
                break;
            case 1:
                Serial.println("[ERROR] No internet connection: failed to send data sensors to the server! ");
                break;
            case 2:
                Serial.println("[ERROR] Failed to get the current time! ");
                break;
            case 3:
                //TODO: adapt for the specific sensor
                Serial.println("[ERROR] Failed to read DHT22 sensor!");
                break;
            default:
                Serial.println("[ERROR] Unkown error while sending data to the server!");
                break;
            }

            startingDHT22MeasureTicker.attach(dhtMeasureTicker, raiseDHT22MeasureFlag); //Enable interruption for new measures

            startingDHT22MeasureFlag = false; //Lower the flag
        }
    }
}

