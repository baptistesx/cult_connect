var mongo = require("../project_modules/mongo_mod");
const KEY = "m yincredibl y(!!1!11!)zpG6z2s8)Key'!";
var jwt = require("jsonwebtoken");
var controler = require("../project_modules/control_mod");

exports.addModule = (req, res, next) => {
    console.log("new request: /api/user/addModule");
    //Vérification du JWT (JSON Web Token)
    //Vérifie si le token match bien avec l'email
    var email = jwt.verify(req.get("Authorization"), KEY, {
        algorithm: "HS256"
    }).email;

    //Ajout du module dans la liste des modules de l'utilisateur
    mongo.addModule(
        email,
        req.body.name,
        req.body.place,
        req.body.publicID,
        req.body.privateID,
        function (answer, code) {
            res.status(code).send(answer);
        }
    );
}

exports.updateModule = (req, res, next) => {
    console.log("new request: /api/user/updateModule");

    var id = req.body.id;
    var newName = req.body.newName;
    var newPlace = req.body.newPlace;
    //Vérification du JWT (JSON Web Token)
    var email = jwt.verify(req.get("Authorization"), KEY, {
        algorithm: "HS256"
    }).email;

    //Récupération de l'utilisateur associé au JWT
    controler.userExists(email, function (err, user) {
        if (user != null) {
            // console.log(newName);
            // console.log(newPlace);
            var response = "ok";
            var codeResponse = 200;
            if (newName != "") {
                mongo.updateModuleName(id, newName, function (code, answer) {
                    codeResponse = code;
                    response = answer;
                });
            }
            if (newPlace != "") {
                mongo.updateModulePlace(id, newPlace, function (code, answer) {
                    codeResponse = code;
                    response = answer;
                });
            }
            res.status(codeResponse).send(response);
        } else {
            res.status(401).send(err)
        }
    });
}

exports.removeModule = (req, res, next) => {
    console.log("new request: /api/user/removeModule");

    //Vérification du JWT (JSON Web Token)
    var email = jwt.verify(req.get("Authorization"), KEY, {
        algorithm: "HS256"
    }).email;

    //Récupération de l'utilisateur associé au JWT
    controler.userExists(email, function (err, user) {
        if (user != null) {
            var id = req.body.id;

            mongo.freeModule(email, id, function (code, answer) {
                res.status(code).send(answer);
            });
        } else {
            res.status(401).send(err);
        }
    });
}

exports.getModules = (req, res, next) => {
    console.log("new request: /api/user/getModules");

    //Vérification du JWT (JSON Web Token)
    var email = jwt.verify(req.get("Authorization"), KEY, {
        algorithm: "HS256"
    }).email;

    //Récupération de l'utilisateur associé au JWT
    controler.userExists(email, function (err, user) {
        if (user != null) {
            mongo.getModules(email, function (code, answer) {
                console.log("%j", answer);
                res.status(code).send(answer);
            });
        } else {
            res.status(401).send(err);
        }
    });
}