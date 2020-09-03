#ifndef SPIFF_FUNCTIONS_H_
#define SPIFF_FUNCTIONS_H_

#include "FS.h"
#include "SPIFFS.h"
#include <ArduinoJson.h>
// #include "connectivity.h"

#define ROUTER_IDS_FILE_PATH "/router_ids"
#define CONFIG_FILE_PATH "/config.json"

#define FORMAT_SPIFFS_IF_FAILED true

void listDir(fs::FS &fs, const char * dirname, uint8_t levels);
String readFile(fs::FS &fs, const char * path);
bool writeFile(fs::FS &fs, const char * path, const char * message);
void appendFile(fs::FS &fs, const char * path, const char * message);
void renameFile(fs::FS &fs, const char * path1, const char * path2);
void deleteFile(fs::FS &fs, const char * path);
void testFileIO(fs::FS &fs, const char * path);
void resetSPIFFS();
int getRouterIdFromSPIFFS(void);
void parseRouterIds(String rawIds);
void clearRouterIds(void);
int readConfigFile(void);
int parseConfigFile(String rawConfig);

#endif
