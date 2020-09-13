#include "spiffs_functions.h"

void listDir(fs::FS &fs, const char *dirname, uint8_t levels)
{
    Serial.print(String("Listing directory: " + String(dirname) + "\r\n"));

    File root = fs.open(dirname);
    if (!root)
    {
        Serial.printf("- failed to open directory\n");
        return;
    }
    if (!root.isDirectory())
    {
        Serial.printf(" - not a directory\n");
        return;
    }

    File file = root.openNextFile();
    while (file)
    {
        if (file.isDirectory())
        {
            Serial.print(String("  DIR : " + String(file.name())));

            if (levels)
                listDir(fs, file.name(), levels - 1);
        }
        else
            Serial.print(String("  FILE: " + String(file.name()) + "\t\tSIZE: " + String(file.size()) + "\n"));

        file = root.openNextFile();
    }
}

String readFile(fs::FS &fs, const char *path)
{
    File file = fs.open(path);
    if (!file || file.isDirectory())

        return "";

    String readString;
    while (file.available())
    {
        readString += (char)file.read();
    }
    return readString;
}

bool writeFile(fs::FS &fs, const char *path, const char *message)
{
    File file = fs.open(path, FILE_WRITE);
    if (!file)
        return false;
    if (file.print(message))
    {
        file.flush();
        return true;
    }
    else
        return false;
}

// void appendFile(fs::FS &fs, const char * path, const char * message){
//    Serial.printf("Appending to file: %s\r\n", path);
//    File file = fs.open(path, FILE_APPEND);
//    if(!file){
//        Serial.println("- failed to open file for appending");
//        return;
//    }
//    if(file.print(message)){
//        Serial.println("- message appended");
//    } else {
//        Serial.println("- append failed");
//    }
// }

void renameFile(fs::FS &fs, const char *path1, const char *path2)
{
    Serial.printf("Renaming file %s to %s\r\n", path1, path2);

    if (fs.rename(path1, path2))
        Serial.println("- file renamed");
    else
        Serial.println("- rename failed");
}

void deleteFile(fs::FS &fs, const char *path)
{
    Serial.printf("Deleting file: %s\r\n", path);
    if (fs.remove(path))
    {
        Serial.println("- file deleted");
    }
    else
    {
        Serial.println("- delete failed");
    }
}

void testFileIO(fs::FS &fs, const char *path)
{
    Serial.printf("Testing file I/O with %s\r\n", path);

    static uint8_t buf[512];
    size_t len = 0;
    File file = fs.open(path, FILE_WRITE);
    if (!file)
    {
        Serial.println("- failed to open file for writing");
        return;
    }

    size_t i;
    Serial.print("- writing");
    uint32_t start = millis();
    for (i = 0; i < 2048; i++)
    {
        if ((i & 0x001F) == 0x001F)
        {
            Serial.print(".");
        }
        file.write(buf, 512);
    }
    Serial.println("");
    uint32_t end = millis() - start;
    Serial.printf(" - %u bytes written in %u ms\r\n", 2048 * 512, end);
    file.close();

    file = fs.open(path);
    start = millis();
    end = start;
    i = 0;
    if (file && !file.isDirectory())
    {
        len = file.size();
        size_t flen = len;
        start = millis();
        Serial.print("- reading");
        while (len)
        {
            size_t toRead = len;
            if (toRead > 512)
            {
                toRead = 512;
            }
            file.read(buf, toRead);
            if ((i++ & 0x001F) == 0x001F)
            {
                Serial.print(".");
            }
            len -= toRead;
        }
        Serial.println("");
        end = millis() - start;
        Serial.printf("- %u bytes read in %u ms\r\n", flen, end);
        file.close();
    }
    else
    {
        Serial.println("- failed to open file for reading");
    }
}

void resetSPIFFS()
{
    File file = SPIFFS.open(CONFIG_FILE_PATH_IN_SPIFFS, FILE_WRITE);

    const size_t capacity = JSON_ARRAY_SIZE(2) + JSON_OBJECT_SIZE(3) + JSON_OBJECT_SIZE(5) + JSON_OBJECT_SIZE(9);
    DynamicJsonDocument doc(3000);

    doc["routerSSID"] = "";
    doc["routerPassword"] = "";
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
}
// }

// The internet router ids are store in ROUTER_IDS_FILE_PATH_IN_SPIFFS
int readRouterIdsFile(String *routerSsid, String *routerPassword)
{
    String rawRouterIds = readFile(SPIFFS, ROUTER_IDS_FILE_PATH_IN_SPIFFS); // Format: ssid&password
    if (rawRouterIds.length() < 5)
    {
        if (rawRouterIds == "")
            deleteFile(SPIFFS, ROUTER_IDS_FILE_PATH_IN_SPIFFS);
        return 1;
    }
    else
    {
        parseRouterIds(rawRouterIds, routerSsid, routerPassword);
        return 2;
    }
}

