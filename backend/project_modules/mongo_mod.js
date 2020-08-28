var mongoose = require("mongoose");
var modules = require("./models/modulesSchema").modules;
var users = require("./models/userSchema").users;
var datas = require("./models/dataSchema").datas;
var jwt = require("jsonwebtoken");
var crypto = require("crypto");
var sensors = require("./models/sensorsSchema").sensors;
var validator = require("email-validator");
var controler = require("./control_mod")
var actuators = require("./models/actuatorsSchema").actuators;
const KEY = "m yincredibl y(!!1!11!)zpG6z2s8)Key'!";

//Setup et connexion à la base de données MongoDb
module.exports.connectDB = function () {
  var mongoDB = "mongodb://localhost/monitoring";
  mongoose.connect(mongoDB, {
    useUnifiedTopology: true,
    useNewUrlParser: true,
  });

  //Get the default connection
  var db = mongoose.connection;

  //Bind connection to error event (to get notification of connection errors)
  db.on("error", console.error.bind(console, "MongoDB connection error:"));
};

//Encryption du password reçu en paramètre
encryptPwd = function (pwd, callback) {
  callback(crypto.createHash("sha256").update(pwd).digest("hex"));
};

//Vérification des conditions et association d'un module à un utilisateur
module.exports.addModule = function (
  user,
  moduleName,
  modulePlace,
  publicId,
  privateId,
  callback
) {
  //Vérification de l'existence du module (les deux ID doivent matcher)
  controler.moduleExists(publicId, privateId, function (res, module) {
    //On vérifie si l'utilisateur n'a pas déjà ajouté ce module
    controler.userOwnsThisModule(res, user, module, function (res) {
      //On vérifie si le module est associé à un autre utilisateur
      controler.isModuleUsed(res, module, function (res) {
        //Cas 2: module disponible
        console.log(
          "le module d'id: '" +
          publicId +
          "' n'est pas deja utilisé => liaison avec le user"
        );
        // S'il n'y a tjrs pas de message d'erreur
        if (res == null) {
          if (moduleName != "") module.name = moduleName
          if (modulePlace != "") module.place = modulePlace
          module.used = true
          module.user = user._id // liaison de l'utilisateur au module
          user.modules.push(module._id) // liaison du module à l'utilisateur
          module.save(function (err, module) {
            if (err) return handleError(err);

            user.save(function (err, user) {
              if (err) return handleError(err);

              getUserFullPopulated(user._id, function (code, user) {
                console.log("après ajout")
                console.log(user)
                callback(201, user);
              })
            })
          })
        } else {
          callback(401, "Error while adding the module : " + res);
        }
      });
    });
  });


};

// --------------- SIGNUP ---------------
module.exports.register = function (email, password, callback) {
  //Vérification du format de l'email
  var emailVerif = validator.validate(email);

  if (emailVerif) {
    //Le format de l'email est correct
    users.findOne({
        email: email,
      },
      function (err, user) {
        if (user != null) {
          //Cas 1: cette adresse email est déjà utilisée
          callback(409, "This email address is already used.");
        } else {
          //Cas 2: cette adresse email n'est pas déjà utilisée => création de l'utilisateur
          //Le password est encrypté
          encryptPwd(password, function (encPassword) {
            createUser(email, encPassword, function (answer) {
              getJWT(email, password, function (code, answer) {
                console.log(answer)
                callback(201, answer);
              });
            });
          });
        }
      }
    );
  } else {
    //Mauvais format d'email
    callback(409, "Bad email format");
  }
};

module.exports.updatePassword = function (emailAddress, newPassword, callback) {
  users.findOne({
      email: emailAddress,
    },
    function (err, user) {
      if (user != null) {
        encryptPwd(newPassword, function (encPassword) {
          user.pwd = encPassword;
          user.save(function (err, user) {
            getJWT(emailAddress, newPassword, function (code, answer) {
              console.log(answer)
              callback(200, answer);
            });
          });
        });
      } else {
        callback(409, "No account with this email");
      }
    }
  );
}

//Inscription d'un utilisateur
createUser = function (email, encPassword, callback) {
  var newUser = new users({
    email: email,
    pwd: encPassword,
    modules: [],
    favouriteSensors: [],
    routerPassword: "",
    routerSsid: "",
  });
  newUser.save(function (err, user) {
    if (err) {
      return handleError(err);
    }
    callback("User well created!");
  });
};

