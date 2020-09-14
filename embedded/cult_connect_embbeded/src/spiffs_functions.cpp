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

void resetSPIFFS()
{
    // Instanciate a json document and fill it with the moduleConfig info
    // and with empty internet router ids
    // TODO: Recheck capacity
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
        JsonObject sensor = sensors.createNestedObject();

        sensor["id"] = moduleConfig.sensors[i]->getId();
        sensor["type"] = moduleConfig.sensors[i]->getType();
        sensor["intervalMeasure"] = moduleConfig.sensors[i]->getMeasureInterval();

        if (String(moduleConfig.sensors[i]->getType()) == "temperature")
        {
            sensor["pin"] = moduleConfig.sensors[i]->getDhtPin();
            sensor["dhtType"] = moduleConfig.sensors[i]->getDhtType();
        }
    }

    // Open the json file stored in SPIFFS memory
    File file = SPIFFS.open(CONFIG_FILE_PATH_IN_SPIFFS, FILE_WRITE);

    // Serialize JSON to file
    if (serializeJson(doc, file) == 0)
        Serial.println(F("[ERROR] Failed to write to file"));
}

int configureModule(void)
{
    // Read json configuration file
    String rawConfig = readFile(SPIFFS, CONFIG_FILE_PATH_IN_SPIFFS);
    if (rawConfig == "")
        // Error case
        return 1;
    else // If no error while reading the file, parse the result
        return parseConfig(rawConfig);
}

int saveRouterInfoInSPIFFS(void)
{
    File file = SPIFFS.open(CONFIG_FILE_PATH_IN_SPIFFS, FILE_WRITE);

    // TODO: check capacity
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
        JsonObject sensor = sensors.createNestedObject();

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

int parseConfig(String config)
{
    // TODO: Recheck capacity
    const size_t capacity = JSON_ARRAY_SIZE(2) + JSON_OBJECT_SIZE(3) + JSON_OBJECT_SIZE(5) + JSON_OBJECT_SIZE(9) + 310;
    DynamicJsonDocument doc(capacity);
    // StaticJsonDocument<N> allocates memory on the stack, it can be
    // replaced by DynamicJsonDocument which allocates in the heap.
    //
    // DynamicJsonDocument doc(200);

    // Using a char[], as shown here, enables the "zero-copy" mode. This mode uses
    // the minimal amount of memory because the JsonDocument stores pointers to
    // the input buffer.
    // If you use another type of input, ArduinoJson must copy the strings from
    // the input to the JsonDocument, so you need to increase the capacity of the
    // JsonDocument.

    // The input needs to be a char* => cast from String to char*
    // +1 for EOL
    int configLength = config.length() + 1;
    char json[configLength];
    config.toCharArray(json, configLength);

    // Deserialize the JSON document
    DeserializationError error = deserializeJson(doc, json);

    // Test if parsing succeeds.
    if (error)
    {
        // Error case
        Serial.print(F("[ERROR] DeserializeJson() failed: "));
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

    // Fetch the nested sensors
    for (int i = 0; i < moduleConfig.getNbSensors(); i++)
    {
        JsonObject sensor = doc["sensors"][i];
        const char *sensorType = sensor["type"];
        const char *sensorId = sensor["id"];
        int sensorIntervalMeasure = sensor["intervalMeasure"];

        // Fetch specific sensors infos for each sensor
        if (String(sensorType) == "temperature")
        {
            int sensorPin = sensor["pin"];
            int sensorDhtType = sensor["dhtType"];

            // Instanciate a new sensor and add it to the moduleConfig "sensors" vector
            moduleConfig.sensors.push_back(new AirTemperatureSensor(sensorDhtType, sensorPin, String(sensorId), String(sensorType), sensorIntervalMeasure));
        }
        if (String(sensorType) == "luminosity")
        {
            // Instanciate a new sensor and add it to the moduleConfig "sensors" vector
            moduleConfig.sensors.push_back(new BrightnessSensor(sensor["id"].as<String>(), sensor["type"].as<String>(), sensor["intervalMeasure"]));
        }
    }

    // Configuration well done
    return 0;
}