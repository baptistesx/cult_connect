const mongoose = require("mongoose");
var Schema = mongoose.Schema,
  ObjectId = Schema.ObjectId;

const modulesSchema = new Schema({
  publicID: String,
  privateID: String,
  name: String,
  place: String,
  used: Boolean,
  sensors: [{ type: ObjectId, ref: "sensors" }],
  user: { type: ObjectId, ref: "users" },
});

module.exports.modules = mongoose.model("modules", modulesSchema);
