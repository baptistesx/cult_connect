// routes user

const express = require("express");
const router = express.Router()


router.post("/updatePassword", function (req, res) {
  console.log("new request: /api/updatePassword");
  setTimeout(function () {
    var emailAddress = req.body.emailAddress;
    var newPassword = req.body.newPassword;
    console.log(emailAddress);
    console.log(newPassword);
    //TODO: update password
    res.status(200).send(JSON.stringify({

      "userId": "123",
      "emailAddress": "toto@gmail.com",
      "token": "123456",
      "routerSsid": "aaa",
      "routerPassword": "bbb",
      "modules": [{
        "moduleId": "123",
        "publicId": "1234",
        "privateId": "1234",
        "name": "module1",
        "place": "serre",
        "used": false,
        "sensors": {
          "147": {
            "sensorId": "147",
            "name": "sensor1",
            "dataType": "humidity",
            "unit": "%",
            "acceptableMin": 20,
            "acceptableMax": 30,
            "criticalMin": 10,
            "criticalMax": 40,
            "nominalValue": 25,
            "limitMin": 0,
            "limitMax": 100,
            "automaticMode": false,
            "isFavourite": false,
            "data": [{
              "date": "2020-04-03T22:00:00.000+00:00",
              "value": 65
            }],
            "actuators": [],
          },
          "10": {
            "sensorId": "10",
            "name": "sensor2",
            "dataType": "temperature",
            "unit": "°C",
            "acceptableMin": 20,
            "acceptableMax": 30,
            "criticalMin": 10,
            "criticalMax": 40,
            "nominalValue": 25,
            "limitMin": 0,
            "limitMax": 100,
            "automaticMode": false,
            "isFavourite": false,
            "data": [{
              "date": "2020-04-03T22:00:00.000+00:00",
              "value": 30
            }],
            "actuators": [],
          },
        },
        "actuators": [],
      }],
      "favouriteSensors": ["10", "147"],
    }));
  }, 2000);
});

router.post("/configureWifi", function (req, res) {
  console.log("new request: /api/configureWifi");
  setTimeout(function () {
    var routerSsid = req.body.routerSsid;
    var routerPassword = req.body.routerPassword;
    console.log(routerSsid)
    console.log(routerPassword)
    res.status(200).send(JSON.stringify({
      "userId": "123",
      "emailAddress": "toto@gmail.com",
      "token": "123456",
      "routerSsid": "aaa",
      "routerPassword": "bbb",
      "modules": [],
      "favouriteSensors": [],

    }));
  }, 2000);
});

module.exports = router