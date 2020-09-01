// routes actuator

const express = require("express");
const router = express.Router()
var mongo = require("../../project_modules/mongo_mod");
const KEY = "m yincredibl y(!!1!11!)zpG6z2s8)Key'!";
var jwt = require("jsonwebtoken");
var controler = require("../../project_modules/control_mod");


//Mise à jour de l'état d'un actionneur d'id reçu en paramètre
router.post("/setActuatorState", function (req, res) {
    console.log("new request: /api/user/setActuatorState");
  
    var id = req.body.actuatorId;
    var value = req.body.value;
    //Vérification du JWT (JSON Web Token)
    var email = jwt.verify(req.get("Authorization"), KEY, {
      algorithm: "HS256"
    }).email;
  
    //Récupération de l'utilisateur associé au JWT
    controler.userExists(email, function (err, user) {
      if (user != null) {
  
        //TODO: Faire réelle requete au module et changer etat en bdd que si validé par module
  
        mongo.setActuatorState(id, value, function (code, answer) {
          res.status(code).send(answer);
        });
      } else {
        res.status(401).send(err)
      }
    });
  });

  //Mise à jour du mode automatic de l'actionneur
router.post("/setActuatorAutomaticMode", function (req, res) {
    console.log("new request: /api/user/setActuatorAutomaticMode");
  
    var id = req.body.actuatorId;
    var value = req.body.value;
    //Vérification du JWT (JSON Web Token)
    var email = jwt.verify(req.get("Authorization"), KEY, {
      algorithm: "HS256"
    }).email;
  
    //Récupération de l'utilisateur associé au JWT
    controler.userExists(email, function (err, user) {
      if (user != null) {
  
        //TODO: Faire réelle requete au module et changer etat en bdd que si validé par module
  
        mongo.setActuatorAutomaticMode(id, value, function (code, answer) {
          res.status(code).send(answer);
        });
      } else {
        res.status(401).send(err)
      }
    });
  });

  router.post("/updateActuatorStateById", function (req, res) {
    console.log("new request: /api/user/updateActuatorStateById");
  
    //Vérification du JWT (JSON Web Token)
    var email = jwt.verify(req.get("Authorization"), KEY, {
      algorithm: "HS256"
    }).email;
  
    //Récupération de l'utilisateur associé au JWT
    controler.userExists(email, function (err, user) {
      if (user != null) {
        var actuatorId = req.body.actuatorId;
        var newValue = req.body.newValue;
  
        mongo.updateActuatorStateById(actuatorId, newValue, function (code, answer) {
          console.log("%j", answer);
          res.status(code).send(answer);
        });
      } else {
        res.status(401).send(err);
      }
    });
  });

  module.exports = router