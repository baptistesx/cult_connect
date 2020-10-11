//TODO: créer fichier de log (écrire dans un fichier: date, heure, commande, resultat)

//TODO: décrire chaque paramètre des fonctions + callback

//TODO: gerer tous les cas d'erreur

//TODO: utiliser des callback(code, "reponse") dans mongo_mod.js

//TODO: passer le serveur en https, voir server_https_to_check.js
// + https://www.zem.fr/creer-un-serveur-https-nodejs-express/ pour générer le certificat

//TODO: faire en sorte que toutes les requetes sur les modules soient bien exécutées
// sur le user après l'avoir checké

//TODO: supprimer le paramètre sensorDataIndex car devenu inutile comme on a descendu d'un niveau

//TODO: coup de formattage auto

//TODO: supprimer commentaires inutiles (console.log)

//TODO: ajouter tableau d'actuators au schema du module

var express = require("express");
var app = express();
var http = require("http");
var bodyParser = require("body-parser");
var mongo = require("./project_modules/mongo_mod");
var controler = require("./project_modules/control_mod");
var jwt = require("jsonwebtoken");

var nodemailer = require('nodemailer');

const {
  waitForDebugger
} = require("inspector");
const {
  users
} = require("./project_modules/models/userSchema");
const {
  sensors
} = require("./project_modules/models/sensorsSchema");
const {
  modules
} = require("./project_modules/models/modulesSchema");

const KEY = "m yincredibl y(!!1!11!)zpG6z2s8)Key'!";

app.use(bodyParser.urlencoded({
  extended: false
}));

//Route pour inscription d'un utilisateur
app.post("/api/signUp", function (req, res) {
  console.log("new request: /api/signup");

  var email = req.body.email;
  var password = req.body.pwd;

  mongo.register(
    email,
    password,
    function (code, answer) {
      res.status(code).send(answer);
    },
  );
});

//Route pour demande de jwt lors avant connexion
app.get("/", function (req, res) {
  console.log("new request: /");

  res.status(200).send("ok");
});

//Route pour connexion de l'utilisateur
app.post("/api/signIn", function (req, res) {
  console.log("new request: /api/signIn");
  console.log(req.get("Authorization"))
  //Vérification du JWT (JSON Web Token)
  //Vérifie si le token match bien avec l'email
  var email = jwt.verify(req.get("Authorization"), KEY, {
    algorithm: "HS256"
  }).email;
  console.log(email)
  mongo.logUser(email, function (code, answer) {
    console.log(answer)
    res.status(code).send(answer);
  })

});

//Route pour demande de jwt lors avant connexion
app.get("/api/getJWT/", function (req, res) {
  console.log("new request: /api/getJWT");

  var email = req.query.email;
  var password = req.query.pwd;

  mongo.getJWT(email, password, function (code, answer) {
    console.log(answer)
    res.status(code).send(answer);
  });

});

//Route pour ajouter un module à l'utilisateur
app.post("/api/addModule", function (req, res) {
  console.log("new request: /api/addModule");
  //Vérification du JWT (JSON Web Token)
  //Vérifie si le token match bien avec l'email
  var email = jwt.verify(req.get("Authorization"), KEY, {
    algorithm: "HS256"
  }).email;

  console.log(email)

  //Récupération de l'utilisateur associé au JWT
  controler.userExists(email, function (err, user) {
    if (user != null) {
      var publicId = req.body.publicId;
      var privateId = req.body.privateId;
      var name = req.body.name;
      var place = req.body.place;
      var routerSsid = req.body.routerSsid;
      var routerPassword = req.body.routerPassword;
      console.log(publicId)
      console.log(privateId)
      console.log(name)
      console.log(place)
      console.log(routerSsid)
      console.log(routerPassword)

      user.routerSsid = routerSsid
      user.routerPassword = routerPassword
      user.save(function (err, user) {
        //Ajout du module dans la liste des modules de l'utilisateur
        mongo.addModule(
          user,
          name,
          place,
          publicId,
          privateId,
          function (code, answer) {
            console.log("code:" + code + " answer: " + answer)
            res.status(code).send(answer);
          }
        );
      })

    } else {
      res.status(401).send(err)
    }
  });


});

