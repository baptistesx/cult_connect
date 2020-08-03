var fs = require("fs");
var express = require("express");
var app = express();
var bodyParser = require('body-parser');
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true, parameterLimit: 50000 }));
var https = require("https").createServer(
  {
    key: fs.readFileSync("key.pem"),
    cert: fs.readFileSync("cert.pem"),
    passphrase: "baptiste",
  },
  app
);
var io = require("socket.io")(https);
var mongoose = require("mongoose");
var mongo = require("./project_modules/mongo_mod");
var jwt = require("jsonwebtoken");
var bodyParser = require("body-parser");
var users = require("./models/userSchema").users;
var messages = require("./models/messageSchema").messages;

const KEY = "m yincredibl y(!!1!11!)<'SECRET>)Key'!";

mongo.connectDB();

io.on("connect", function (socket) {
  console.log("Start animation");
  socket.emit("refreshMessagesList", "heyoo");
  socket.on("disconnect", function () {
    console.log("Stop animation");
  });
});
// app.use(function (req, res, next) {
//   res.setHeader(
//     "Content-Security-Policy",
//     "script-src 'self' https://apis.google.com"
//   );
//   return next();
// });

app.use(
  bodyParser.urlencoded({
    extended: false,
  })
);

app.get("/", function (req, res) {
  res.send("hello world");
});

app.post("/signup", function (req, res) {
  var email = req.body.email;
  var pwd = req.body.pwd;
  var name = req.body.name;
  var phone = req.body.phone;

  mongo.addUser(email, pwd, name, phone, function (code, response) {
    res.status(code).json(response);
  });
});

app.post("/signin", function (req, res) {
  var email = req.body.email;
  var pwd = req.body.pwd;

  mongo.logUser(email, pwd, function (code, response) {
    res.status(code).json(response);
  });
});

app.put("/updateUserInfos", function (req, res) {
  var email = mongo.checkJWT(req.get("Authorization"), KEY);
  if (email != null) {
    var newUsername = JSON.parse(req.body.infos).newUsername;
    var newPhone = JSON.parse(req.body.infos).newPhone;
    var oldPwd = JSON.parse(req.body.infos).oldPwd;
    var newPwd = JSON.parse(req.body.infos).newPwd;
    var newPerimeter = JSON.parse(req.body.infos).newPerimeter;
    console.log(newUsername);
    console.log(newPhone);
    console.log(oldPwd);
    console.log(newPwd);
    console.log(newPerimeter);
    mongo.updateUserInfos(
      email,
      newUsername,
      newPhone,
      oldPwd,
      newPwd,
      newPerimeter,
      function (code, response) {
        res.status(code).json(response);
      }
    );
  } else {
    res.status(500).json({ response: "Error, try to reconnect" });
  }
});

app.put("/updateLocation", function (req, res) {
  console.log("updateLocation");
  var email = mongo.checkJWT(req.get("Authorization"), KEY);
  if (email != null) {
    var location = JSON.parse(req.body.infos).location;
    mongo.updateLocation(email, location, function (code, response) {
      res.status(code).json(response);
    });
  } else {
    res.status(500).json({ response: "Error, try to reconnect" });
  }
});

app.post("/sendMessage", function (req, res) {
  console.log("sendMessage");
  var email = mongo.checkJWT(req.get("Authorization"), KEY);
  console.log(email);
  if (email != null) {
    console.log("okok");
    var message = req.body.message;;
    var photo = req.body.photo;
    mongo.sendMessage(email, message, photo, function (code, response) {
      res.status(code).json(response);
    });
  } else {
    res.status(500).json({ response: "Error, try to reconnect" });
  }
});

app.get("/getUserInfos", function (req, res) {
  console.log("getuserinfos");

  var email = mongo.checkJWT(req.get("Authorization"), KEY);

  if (email != null) {
    console.log("getuserinfos");
    mongo.getUserInfos(email, function (code, response) {
      res.status(code).json(response);
    });
  } else {
    res.status(500).json({ response: "Error, try to reconnect" });
  }
});

app.get("/getMessages", function (req, res) {
  console.log("getmessages");


  var email = mongo.checkJWT(req.get("Authorization"), KEY);
  if (email != null) {
    mongo.getMessages(email, function (code, response) {
      res.status(code).json(response);
      // console.log("%j", response);
    });
  } else {
    res.status(500).json({ response: "Error, try to reconnect" });
  }
});

// Chargement de socket.io
var io = require("socket.io").listen(https);

// Quand un client se connecte, on le note dans la console
io.sockets.on("connection", function (socket) {
  console.log("Un client est connecté !");

  socket.on("newMessage", function (msg) {
    socket.emit("newMessageOnServer", "newMessageOnServer");
    socket.broadcast.emit("newMessageOnServer", "newMessageOnServer");
  });
});

https.listen(3000);
