// routes user

const express = require("express");
const router = express.Router()
const userCtrl = require("../../controllers/user")

router.post("/updatePassword", userCtrl.updatePassword)

router.post("/configureWifi", userCtrl.configureWifi);

module.exports = router