//Mise à jour de l'état d'un actionneur d'id reçu en paramètre
app.post("/api/user/setActuatorState", function (req, res) {
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
app.post("/api/user/setActuatorAutomaticMode", function (req, res) {
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

//Mise à jour du mode automatic de l'actionneur
app.post("/api/user/updateSensorAutomaticMode", function (req, res) {
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
});

//Mise à jour de la config d'un sensorData
app.post("/api/user/updateSensorDataConfig", function (req, res) {
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

});

//Route pour mise à jour du module d'id reçu en paramètre
app.post("/api/updateModuleSettings", function (req, res) {
  console.log("new request: /api/updateModuleSettings");

  //Vérification du JWT (JSON Web Token)
  var email = jwt.verify(req.get("Authorization"), KEY, {
    algorithm: "HS256"
  }).email;

  //Récupération de l'utilisateur associé au JWT
  controler.userExists(email, function (err, user) {
    if (user != null) {
      var id = req.body.moduleId;
      var newName = req.body.newName;
      var newPlace = req.body.newPlace;
      if (newName != "") {
        mongo.updateModuleName(id, newName, function (code) {});
      }
      if (newPlace != "") {
        mongo.updateModulePlace(id, newPlace, function (code) {});
      }
      var user = mongo.getUserFullPopulated(user._id, function (code, user) {
        console.log(code + " " + user)
        res.status(code, ).send(user);
      })
    } else {
      res.status(401).send(err)
    }
  });
});

//Route pour mise à jour d'un capteur d'id reçu en paramètre
app.post("/api/updateSensorSettings", function (req, res) {
  console.log("new request: /api/user/updateSensorSettings");


  //Vérification du JWT (JSON Web Token)
  var email = jwt.verify(req.get("Authorization"), KEY, {
    algorithm: "HS256"
  }).email;

  //Récupération de l'utilisateur associé au JWT
  controler.userExists(email, function (err, user) {
    if (user != null) {
      var sensorId = req.body.sensorId;
      var newName = req.body.newName;
      mongo.updateSensorSettings(sensorId, newName, function (code) {
        mongo.getUserFullPopulated(user._id, function (code, user) {
          res.status(code).send(user);
        })
      });
    } else {
      res.status(401).send(err)
    }
  });
});

//Utilisateur "supprime" un module de sa liste => libérer module mais pas supprimer
app.post("/api/user/removeModule", function (req, res) {
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
});

app.get("/api/user/getModules", function (req, res) {
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
});

app.post("/api/user/updateActuatorStateById", function (req, res) {
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

app.post("/api/configureWifi", function (req, res) {
  console.log("new request: /api/configureWifi");

  //Vérification du JWT (JSON Web Token)
  var email = jwt.verify(req.get("Authorization"), KEY, {
    algorithm: "HS256"
  }).email;

  //Récupération de l'utilisateur associé au JWT
  controler.userExists(email, function (err, user) {
    if (user != null) {
      var routerSsid = req.body.routerSsid;
      var routerPassword = req.body.routerPassword;
      mongo.setWifiRouterParameters(user, routerSsid, routerPassword, function (code, answer) {
        res.status(code).send(answer);
      });
    } else {
      res.status(401).send(err);
    }
  });
});

var transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: 'seuxbaptiste2@gmail.com',
    pass: 'Testtest.'
  }
});

function generateRandomVerificationCode(length) {
  var result = '';
  var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  var charactersLength = characters.length;
  for (var i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength));
  }
  return result;
}

app.post("/api/sendVerificationCode", function (req, res) {
  console.log("new request: /api/sendVerificationCode");
  var emailAddress = req.body.emailAddress;
  console.log(emailAddress);

  users.findOne({
    email: emailAddress
  }, function (err, user) {
    if (user != null) {
      //TODO: generate random verification code
      var code = generateRandomVerificationCode(5)

      var mailOptions = {
        from: 'seuxbaptiste2@gmail.com',
        to: emailAddress,
        subject: 'Verification code for a new password!',
        text: 'Code: ' + code,
      };

      transporter.sendMail(mailOptions, function (error, info) {
        if (error) {
          console.log(error);
          res.status(500).send("ERROR");
        } else {
          console.log('Email sent: ' + info.response);
          res.status(200).send(JSON.stringify({
            "verificationCode": code,
          }));
        }
      });
    } else {
      res.status(409).send({
        errorMessage: "No user matches this email address"
      })
    }
  })
});

app.post("/api/updatePassword", function (req, res) {
  console.log("new request: /api/updatePassword");
  setTimeout(function () {
    var emailAddress = req.body.emailAddress;
    var newPassword = req.body.newPassword;

    controler.userExists(emailAddress, function (err, user) {
      if (user != null) {
        console.log("user not nul!")
        mongo.updatePassword(emailAddress, newPassword, function (code, answer) {
          res.status(code).send(answer);
        });
      } else {
        console.log("user nul!")
        res.status(401).send(err);
      }
    });
  }, 2000);
});

// app.post("/api/addModule", function (req, res) {
//   console.log("new request: /api/addModule");
//   setTimeout(function () {
//     var publicId = req.body.publicId;
//     var privateId = req.body.privateId;
//     var name = req.body.name;
//     var place = req.body.place;
//     console.log(publicId)
//     console.log(privateId)
//     console.log(name)
//     console.log(place)
//     res.status(200).send(JSON.stringify({
//       "userId": "123",
//       "emailAddress": "toto@gmail.com",
//       "token": "123456",
//       "pseudo": "toto",
//       "modules": [{
//         "moduleId": "123",
//         "publicId": publicId,
//         "privateId": privateId,
//         "name": name,
//         "place": place,
//         "used": true,
//         "sensors": {
//           "147": {
//             "sensorId": "147",
//             "name": "sensor1",
//             "dataType": "humidity",
//             "unit": "%",
//             "acceptableMin": 20,
//             "acceptableMax": 30,
//             "criticalMin": 10,
//             "criticalMax": 40,
//             "nominalValue": 25,
//             "limitMin": 0,
//             "limitMax": 100,
//             "automaticMode": false,
//             "isFavourite": true,
//             "data": [{
//               "date": "2020-04-03T22:00:00.000+00:00",
//               "value": 65
//             }],
//             "actuators": [],
//           },
//           "10": {
//             "sensorId": "10",
//             "name": "sensor2",
//             "dataType": "temperature",
//             "unit": "°C",
//             "acceptableMin": 20,
//             "acceptableMax": 30,
//             "criticalMin": 10,
//             "criticalMax": 40,
//             "nominalValue": 25,
//             "limitMin": 0,
//             "limitMax": 100,
//             "automaticMode": false,
//             "isFavourite": true,
//             "data": [{
//               "date": "2020-04-03T22:00:00.000+00:00",
//               "value": 30
//             }],
//             "actuators": [],
//           },
//         },
//         "actuators": [],
//       }, ],
//       "favouriteSensors": ["10", "147"],

//     }));
//   }, 2000);
// });

app.post("/api/removeFavouriteSensorById", function (req, res) {
  console.log("new request: /api/removeFavouriteSensorById");

  var email = jwt.verify(req.get("Authorization"), KEY, {
    algorithm: "HS256"
  }).email;

  //Récupération de l'utilisateur associé au JWT
  controler.userExists(email, function (err, user) {
    if (user != null) {
      var sensorId = req.body.sensorId;

      mongo.removeFavouriteSensorById(user, sensorId, function (code, answer) {
        res.status(code).send(answer);
      });
    } else {
      res.status(401).send(err);
    }
  });
});

app.post("/api/addFavouriteSensorById", function (req, res) {
  console.log("new request: /api/addFavouriteSensorById");

  var email = jwt.verify(req.get("Authorization"), KEY, {
    algorithm: "HS256"
  }).email;

  //Récupération de l'utilisateur associé au JWT
  controler.userExists(email, function (err, user) {
    if (user != null) {
      var sensorId = req.body.sensorId;

      mongo.addFavouriteSensorById(user, sensorId, function (code, answer) {
        res.status(code).send(answer);
      });
    } else {
      res.status(401).send(err);
    }
  });
});

// Démarrage du serveur
server = http.createServer(app)

function getSensorData(moduleId, sensor, callback) {
  callback(JSON.stringify({
    moduleId: moduleId,
    sensorId: sensor._id,
    data: sensor.data
  }))
}

// Chargement de socket.io
var io = require('socket.io').listen(server);

var clientsSockets = new Map();

//Connection d'un nouveau client => nouvelle socket
io.sockets.on('connection', function (socket) {
  var userId = ""

  //identification de la socket
  socket.on('identification', function (name) {
    socket.name = name
    socket.dbId = name.split('_')[1]
    //Le client est un module
    if (name.split('_')[0] == "M") {
      mongo.getModuleOwnerById(name.split('_')[1], function (user) {
        //TODO: handle user = null case

        if (user != null) {
          //Le module rejoint la room correspondant a l'id de
          // son utilisateur
          userId = user._id
          moduleId = socket.dbId
          clientsSockets.set(socket.id, moduleId)
          console.log("module " + moduleId + " joining room " + userId)
          socket.join(userId)
          modules.findOne({
            _id: moduleId
          }, function (err, module) {
            module.state = true;
            module.save()
            console.log("emitting new module connected")
            socket.to(userId).emit("newModuleConnected", moduleId);
          })
        } else {
          console.log("[EEEERRROOOR] no user found");
        }

      })

      //Le module envoie une nouvelle data
      socket.on('newDataFromModule', function (dataReceived) {
        var res = dataReceived.replace(/'/g, "\"")
        var dataParsed = JSON.parse(res)
        console.log(dataParsed)

        sensors.findOne({
          _id: dataParsed.sensorId
        }, function (err, sensor) {
          console.log("newDataFromModule: %j", dataParsed.data)
          sensor.data.push(dataParsed.data)

          //Sauvegarde de la data en base de données
          sensor.save(function (err, sensor) {
            getSensorData(dataParsed.moduleId, sensor, function (dataToSend) {
              //Broadcast a toutes les sockets de la room
              io.to(userId).emit("appNewData", dataToSend)
            })

          })
        })

      });
    }
    //Le client est un utilisateur 
    else if (name.split('_')[0] == "USER") {
      var email = jwt.verify(name.split('USER_')[1].toString(), KEY, {
        algorithm: "HS256"
      }).email;

      //Récupération de l'utilisateur associé au JWT
      controler.userExists(email, function (err, user) {
        if (user != null) {
          userId = user._id
          //L'utilisateur rejoint la room correspondant a son id
          console.log("user joining room " + userId)

          clientsSockets.set(socket.id, userId)

          socket.join(userId)

          var list2send = []
          io.of('/').in(userId).clients(function (error, clients) {
              var numClients = clients.length;

              clients.forEach(element => {
                if (clientsSockets.get(element) != userId) {
                  list2send.push(clientsSockets.get(element))
                }
              });
              console.log(JSON.stringify(list2send))
              console.log("emiittiing connected modules");
              socket.emit('connectedModules', JSON.stringify(list2send))
            }

          );

        } else {
          console.log("user null")
          //TODO: handle error
        }
      });

    } else {
      console.log("equipement inconnu")
    }

  });
  socket.on('disconnect', () => {
    var moduleId = socket.dbId

    if (socket.name.split('_')[0] == "M") {
      console.log(socket.name + " disconnect");
      modules.findOne({
        _id: moduleId
      }, function (err, module) {
        module.state = false;
        module.save()

        socket.to(userId).emit("newModuleDisconnected", moduleId);
      })
    }

  });
});

server.listen(process.env.PORT || 8081, function () {
  return console.log(
    "server listening on port 8081"
  );
});

//Connexion à la base de données
mongo.connectDB();