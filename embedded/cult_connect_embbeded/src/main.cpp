#include "main.h"
#include <vector>

/***** BLE global variables *****/
// BLECharacteristic *pCharacteristic = NULL;
// BLEServer *pServer = NULL;

// // BLE module state
// bool isBleON = false;

// // Previous BLE module state
// bool oldIsBleON = false;

// // BLE module connection state
// bool isBLEConnected = false;

// // BLE module connection previous state
// bool oldIsBLEConnected = false;

// // Value received by the paired device
// std::string rawBLEValueReceived = "0";

// Value notified by the module over BLE
// uint32_t valToNotifyBLE = 0;

// Previous value notified by the module over BLE
// uint32_t oldValToNotifyBLE = 0;

/***** Internet global variables *****/
// Internet router SSID
// String routerSsid = "";

// Internet router password
// String routerPassword = "";

WiFiUDP ntpUDP;
NTPClient timeClient(ntpUDP);

/***** Various global variables *****/

// String MODULE_PRIVATE_ID = "";
// String MODULE_NAME = "";

// When this flag is high => reset SPIFFS memory and reboot
// bool resetModuleFlag = false;

// The last time the output pin was toggled
// unsigned long lastDebounceTime = 0;

/***** Monitoring global variables *****/
//Sensor DHT22 object (humidity and temperature sensor)
// DHT humidityTemperatureSensor(4, DHTTYPE);
// bool startingHumidityTemperatureMeasureFlag = false;
// bool startingBrightnessMeasureFlag = false;
// String sensors[NUMBER_OF_MODULE_SENSORS];
//TODO: check
// Ticker startingHumidityTemperatureMeasureTicker;
// Ticker startingBrightnessMeasureTicker;

// int humidityTemperatureMeasureTickerDelay = 10;
// int brightnessMeasureTickerDelay = 20;
// Adafruit_TSL2561_Unified brightnessSensor = Adafruit_TSL2561_Unified(TSL2561_ADDR_FLOAT, 12345);

/***** Websocketsio global variables *****/

SocketIoClient webSocket;
BleInstance bleInstance;
Config moduleConfig;
//First executed function when the module starts <=> initialisation
void setup()
{
    serialPortInit();
    Serial.printf("=============================\nStarting setup\n=============================\n\n");

    Serial.println("[INIT] Serial communication (" + String(SERIAL_SPEED) + " bauds, 8 data bits, no parity, 1 stop bit): OK");

    if (!SPIFFSInit()) //Init error case
    {
        printf("[INIT] SPIFFS: KO, SPIFFS Mount Failed -> Reboot...\n");

        ESP.restart();
    }
    Serial.println("[INIT] SPIFFS: OK");

    int res = readConfigFileFromSPIFFS();
    Serial.println(readFile(SPIFFS, CONFIG_FILE_PATH_IN_SPIFFS));
    switch (res)
    {
    case 0:
        Serial.println("[INIT] Module configuration from config.json file: OK");
        Serial.println(moduleConfig.toString());
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
        // BLEInit();
        Serial.println("[INIT] BLE: OK");
    }
    else
    {

        if (!connection2InternetRouter(moduleConfig.getRouterSSID(), moduleConfig.getRouterPassword()))
        {
            Serial.println("[INIT] Connection to the internet router: KO");
            Serial.println("=> ssid: " + moduleConfig.getRouterSSID() + " & password: " + moduleConfig.getRouterPassword());

            //TODO: todo
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

            sensorsInit();
            //TODO: list sensors
            Serial.println("[INIT] Sensors: OK");
        }
    }

    Serial.printf("=============================\nSetup done\n=============================\n\n");
}

void loop()
{
    for (int i = 0; i < moduleConfig.getNbSensors(); i++)
    {
        moduleConfig.sensors[i]->update();
    }
    // If the flag to reset the module is up
    if (moduleConfig.getResetModuleFlag())
    {
        //Clear the SPIFFS memory then reboot
        Serial.println("reset spiff");
        resetSPIFFS();
        Serial.println("Reboot......");
        Serial.println(readFile(SPIFFS, CONFIG_FILE_PATH_IN_SPIFFS));
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
            // pServer->startAdvertising(); // restart advertising
            // Serial.println("start advertising");
            // oldIsBLEConnected = isBLEConnected;
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

        //Check if there is someting to do with the WebSocket
        webSocket.loop();

        //If the flag for a new measure is up => sensors reading
        // if (startingHumidityTemperatureMeasureFlag)
        // {
        //     //TODO: check
        //     // startingHumidityTemperatureMeasureTicker.detach(); //Disable interruption for new measures

        //     int res = sendSensorsData2Server(1);

        //     switch (res)
        //     {
        //     case 0:
        //         Serial.println("Data sent to the server with Success!");
        //         break;
        //     case 1:
        //         Serial.println("[ERROR] No internet connection: failed to send data sensors to the server! ");
        //         break;
        //     case 2:
        //         Serial.println("[ERROR] Failed to get the current time! ");
        //         break;
        //     case 3:
        //         //TODO: adapt for the specific sensor
        //         Serial.println("[ERROR] Failed to read DHT22 sensor!");
        //         break;
        //     case 4:
        //         Serial.println("[ERROR] Unknown sensor!");
        //         break;
        //     default:
        //         Serial.println("[ERROR] Unkown error while sending data to the server!");
        //         break;
        //     }
        //     //TODO: check

        //     // startingHumidityTemperatureMeasureTicker.attach(humidityTemperatureMeasureTickerDelay, raiseHumidityTemperatureMeasureFlag); //Enable interruption for new measures

        //     startingHumidityTemperatureMeasureFlag = false; //Lower the flag
        // }

        // if (startingBrightnessMeasureFlag)
        // {
        //     //TODO: check
        //     // startingBrightnessMeasureTicker.detach(); //Disable interruption for new measures

        //     int res = sendSensorsData2Server(2);

        //     switch (res)
        //     {
        //     case 0:
        //         Serial.println("Data sent to the server with Success!");
        //         break;
        //     case 1:
        //         Serial.println("[ERROR] No internet connection: failed to send data sensors to the server! ");
        //         break;
        //     case 2:
        //         Serial.println("[ERROR] Failed to get the current time! ");
        //         break;
        //     case 3:
        //         //TODO: adapt for the specific sensor
        //         Serial.println("[ERROR] Failed to read TSL2561 sensor!");
        //         break;
        //     default:
        //         Serial.println("[ERROR] Unkown error while sending data to the server!");
        //         break;
        //     }

        //     //TODO: check
        //     // startingBrightnessMeasureTicker.attach(brightnessMeasureTickerDelay, raiseBrightnessMeasureFlag); //Enable interruption for new measures

        //     startingBrightnessMeasureFlag = false; //Lower the flag
        // }
    }
}
