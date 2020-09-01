const mongoose = require("mongoose");
var Schema = mongoose.Schema,
  ObjectId = Schema.ObjectId;

const actuatorsSchema = new Schema({
  name: String,
  module: { type: ObjectId, ref: "modules" },
  state: Boolean,
  value: Number,
  startTime: Date,
  stopTime: Date,
  automaticMode: Boolean
});

module.exports.actuators = mongoose.model("actuators", actuatorsSchema);
