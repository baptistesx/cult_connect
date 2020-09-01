#include "web_socket_io.h"

char host[] = "Baptiste-PC";                     // Socket.IO Server Address
int port = 8081;                                 // Socket.IO Port Address
char path[] = "/socket.io/?transport=websocket"; // Socket.IO Base Path
SocketIoClient webSocket;

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

void websocketioInit(void)
{
    // Setup 'on' listen events
    webSocket.on("connect", socket_Connected);
    webSocket.on("event", socket_event);
    webSocket.on("reply", messageEventHandler);
    webSocket.begin(host, 8081, path);
}