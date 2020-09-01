var mongoose = require("mongoose");
var modules = require("../models/modulesSchema").modules;
var users = require("../models/userSchema");
var datas = require("../models/dataSchema").datas;
var jwt = require("jsonwebtoken");
var crypto = require("crypto");
var sensors = require("../models/sensorsSchema").sensors;
var validator = require("email-validator");
var controler = require("./control_mod")
var actuators = require("../models/actuatorsSchema").actuators;
const KEY = "m yincredibl y(!!1!11!)zpG6z2s8)Key'!";

//Setup et connexion à la base de données MongoDb
function connectDB() {
  var mongoDB = "mongodb://localhost/monitoring";
  mongoose.connect(mongoDB, {
      useUnifiedTopology: true,
      useNewUrlParser: true,
    })
    .then(() => console.log('Connexion à MongoDB réussie !'))
    .catch(() => console.log('Connexion à MongoDB échouée !'));;

  //Get the default connection
  var db = mongoose.connection;

  //Bind connection to error event (to get notification of connection errors)
  // db.on("error", console.error.bind(console, "MongoDB connection error:"));
};
connectDB()

//Encryption du password reçu en paramètre
encryptPwd = function (pwd, callback) {
  callback(crypto.createHash("sha256").update(pwd).digest("hex"));
};

//Vérification des conditions et association d'un module à un utilisateur
module.exports.addModule = function (
  email,
  moduleName,
  modulePlace,
  publicID,
  privateID,
  callback
) {
  controler.userExists(email, function (res, user) {
    //Vérification de l'existence du module (les deux ID doivent matcher)
    controler.moduleExists(res, publicID, privateID, function (res, module) {
      //On vérifie si l'utilisateur n'a pas déjà ajouté ce module
      controler.userOwnsThisModule(res, user, module, function (res) {
        //On vérifie si le module est associé à un autre utilisateur
        controler.isModuleUsed(res, module, function (res) {
          //Cas 2: module disponible
          console.log(
            "le module d'id: '" +
            publicID +
            "' n'est pas deja utilisé => liaison avec le user"
          );
          // S'il n'y a tjrs pas de message d'erreur
          if (res == null) {
            module.name = moduleName
            module.place = modulePlace
            module.used = true
            module.user = user._id // liaison de l'utilisateur au module
            user.modules.push(module._id) // liaison du module à l'utilisateur
            module.save(function (err) {
              if (err) return handleError(err);
            })
            user.save(function (err) {
              if (err) return handleError(err);
            })
            callback("The module has been added with success!", 201);
          } else {
            callback("Error while adding the module : " + res, 401);
          }
        });
      });
    });
  })

};

// --------------- SIGNUP ---------------
//Inscription d'un utilisateur
var createUser = function (email, encPassword, callback) {
  var newUser = new users({
    email: email,
    pwd: encPassword
  });
  newUser.save(function (err, user) {
    if (err) {
      return handleError(err);
    }
    callback("User well created!");
  });
};

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
          callback(409, "An user with that username already exists");
        } else {
          // Cas 2: cette adresse email n'est pas déjà utilisée => 
          //    - password encrypté
          //    - création de l'utilisateur
          encryptPwd(password, function (encPassword) {
            createUser(email, encPassword, function (answer) {
              callback(201, answer);
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


// --------------- SIGNIN ---------------
//Vérification et connexion de l'utilisateur (renvoie un JWT)
module.exports.logUser = function (email, password, callback) {
  //Le password est encrypté
  encryptPwd(password, function (encPassword) {
    //Recherche d'un utilisateur qui match l'email et le password encrypté
    users.findOne({
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

          callback(200, token);
        } else {
          callback(401, "There's no user matching that");
        }
      }
    );
  });
};

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
      callback(200, "ok");
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
      callback(200, "ok");
    });
};

//Mise à jour du nom du capteur d'id reçu en paramètre
module.exports.updateSensor = function (id, newName, callback) {
  sensors
    .updateOne({
      _id: id
    }, {
      $set: {
        name: newName,
      },
    })
    .then((obj) => {
      callback(200, "ok");
    });
};

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