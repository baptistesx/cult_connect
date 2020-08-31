#include <Arduino.h>
#include "initialisation.h"
#include <string.h>
#include "SocketIoClient.h"
SocketIoClient webSocket;
#include <HTTPClient.h>

bool oldIsBleON = false;
bool isBleON = false;
/// Socket.IO Settings ///
char host[] = "Baptiste-PC";                     // Socket.IO Server Address
int port = 8081;                                 // Socket.IO Port Address
char path[] = "/socket.io/?transport=websocket"; // Socket.IO Base Path
bool useSSL = false;                             // Use SSL Authentication
const char *sslFingerprint = "";                 // SSL Certificate Fingerprint
bool useAuth = false;                            // use Socket.IO Authentication
int year = 2000;
void clearRouterIds()
{
    routerSsid = "";
    routerPassword = "";
}

void parseRouterIds(String rawIds)
{
    bool isSsid = true;

    clearRouterIds();

    for (int i = 0; i < rawIds.length(); i++)
    {
        if (rawIds[i] == '&')
            isSsid = false;
        else
        {
            if (isSsid)
                routerSsid += rawIds[i];
            else
                routerPassword += rawIds[i];
        }
    }
}
void socket_Connected(const char *payload, size_t length)
{
    Serial.println("Socket.IO Connected!");
    char *id = "\"MODULE_5e7a80125d33fe0d041ff8cb\"";
    webSocket.emit("identification", id);
}

void socket_event(const char *payload, size_t length)
{
    Serial.print("got message: ");
    Serial.println(payload);
}
void messageEventHandler(const char *payload, size_t length)
{
    Serial.printf("got message: %s\n", payload);
}
void setup()
{
    serial_port_init();

    if (!SPIFF_init()) //Init error case
    {
        printf("SPIFFS Mount Failed -> Reboot...\n");

        ESP.restart();
    }

    writeFile(SPIFFS, "/router_ids", "SFR_89B8&58baqh5jkg88xtvx7cih");

    String rawRouterIds = readFile(SPIFFS, "/router_ids");

    if (rawRouterIds == "")
    {
        Serial.println("No router Ids in memory => BLE mode");
        ble_init();
    }
    else
    {
        parseRouterIds(rawRouterIds);

        if (!connection_to_internet_router())
        {
            String s = "\nUnable to connect to the internet router\n";
            s += "Timer config to retry later...\n";
            Serial.printf("%s", s.c_str());

            // start_new_try.attach(TEMPO_NEW_TRY, new_try);
        }

        if (is_internet_connected())
        {
            init_NTP();

            if (timeClient.update())
            {
                formattedDate = timeClient.getFormattedDate();
                Serial.println(formattedDate);
                // res = true;
            }

            // Setup 'on' listen events
            webSocket.on("connect", socket_Connected);
            webSocket.on("event", socket_event);
            webSocket.on("reply", messageEventHandler);
            webSocket.begin(host, 8081, path);
        }
    }

    Serial.println("setup done");
}
int i;
uint64_t messageTimestamp;
void loop()
{
    if (isBleON)
    { //disconnecting
        if (oldIsBleON == false)
        {
            String stringToStore = routerSsid + "&" + routerPassword;
            writeFile(SPIFFS, "/router_ids", stringToStore.c_str());
            oldIsBleON = true;
        }
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
    }
    else
    {
        webSocket.loop();
        uint64_t now = millis();
        if (now - messageTimestamp > 4000)
        {
            messageTimestamp = now;

            year += 1;
            float value = random(0, 50) / 100.0;

            String dataToSend = "\"{'moduleId': '5e7a80125d33fe0d041ff8cb', 'sensorId': '5e81197a68819b45fce01000', 'data' : [ {'date' : '" + String(year) + "-04-03T21:00:00.000+00:00', 'value' : " + String(value) + "} ]}\"";
            webSocket.emit("newDataFromModule", dataToSend.c_str());
        }
    }
}