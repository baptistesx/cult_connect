// Authentification

const express = require("express");
const router = express.Router()
var mongo = require("../../project_modules/mongo_mod");

//Route pour inscription d'un utilisateur
router.post("/signup",
  //celebrate
  function (req, res) {
    // const {
    //     email,
    //     password
    // } = req.body
    var email = req.body.email;
    var password = req.body.pwd;

    mongo.register(email, password, function (code, answer) {
      res.status(code).send(answer);
    });
  }
)

//Route pour connexion de l'utilisateur
router.post("/login", function (req, res) {
  console.log("new request: /api/login");

  var email = req.body.email;
  var password = req.body.pwd;

  mongo.logUser(email, password, function (code, answer) {
    res.status(code).send(answer);
  });
});

router.post("/sendVerificationCode", function (req, res) {
  console.log("new request: /api/sendVerificationCode");
  setTimeout(function () {
    var emailAddress = req.body.emailAddress;
    console.log(emailAddress);
    //TODO: envoie code par email
    res.status(200).send(JSON.stringify({
      "verificationCode": "567",
    }));
  }, 2000);
});

module.exports = router