void parseRouterIds(String rawIds, String *routerSsid, String *routerPassword)
{
    bool isSsid = true;

    // clearRouterIds();

    for (int i = 0; i < rawIds.length(); i++)
    {
        if (rawIds[i] == '&')
            isSsid = false;
        else
        {
            if (isSsid)
                *routerSsid += rawIds[i];
            else
                *routerPassword += rawIds[i];
        }
    }
}

// The router config is store in the SPIFFS memory CONFIG_FILE_PATH_IN_SPIFFS
// The config is composed of the MODULE_NAME and the different sensors/actuators the module owns
int readConfigFileFromSPIFFS(void)
{
    String rawConfig = readFile(SPIFFS, CONFIG_FILE_PATH_IN_SPIFFS); // Format: json
    if (rawConfig.length() < 5)
        return 1;
    else
        return parseConfig(rawConfig);
}

int parseConfig(String config)
{
    const size_t capacity = JSON_ARRAY_SIZE(2) + JSON_OBJECT_SIZE(3) + JSON_OBJECT_SIZE(5) + JSON_OBJECT_SIZE(9) + 310;
    DynamicJsonDocument doc(capacity);
    // const char *json = "{\"routerSSID\":\"Martin Router King\",\"routerPassword\":\"phelmaRPZ204\",\"id\":\"5e7a80125d33fe0d041ff8cb\",\"privateId\":\"123\",\"resetButtonPin\":32,\"bleStatusLedPin\":13,\"socketStatusLedPin\":12,\"nbSensors\":2,\"sensors\":[{\"id\":\"5e81197a68819b45fce01000\",\"type\":\"temperature\",\"pin\":4,\"dhtType\":22,\"intervalMeasure\":5000},{\"id\":\"5f4ec59b1f305e32f8f3e519\",\"type\":\"luminosity\",\"intervalMeasure\":10000}]}";
    // StaticJsonDocument<N> allocates memory on the stack, it can be
    // replaced by DynamicJsonDocument which allocates in the heap.
    //
    // DynamicJsonDocument doc(200);

    // JSON input string.
    //
    // Using a char[], as shown here, enables the "zero-copy" mode. This mode uses
    // the minimal amount of memory because the JsonDocument stores pointers to
    // the input buffer.
    // If you use another type of input, ArduinoJson must copy the strings from
    // the input to the JsonDocument, so you need to increase the capacity of the
    // JsonDocument.
    /////////
    int config_len = config.length() + 1;
    char json[config_len];
    config.toCharArray(json, config_len);
    /////////
    // Deserialize the JSON document
    DeserializationError error = deserializeJson(doc, json);

    // Test if parsing succeeds.
    if (error)
    {
        Serial.print(F("deserializeJson() failed: "));
        Serial.println(error.c_str());
        return 2;
    }

    // Fetch values.
    //
    // Most of the time, you can rely on the implicit casts.
    // In other case, you can do doc["time"].as<long>();
    moduleConfig.setRouterInfo(doc["routerSSID"], doc["routerPassword"]);
    moduleConfig.setModuleInfo(doc["id"], doc["privateId"]);
    moduleConfig.setResetButtonPin(doc["resetButtonPin"]);
    moduleConfig.setBleStatusLedPin(doc["bleStatusLedPin"]);
    moduleConfig.setSocketStatusLedPin(doc["socketStatusLedPin"]);
    moduleConfig.setSensorsSize(doc["nbSensors"]);

    JsonObject sensors_0 = doc["sensors"][0];
    const char *sensors_0_id = sensors_0["id"];                   // "5e81197a68819b45fce01000"
    const char *sensors_0_type = sensors_0["type"];               // "temperature"
    int sensors_0_pin = sensors_0["pin"];                         // 4
    int sensors_0_dhtType = sensors_0["dhtType"];                 // 22
    int sensors_0_intervalMeasure = sensors_0["intervalMeasure"]; // 5000

    for (int i = 0; i < moduleConfig.getNbSensors(); i++)
    {
        JsonObject sensor = doc["sensors"][i];
        const char *sensor_type = sensor["type"];               // "temperature"
        const char *sensor_id = sensor["id"];                   // "5e81197a68819b45fce01000"
        int sensor_intervalMeasure = sensor["intervalMeasure"]; // 5000

        if (String(sensor_type) == "temperature")
        {
            int sensor_pin = sensor["pin"];         // 4
            int sensor_dhtType = sensor["dhtType"]; // 22

            Serial.println("temperature sensor");
            moduleConfig.sensors.push_back(new AirTemperatureSensor(sensor_dhtType, sensor_pin, String(sensor_id), String(sensor_type), sensor_intervalMeasure));
        }
        if (String(sensor_type) == "luminosity")
        {
            Serial.println("luminosity sensor");

            moduleConfig.sensors.push_back(new BrightnessSensor(sensor["id"].as<String>(), sensor["type"].as<String>(), sensor["intervalMeasure"]));
        }
    }
    return 0;
}