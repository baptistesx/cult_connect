#include "spiffs_functions.h"

extern String routerSsid;
extern String routerPassword;

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
    deleteFile(SPIFFS, ROUTER_IDS_FILE_PATH);
}

int getRouterIdFromSPIFFS(void)
{
    String rawRouterIds = readFile(SPIFFS, ROUTER_IDS_FILE_PATH); // Format: ssid&password
    if (rawRouterIds.length() < 5)
    {
        if (rawRouterIds == "")
            deleteFile(SPIFFS, ROUTER_IDS_FILE_PATH);
        return 1;
    }
    else
    {
        parseRouterIds(rawRouterIds);
        return 2;
    }
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

void clearRouterIds()
{
    routerSsid = "";
    routerPassword = "";
}