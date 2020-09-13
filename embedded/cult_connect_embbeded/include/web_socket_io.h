#ifndef __WEB_SOCKET_IO_H_
#define __WEB_SOCKET_IO_H_

#include "main.h"

void socketConnected(const char *payload, size_t length);
void socketEvent(const char *payload, size_t length);
void messageEventHandler(const char *payload, size_t length);

#endif