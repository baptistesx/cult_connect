// routes sensor

const express = require("express");
const router = express.Router()
const sensorCtrl = require("../../controllers/sensor")

//Mise à jour du mode automatic de l'actionneur
router.post("/updateSensorAutomaticMode", sensorCtrl.updateSensorAutomaticMode)

//Mise à jour de la config d'un sensorData
router.post("/updateSensorDataConfig", sensorCtrl.updateSensorDataConfig);

//Route pour mise à jour d'un capteur d'id reçu en paramètre
router.post("/updateSensor", sensorCtrl.updateSensor);

module.exports = router