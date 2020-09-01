#ifndef WEB_SOCKET_IO_H
#define WEB_SOCKET_IO_H

#include "headers.h"

extern char host[]; // Socket.IO Server Address
extern int port;    // Socket.IO Port Address
extern char path[]; // Socket.IO Base Path
extern SocketIoClient webSocket;

extern SocketIoClient webSocket;
void socket_Connected(const char *payload, size_t length);
void socket_event(const char *payload, size_t length);
void messageEventHandler(const char *payload, size_t length);
void websocketioInit(void);

#endif