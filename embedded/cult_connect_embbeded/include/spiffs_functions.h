#ifndef __SPIFF_FUNCTIONS_H_
#define __SPIFF_FUNCTIONS_H_

#include "main.h"

#include "SPIFFS.h"

#include "air_humidity_sensor.h"
#include "air_temperature_sensor.h"
#include "brightness_sensor.h"

// Path to the json configuration file into SPIFFS memory, from root directory
#define CONFIG_FILE_PATH_IN_SPIFFS "/config.json"

#define FORMAT_SPIFFS_IF_FAILED true

// List directory content
void listDir(fs::FS &fs, const char *dirname, uint8_t levels);

// Return the content of the file read or an empty String if error
String readFile(fs::FS &fs, const char *path);

// Write message in a file to the desired path
bool writeFile(fs::FS &fs, const char *path, const char *message);

// Clear internet router ids in the json config file
void resetSPIFFS(void);

// The router config is store in the SPIFFS memory CONFIG_FILE_PATH_IN_SPIFFS with json format
/* The configuration file is composed of:
        - routerSSID: internet router SSID
        - routerPassword: internet router Password
        - id: module id (same as in database)
        - privateId: module private id
        - resetButtonPin: reset button pin
        - bleStatusLedPin: BLE status Led indicator pin
        - socketStatusLedPin: Socket status Led indicator pin
        - nbSensors: number of differents module sensors
        - sensors: array of sensors with their infos

    The file is read and parsed in order to initialize the moduleConfig global instance
*/
int configureModule(void);

// Parse the config raw String and configure the moduleConfig global instance
int parseConfig(String rawConfig);

// Save router info into SPIFFS memory
int saveRouterInfoInSPIFFS(void);

#endif
