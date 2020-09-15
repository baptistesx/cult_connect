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


Recommandations de paul:

- Il faut proscrire des noms de variable globales qui serait réutilisées pour des variables locales ou des paramètres (je pense notamment à pCharacteristic utilisée en variable globale et en paramètres)

- mettre les déclarations de fonctions dans le meme ordre que dans le.h

- Après il faut limiter au plus que possible les variables globales qui sont dépendantes d'une instance de classe, genre est-ce que deviceConnected ne pourrait pas être plutôt un membre de MyServerCallbacks ? (peut-être que c'est pas possible ?)

- De même si tes variables locales n'ont qu'une portée sur ce fichier (ce qui est le cas) il est bon d'ajouter le mot clé static devant les variables pour limiter leur visibilité

- Evite les noms :
```
std::string value = "0";
std::string old_value = "0";
```
qui sont beaucoup trop génériques pour des variables globales

- gestion cas d'erreur

- voir: https://www.ssi.gouv.fr/uploads/2020/05/anssi-guide-regles_de_programmation_pour_le_developpement_securise_de_logiciels_en_langage_c-v1.2.pdf