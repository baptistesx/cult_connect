var mongo = require("../project_modules/mongo_mod");
var controler = require("../project_modules/control_mod");
var jwt = require("jsonwebtoken");
const KEY = "m yincredibl y(!!1!11!)zpG6z2s8)Key'!";

exports.updateSensorAutomaticMode = (req, res, next) => {
    console.log("new request: /api/user/updateSensorAutomaticMode");

    var sensorId = req.body.sensorId;
    var sensorDataIndex = req.body.sensorDataIndex;
    var newValue = req.body.newValue;
    //Vérification du JWT (JSON Web Token)
    var email = jwt.verify(req.get("Authorization"), KEY, {
        algorithm: "HS256"
    }).email;

    //Récupération de l'utilisateur associé au JWT
    controler.userExists(email, function (err, user) {
        if (user != null) {
            //TODO: Faire réelle requete au module et changer etat en bdd que si validé par module

            mongo.updateSensorDataAutomaticMode(
                sensorId,
                newValue,
                function (code, answer) {
                    res.status(code).send(answer);
                }
            );
        } else {
            res.status(401).send(err)
        }
    });
}

exports.updateSensorDataConfig = (req, res, next) => {
    console.log("new request: /api/user/updateSensorDataConfig");

    var sensorId = req.body.sensorId;
    var sensorDataIndex = req.body.sensorDataIndex;
    var newNominalValue = req.body.newNominalValue;
    var newAcceptableMin = req.body.newAcceptableMin;
    var newAcceptableMax = req.body.newAcceptableMax;
    var newCriticalMin = req.body.newCriticalMin;
    var newCriticalMax = req.body.newCritiacalMax;
    //Vérification du JWT (JSON Web Token)
    var email = jwt.verify(req.get("Authorization"), KEY, {
        algorithm: "HS256"
    }).email;

    //Récupération de l'utilisateur associé au JWT
    controler.userExists(email, function (err, user) {
        if (user != null) {
            //TODO: Faire réelle requete au module et changer etat en bdd que si validé par module
            mongo.updateSensorDataConfig(
                sensorId,
                sensorDataIndex,
                newNominalValue,
                newAcceptableMin,
                newAcceptableMax,
                newCriticalMin,
                newCriticalMax,
                function (code, answer) {
                    res.status(code).send(answer);
                }
            );
        } else {
            res.status(401).send(err)
        }
    });
}

exports.updateSensor = (req, res, next) => {
    console.log("new request: /api/user/updateSensor");

    var id = req.body.id;
    var newName = req.body.newName;
    //Vérification du JWT (JSON Web Token)
    var email = jwt.verify(req.get("Authorization"), KEY, {
        algorithm: "HS256"
    }).email;

    //Récupération de l'utilisateur associé au JWT
    controler.userExists(email, function (err, user) {
        if (user != null) {
            // console.log(newName);
            mongo.updateSensor(id, newName, function (code, answer) {
                res.status(code).send(answer);
            });
        } else {
            res.status(401).send(err)
        }
    });
}