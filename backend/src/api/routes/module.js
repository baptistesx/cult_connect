// routes module

const express = require("express");
const router = express.Router()
const moduleCtrl = require("../../controllers/module")


//Route pour ajouter un module à l'utilisateur
router.post("/addModule", moduleCtrl.addModule)

//Route pour mise à jour du module d'id reçu en paramètre
router.post("/updateModule", moduleCtrl.updateModule);

//Utilisateur "supprime" un module de sa liste => libérer module mais pas supprimer
router.post("/removeModule", moduleCtrl.removeModule);

router.get("/getModules", moduleCtrl.getModules);

module.exports = router