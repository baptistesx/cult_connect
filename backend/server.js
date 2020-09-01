//Principes SOLID
//Middleware
//Validation (Celebrate, joi)
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

app.use(bodyParser.urlencoded({
  extended: false
}));

//Routes pour singup et signin
const authRoutes = require('./api/routes/authentification')
app.use('/api', authRoutes)

// Les routes pour les modules
const moduleRoutes = require('./api/routes/module')
app.use('/api/user', moduleRoutes)

// Les routes pour les sensors
const sensor = require('./api/routes/sensor')
app.use('/api/user', sensor)

// Les routes pour les actuators
const actuator = require('./api/routes/actuator')
app.use('/api/user', actuator)

// Les routes pour les users
const user = require('./api/routes/user');
app.use('/api', user)


// Démarrage du serveur
http.createServer(app).listen(process.env.PORT || 8081, function () {
  return console.log(
    "Started user authentication server listening on port 8081"
  );
});

//Connexion à la base de données
// mongo.connectDB();