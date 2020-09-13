#ifndef __SPIFF_FUNCTIONS_H_
#define __SPIFF_FUNCTIONS_H_

#include "main.h"

#include "SPIFFS.h"

#define ROUTER_IDS_FILE_PATH_IN_SPIFFS "/router_ids"
#define CONFIG_FILE_PATH_IN_SPIFFS "/config.json"

#define FORMAT_SPIFFS_IF_FAILED true

void listDir(fs::FS &fs, const char *dirname, uint8_t levels);
String readFile(fs::FS &fs, const char *path);
bool writeFile(fs::FS &fs, const char *path, const char *message);
void appendFile(fs::FS &fs, const char *path, const char *message);
void renameFile(fs::FS &fs, const char *path1, const char *path2);
void deleteFile(fs::FS &fs, const char *path);
void testFileIO(fs::FS &fs, const char *path);
void resetSPIFFS(void);
int readRouterIdsFile(String *routerSsid, String *routerPassword);
void parseRouterIds(String rawIds, String *routerSsid, String *routerPassword);
int readConfigFileFromSPIFFS(void);
int parseConfig(String rawConfig);

#endif
