// routes actuator

const express = require("express");
const router = express.Router()
const actuatorCtrl = require("../../controllers/actuator")

//Mise à jour de l'état d'un actionneur d'id reçu en paramètre
router.post("/setActuatorState", actuatorCtrl.setActuatorState);

//Mise à jour du mode automatic de l'actionneur
router.post("/setActuatorAutomaticMode", actuatorCtrl.setActuatorsAutomaticMode);

router.post("/updateActuatorStateById", actuatorCtrl.updateActuatorStateById);

module.exports = router