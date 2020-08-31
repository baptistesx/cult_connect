#include "spiff_functions.h"

//SPIFF use only to store the access point web page configuration
//the next function are not used anymore (for now)
//If used review them

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
    Serial.printf("Reading file: %s\r\n", path);

    File file = fs.open(path);
    if (!file || file.isDirectory())
    {
        Serial.println("- failed to open file for reading");
        return "";
    }

    Serial.println("- read from file:");
    String readString;
    while (file.available())
    {
        // Serial.write(file.read());
        readString += (char)file.read();
    }

    return readString;
}

void writeFile(fs::FS &fs, const char *path, const char *message)
{
    Serial.printf("Writing file: %s\r\n", path);

    File file = fs.open(path, FILE_WRITE);
    if (!file)
    {
        Serial.println("- failed to open file for writing");
        return;
    }
    if (file.print(message))
    {
        Serial.println("- file written");
    }
    else
    {
        Serial.println("- frite failed");
    }
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
