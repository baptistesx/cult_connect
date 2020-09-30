// Test des middlewares

const express = require("express");
const app = express();
var mongo = require("../../project_modules/mongo_mod");

mongo.connectDB()


app.use((req, res, next) => {
  console.log("new request : ", req.originalUrl); //diff avec .url?
  next()
})