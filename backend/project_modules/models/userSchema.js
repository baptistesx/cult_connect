const mongoose = require("mongoose");

var Schema = mongoose.Schema,
  ObjectId = Schema.ObjectId;
const usersSchema = new Schema({
  email: String,
  pwd: String,
  modules: [{type: ObjectId, ref: 'modules'}],
});

module.exports.users = mongoose.model("users", usersSchema);