//Vérification et connexion de l'utilisateur (renvoie un JWT)
module.exports.logUser = function (email, callback) {
  //Le password est encrypté
  // encryptPwd(password, function (encPassword) {
  //Recherche d'un utilisateur qui match l'email et le password encrypté
  users.findOne(
      //TODO: utiliser findOne?
      {
        email: email,
      },
    ).populate({
      //Remplace l'ObjectId du champ "modules" de user par l'objet correpsondant
      path: "modules",
      model: "modules",
      // select: "modules",
      //Remplace l'ObjectId du champ "sensors" du module peuplé précédemment par l'objet correpsondant
      populate: [{
          path: "sensors",
          model: "sensors",
          populate: [{
            path: "actuators",
            model: "actuators",
            options: {
              limit: 0
            },
          }],
        },
        {
          path: "actuators",
          model: "actuators",
        }, "publicId"
      ],
    })
    .exec(function (err, user) {
      if (err) return handleError(err);
      if (user != null) {
        callback(200, user);
      } else callback(500, "Bad token")
    });
  // );
};

//Vérification et génération d'un jwt lors de la connexion
getJWT = function (email, password, callback) {
  //Le password est encrypté
  encryptPwd(password, function (encPassword) {
    //Recherche d'un utilisateur qui match l'email et le password encrypté
    users.findOne(
      //TODO: utiliser findOne?
      {
        email: email,
        pwd: encPassword,
      },
      function (err, user) {
        if (user != null) {
          //L'utilisateur existe bien
          var payload = {
            email: email,
          };

          //Génération du JWT (JSON Web Token)
          var token = jwt.sign(payload, KEY, {
            algorithm: "HS256",
            expiresIn: "15d",
          });

          callback(200, {
            jwt: token
          });
        } else {
          callback(401, {
            errorMessage: "Bad identifiers"
          });
        }
      }
    );
  });
};
module.exports.getJWT = getJWT

module.exports.removeFavouriteSensorById = function (user, sensorId, callback) {
  for (var i = 0; i < user.favouriteSensors.length; i++) {
    if (user.favouriteSensors[i] === sensorId) {
      user.favouriteSensors.splice(i, 1);
    }
  }

  user.save(function () {
    console.log(sensorId)
    sensors.updateOne({
      _id: sensorId
    }, {
      $set: {
        isFavourite: false
      }
    }, function (err, sensor) {
      users.findOne({
          _id: user._id
        }, function (err, user) {

        }).populate({
          //Remplace l'ObjectId du champ "modules" de user par l'objet correpsondant
          path: "modules",
          model: "modules",
          //Remplace l'ObjectId du champ "sensors" du module peuplé précédemment par l'objet correpsondant
          populate: [{
              path: "sensors",
              model: "sensors",
              populate: [{
                path: "actuators",
                model: "actuators",
                options: {
                  limit: 0
                },
              }, ],
            },
            {
              path: "actuators",
              model: "actuators",
            },
          ],
        })
        .exec(function (err, user) {

          if (err) {
            return handleError(err);
          }
          callback(200, user);
        });
    })
  })

}

module.exports.setWifiRouterParameters = function (user, routerSsid, routerPassword, callback) {
  user.routerSsid = routerSsid
  user.routerPassword = routerPassword
  user.save(function () {
    callback(200, user);
  })
}

module.exports.addFavouriteSensorById = function (user, sensorId, callback) {
  user.favouriteSensors.push(sensorId)

  user.save(function () {
    console.log(sensorId)
    sensors.updateOne({
      _id: sensorId
    }, {
      $set: {
        isFavourite: true
      }
    }, function (err, sensor) {
      users.findOne({
          _id: user._id
        }, function (err, user) {

        }).populate({
          //Remplace l'ObjectId du champ "modules" de user par l'objet correpsondant
          path: "modules",
          model: "modules",
          //Remplace l'ObjectId du champ "sensors" du module peuplé précédemment par l'objet correpsondant
          populate: [{
              path: "sensors",
              model: "sensors",
              populate: [{
                path: "actuators",
                model: "actuators",
                options: {
                  limit: 0
                },
              }, ],
            },
            {
              path: "actuators",
              model: "actuators",
            },
          ],
        })
        .exec(function (err, user) {

          if (err) {
            return handleError(err);
          }
          callback(200, user);
        });
    })
  })

}

//Mise à jour du nom du module d'id reçu en paramètre
module.exports.updateModuleName = function (id, newName, callback) { //update géneral : updateField?
  modules
    .updateOne({
      _id: id
    }, {
      $set: {
        name: newName,
      },
    }, function (err, res) { // test res
      callback(200);
    });
};

//Mise à jour de la place du module d'id reçu en paramètre
module.exports.updateModulePlace = function (id, newPlace, callback) {
  modules
    .updateOne({
      _id: id
    }, {
      $set: {
        place: newPlace,
      },
    }, function () {
      callback(200);
    });
};

//Mise à jour du nom du capteur d'id reçu en paramètre
module.exports.updateSensorSettings = function (id, newName, callback) {
  sensors
    .updateOne({
      _id: id
    }, {
      $set: {
        name: newName,
      },
    })
    .then((obj) => {
      callback(200);
    });
};

