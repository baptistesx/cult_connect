CULT'CONNECT

The goal of this code (embbeded on ESP32) is to send sensors data to an online server.

A json file is loaded into SPIFFS memory. This file contains the configuration of the module.

The configuration file is composed of:
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

Two running mode for the module (package: ESP32 + sensors) are available following the presence or not of routerSSID and routerPassword int the config.json file.

- router ids not present:
    => instanciation of a BLE (Bluetooth Low Energy) server waiting for router ids from the mobile app

- router ids present:
    => connection to the internet router
    => instanciation of the sensors following the config file
    => instanciation of websocketsIO
    => reading sensors periodically and sending data to the server


Questions:

- Comment organiser les repertoires du projet?

- Comment gérer les dépendances exterieures?