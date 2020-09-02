var users = require("../models/userSchema");
var modules = require("../models/modulesSchema").modules;



//Vérifie si un utilisateur avec l'email reçue en paramètre existe
module.exports.userExists = function (email, callback) {
    if (email != null) {
        users.findOne({
            email: email
        }, function (err, user) {
            if (err || !user) {
                callback("User not found", null)
            } else {
                callback(null, user);
            }
        });
    } else {
        callback("Bad Token", null)
    }
};

//------------ Vérifications pour l'ajout d'un module ------------
//Vérification qu'un module match avec les IDs reçus
module.exports.moduleExists = function (res, publicID, privateID, callback) {
    if (res == null) {
        modules.findOne({
            publicID: publicID,
            privateID: privateID
        }, function (err, module) {
            if (err || !module) {
                //Les IDs ne matchent pas => le module correspondant n'existe pas
                callback("This module doesn't exist. Try again.", null)
            } else {
                callback(null, module);
            }
        });
    } else {
        callback(res, null)
    }
}

//Vérifie si l'utilisateur a déjà ajouté ce module
module.exports.userOwnsThisModule = function (res, user, module, callback) {
    if (res == null) {

        if (user.modules.includes(module._id)) {
            //Cas 1: module déjà ajouté

            callback("You've already added this module.");
        } else {
            //Cas 2: module non encore ajouté
            callback(null)
        }
    } else {
        callback(res)
    }
}

//Vérifie si le module est déjà associé à un utilisateur
module.exports.isModuleUsed = function (res, module, callback) {
    if (res == null) {
        if (module.used) {
            //Cas 1: module ajouté par un autre utilisateur
            callback("This module isn't available.");
        } else {
            //Cas 2: module disponible
            callback(null)
        }
    } else {
        callback(res)
    }
}