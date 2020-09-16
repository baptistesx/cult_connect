#include "web_socket_io.h"

void socketConnected(const char *payload, size_t length)
{
    Serial.println("Socket.IO Connected!");
    String tempId = "\"";
    tempId += String(moduleConfig.getName());
    tempId += "\"";

    uint32_t tempId_len = tempId.length() + 1;
    char id[tempId_len];
    tempId.toCharArray(id, tempId_len);

    webSocket.emit("identification", id);
}

void socketEvent(const char *payload, size_t length)
{
    Serial.print("got message: ");
    Serial.println(payload);
}

void messageEventHandler(const char *payload, size_t length)
{
    Serial.printf("got message: %s\n", payload);
}
