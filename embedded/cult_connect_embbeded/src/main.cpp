#include "main.h"

// Instances necessary to get time from a NTP server by UDP
WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP);

// WebsocketIO client instance to discuss with the server
SocketIoClient webSocket;

// Bluetooth LE instance
BleInstance bleInstance;

// Instance containing the module configuration
Config moduleConfig;

//First executed function when the module starts <=> initialisation
void setup()
{
    serialPortInit();
    Serial.printf("=============================\nStarting setup\n=============================\n\n");

    Serial.println("[INIT] Serial communication (" + String(SERIAL_SPEED) + " bauds, 8 data bits, no parity, 1 stop bit): OK");

    if (!SPIFFSInit())
    {
        //Init error case
        // The module configuration is stored into SPIFFS memory
        // if the SPIFFS fails to mount, the module cannot work properly
        printf("[INIT] SPIFFS: KO, SPIFFS Mount Failed -> Reboot...\n");
        ESP.restart();
    }
    Serial.println("[INIT] SPIFFS: OK");

    switch (configureModule())
    {
    case 0:
        Serial.println("[INIT] Module configuration from config.json file: OK");
        break;
    case 1:
        Serial.println("[ERROR] Module configuration from config.json file: KO, no config file found!");
        Serial.println("Reboot..");
        ESP.restart();
        break;
    case 2:
        Serial.println("[ERROR] Module configuration from config.json file: KO, error while parsing the config file!");
        Serial.println("Reboot..");
        ESP.restart();
        break;
    default:
        break;
    }

    statusLedsInit();
    Serial.println("[INIT] Status LEDs: OK");

    resetButtonInit();
    Serial.println("[INIT] Reset button on PIN " + String(moduleConfig.getResetButtonPin()) + " (press over 2s to reset): OK");

    if (moduleConfig.getRouterSSID() == "")
    {
        Serial.println("No internet router ids stored in memory");
        Serial.println("\t=> BLE mode");
        bleInstance.init();
        Serial.println("[INIT] BLE: OK");
    }
    else
    {
        if (!connection2InternetRouter(moduleConfig.getRouterSSID(), moduleConfig.getRouterPassword()))
        {
            Serial.println("[INIT] Connection to the internet router: KO");
            Serial.println("=> ssid: " + moduleConfig.getRouterSSID() + " & password: " + moduleConfig.getRouterPassword());

            //TODO: implement some retry if the connection failed
            // Serial.println("\tTimer configuration to retry later");
            // start_new_try.attach(TEMPO_NEW_TRY, new_try);
        }
        else
        {
            Serial.println("[INIT] Connection to the internet router: OK");
            digitalWrite(moduleConfig.getBleStatusLedPin(), LOW);
            digitalWrite(moduleConfig.getSocketStatusLedPin(), HIGH);

            Serial.println("=>Socket mode");

            NTPInit();
            Serial.println("[INIT] NTP client (time): OK");

            websocketioInit();
            Serial.println("[INIT] WebSocketIo: OK");

            startSensorsTimers();

            Serial.println("[INIT] Sensors: OK");
        }
    }

    Serial.printf("=============================\nSetup done\n=============================\n\n");
}

void loop()
{
    // If the flag to reset the module is up
    if (moduleConfig.getResetModuleFlag())
    {
        //Clear the SPIFFS memory then reboot
        Serial.println("reset spiff");
        // Will clear the internet router ids, the reboot and start BLE mode
        resetSPIFFS();
        Serial.println("Reboot......");
        delay(2000);
        ESP.restart();
    }

    //BLE mode
    if (bleInstance.getIsBleOn())
    {
        digitalWrite(moduleConfig.getSocketStatusLedPin(), LOW);
        digitalWrite(moduleConfig.getBleStatusLedPin(), HIGH);

        if (!bleInstance.getOldIsBleOn())
            bleInstance.setOldIsBleOn(true);

        //disconnecting
        if (!bleInstance.getIsBleConnected() && bleInstance.getOldIsBleConnected())
        {
            Serial.println("BLE Disconnected");
            delay(500); // give the bluetooth stack the chance to get things ready

            Serial.println("Reboot...");

            ESP.restart();
        }
        // connecting
        if (bleInstance.getIsBleConnected() && !bleInstance.getOldIsBleConnected())
        {
            // do stuff here on connecting
            bleInstance.setOldIsBleConnected(bleInstance.getIsBleConnected());
        }
    }
    //WebSocket mode
    else
    {
        //If it was in the BLE mode right before
        if (bleInstance.getOldIsBleOn())
        {
            bleInstance.setOldIsBleOn(false);

            delay(3000);
            //Restart to initialize the WebSocket mode
            Serial.println("Reboot...\n");
            Serial.println(readFile(SPIFFS, CONFIG_FILE_PATH_IN_SPIFFS));
            delay(3000);
            ESP.restart();
        }

        // Check if sensors measure ticker is up
        for (int i = 0; i < moduleConfig.getNbSensors(); i++)
        {
            moduleConfig.sensors[i]->update();
        }

        //Check if there is someting to do with the WebSocket
        webSocket.loop();
    }
}
