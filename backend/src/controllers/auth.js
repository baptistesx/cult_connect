var mongo = require("../../project_modules/mongo_mod");

exports.signup = (req, res, next) => {
    var email = req.body.email;
    var password = req.body.pwd;

    mongo.register(email, password, function (code, answer) {
        res.status(code).send(answer);
    });
}

exports.signin = (req, res, next) => {
    console.log("new request: /api/login");

    var email = req.body.email;
    var password = req.body.pwd;

    mongo.logUser(email, password, function (code, answer) {
        res.status(code).send(answer);
    });
}

exports.sendVerificationCode = (req, res, next) => {
    console.log("new request: /api/sendVerificationCode");
    setTimeout(function () {
        var emailAddress = req.body.emailAddress;
        console.log(emailAddress);
        //TODO: envoie code par email
        res.status(200).send(JSON.stringify({
            "verificationCode": "567",
        }));
    }, 2000);
}