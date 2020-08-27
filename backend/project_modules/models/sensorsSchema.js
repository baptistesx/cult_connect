const mongoose = require("mongoose");
const { Double } = require("mongodb");
var Schema = mongoose.Schema,
  ObjectId = Schema.ObjectId;

const sensorsSchema = new Schema({
  name: String,
  dataType: String,
  unit: String,
  acceptableMin: Number,
  acceptableMax: Number,
  criticalMin: Number,
  criticalMax: Number,
  nominalValue: Number,
  limitMin: Number,
  limitMax: Number,
  automaticMode: Boolean,
  isFavourite: Boolean,
  data: [{
    date: Date,
    value: Number,
  }],
  module: {
    type: ObjectId,
    ref: "modules"
  },
});

module.exports.sensors = mongoose.model("sensors", sensorsSchema);