getUserFullPopulated = function (userId, callback) {
  users.findOne({
      _id: userId
    }, ).populate({
      //Remplace l'ObjectId du champ "modules" de user par l'objet correpsondant
      path: "modules",
      model: "modules",
      //Remplace l'ObjectId du champ "sensors" du module peuplé précédemment par l'objet correpsondant
      populate: [{
          path: "sensors",
          model: "sensors",
          populate: [{
            path: "actuators",
            model: "actuators",
            options: {
              limit: 0
            },
          }, ],
        },
        {
          path: "actuators",
          model: "actuators",
        },
      ],
    })
    .exec(function (err, user) {
      if (err) {
        return handleError(err);
      }
      callback(200, user);
    });
}
module.exports.getUserFullPopulated = getUserFullPopulated
//Mise à jour de l'état de l'actionneur d'id recu en paramètre
//avec la valeur value reçue en paramètre
module.exports.setActuatorState = function (id, value, callback) {
  actuators
    .updateOne({
      _id: id
    }, {
      $set: {
        state: value,
      },
    }, function () {
      callback(200, "Success");
    });
};

//Mise à jour du mode automatique de l'actionneur d'id recu en paramètre
//avec la valeur value reçue en paramètre
module.exports.setActuatorAutomaticMode = function (id, value, callback) {
  actuators
    .updateOne({
      _id: id
    }, {
      $set: {
        automaticMode: value,
      },
    })
    .then((obj) => {
      callback(200, "Success");
    });
};

module.exports.getModuleOwnerById = function (moduleId, callback) {
  users.findOne({
    modules: moduleId
  }, function (err, user) {
    callback(user)
  })
}

module.exports.getModules = function (email, callback) {
  var o = {}; // empty Object
  o = []; // empty Array, which you can push() values into
  var ok = true;
  users
    .findOne({
      email: email
    }, function (err, user) {
      //renvoie le user trouvé
      if (user.modules.length == 0) {
        console.log();
        callback(200, JSON.stringify(o));
        ok = false;
      }
    })
    .populate({
      //Remplace l'ObjectId du champ "modules" de user par l'objet correpsondant
      path: "modules",
      model: "modules",
      //Remplace l'ObjectId du champ "sensors" du module peuplé précédemment par l'objet correpsondant
      populate: [{
          path: "sensors",
          model: "sensors",
          populate: [{
            path: "data",
            model: "datas",
            options: {
              limit: 0
            },
          }, {
            path: "actuators",
            model: "actuators",
            options: {
              limit: 0
            },
          }],
        },
        {
          path: "actuators",
          model: "actuators",
        },
      ],
    })
    .exec(function (err, user) {
      if (err) return handleError(err);
      if (ok) {
        callback(200, user.modules);
      }
    });
};

//Réinitialise le module et le désassocie du user
module.exports.freeModule = function (email, id, callback) {
  console.log("remove " + id);
  modules
    .updateOne({
      _id: id
    }, {
      $set: {
        name: "ModuleN",
        place: "PlaceN",
        used: false,
        user: undefined,
      },
    })
    .then((obj) => {
      users.findOne({
        email: email
      }, function (err, user) {
        user.modules.remove(id);
        user.save();
      });
      callback(200, "Success");
    });
};

module.exports.updateSensorDataAutomaticMode = function (
  sensorId,
  newValue,
  callback
) {
  sensors.updateOne({
    _id: sensorId
  }, {
    $set: {
      automaticMode: newValue,
    },
  }, function (err, res) { // TODO: test res*
    console.log(res)
    callback(200, "Success");
  });
};

module.exports.updateSensorDataConfig = function (
  sensorId,
  sensorDataIndex,
  newNominalValue,
  newAcceptableMin,
  newAcceptableMax,
  newCriticalMin,
  newCriticalMax,
  callback
) {
  // console.log(sensorId);
  // console.log(sensorDataIndex);
  // console.log(newNominalValue);
  // console.log(newAcceptableMin);
  // console.log(newAcceptableMax);
  // console.log(newCriticalMin);
  // console.log(newCriticalMax);

  sensors.findOne({
    _id: sensorId
  }, function (err, sensor) {
    sensor.nominalValue = newNominalValue;

    sensor.acceptableMin = newAcceptableMin;

    sensor.acceptableMax = newAcceptableMax;

    sensor.criticalMin = newCriticalMin;

    sensor.criticalMax = newCriticalMax;

    sensor.save();
    callback(200, "Success");
  });
};

module.exports.updateActuatorStateById = function (
  actuatorId,
  newValue,
  callback
) {
  console.log(actuatorId);
  console.log(newValue);

  actuators.updateOne({
    _id: actuatorId
  }, {
    $set: {
      state: (newValue === "true"),
    },
  }, function (err, res) { // TODO: test res*
    if (err == null) {
      console.log(res)
      var test = (newValue === "true");
      console.log(test)
      callback(200, newValue);
    }

  });
};