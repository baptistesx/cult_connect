#include "sensors/sensor.h"
#include "config.h"
#include "connectivity.h"

Sensor::Sensor(String id, String type, uint32_t timer, uint32_t repeat, resolution_t resolution)
{
    // Initialize the sensors ticker
    this->resolution = resolution;
    if (resolution == MICROS)
        timer = timer * 1000000;

    this->timer = timer*1000;
    this->repeat = repeat;
    enabled = false;
    lastTime = 0;
    counts = 0;

    this->type = type;
    this->id = id;
}

Sensor::~Sensor() {}

String Sensor::getId(void) { return this->id; }

void Sensor::setISR(void) { this->start(); }

uint32_t Sensor::getMeasureInterval(void)
{
    return this->timer;
}

String Sensor::getType(void) { return this->type; }

void Sensor::setType(String type) { this->type = type; }

void Sensor::start()
{
    Serial.println("isr started");
    if (resolution == MILLIS)
        lastTime = millis();
    else
        lastTime = micros();
    enabled = true;
    counts = 0;
    status = RUNNING;
}

void Sensor::resume()
{
    if (resolution == MILLIS)
        lastTime = millis() - diffTime;
    else
        lastTime = micros() - diffTime;
    if (status == STOPPED)
        counts = 0;
    enabled = true;
    status = RUNNING;
}

void Sensor::stop()
{
    enabled = false;
    counts = 0;
    status = STOPPED;
}

void Sensor::pause()
{
    if (resolution == MILLIS)
        diffTime = millis() - lastTime;
    else
        diffTime = micros() - lastTime;
    enabled = false;
    status = PAUSED;
}

int Sensor::sendSensorData2Server()
{
    if (isInternetConnected())
    {
        if (timeClient.update())
        {
            float value = this->getMeasure();

            if (value != -1)
            {
                String dataToSend = "\"{'moduleId': '" + moduleConfig.getId() + "', 'sensorId': '" + this->getId() + "', 'data' : {'date' : '" + timeClient.getFormattedDate() + "', 'value' : " + String(value) + "}}\"";
                Serial.println(dataToSend);
                webSocket.emit("newDataFromModule", dataToSend.c_str());

                return 0;
            }
            else
                return 3;
        }
        else
            return 2;
    }
    else
        return 1;
}

void Sensor::update()
{
    if (tick())
    {
        int res = this->sendSensorData2Server();

        switch (res)
        {
        case 0:
            Serial.println("Data sent to the server with Success!");
            break;
        case 1:
            Serial.println("[ERROR] No internet connection: failed to send data sensors to the server! ");
            break;
        case 2:
            Serial.println("[ERROR] Failed to get the current time! ");
            break;
        case 3:
            Serial.println("[ERROR] Failed to read " + this->getType() + " sensor!");
            break;
        case 4:
            Serial.println("[ERROR] Unknown sensor!");
            break;
        default:
            Serial.println("[ERROR] Unkown error while sending data to the server!");
            break;
        }
    }
}

bool Sensor::tick()
{
    if (!enabled)
        return false;
    if (resolution == MILLIS)
    {
        if ((millis() - lastTime) >= timer)
        {
            lastTime = millis();
            if (repeat - counts == 1)
                enabled = false;
            counts++;
            return true;
        }
    }
    else
    {
        if ((micros() - lastTime) >= timer)
        {
            lastTime = micros();
            if (repeat - counts == 1)
                enabled = false;
            counts++;
            return true;
        }
    }
    return false;
}

void Sensor::interval(uint32_t timer)
{
    // timer is received in seconds
    if (resolution == MICROS)
        timer = timer * 1000000;
    this->timer = timer*1000;
}

uint32_t Sensor::elapsed()
{
    if (resolution == MILLIS)
        return millis() - lastTime;
    else
        return micros() - lastTime;
}

status_t Sensor::state()
{
    return status;
}

uint32_t Sensor::counter()
{
    return counts;
}







