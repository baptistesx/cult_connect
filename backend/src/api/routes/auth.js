// Authentification

const express = require("express");
const router = express.Router()
const authCtrl = require("../../controllers/auth")

//Route pour inscription d'un utilisateur
router.post("/signup", authCtrl.signup)

//Route pour connexion de l'utilisateur
router.post("/login", authCtrl.signin)

router.post("/sendVerificationCode", authCtrl.sendVerificationCode)

module.exports = router