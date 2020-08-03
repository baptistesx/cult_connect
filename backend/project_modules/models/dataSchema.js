const mongoose = require("mongoose");
var Schema = mongoose.Schema,
  ObjectId = Schema.ObjectId;
  
const dataSchema = new Schema({
  sensor: { type: ObjectId, ref: "sensors" },
  values: [{ date: Date, value: Number }],
});

module.exports.datas = mongoose.model("datas", dataSchema);
