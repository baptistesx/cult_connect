const mongoose = require('mongoose');
const request = require('supertest')
const UserModel = require('../project_modules/models/userSchema').users;
const userData = {email: 'testing@gmail.com',pwd: 'test'};
const mongo_mod = require("../project_modules/mongo_mod")
describe('User Model Test', () => {

    // It's just so easy to connect to the MongoDB Memory Server 
    // By using mongoose.connect
    beforeAll(async () => {
        await mongoose.connect(`mongodb://127.0.0.1/db_test`, { useNewUrlParser: true }, (err) => {
            if (err) {
                console.error(err);
                process.exit(1);
            }
        });
    });


    // it('create & save user successfully', async () => {
    //     const validUser = new UserModel(userData);
    //     const savedUser = await validUser.save();
    //     // Object Id should be defined when successfully saved to MongoDB.
    //     expect(savedUser._id).toBeDefined();
    //     expect(savedUser.name).toBe(userData.name);
    //     expect(savedUser.gender).toBe(userData.gender);
    //     expect(savedUser.dob).toBe(userData.dob);
    //     expect(savedUser.loginUsing).toBe(userData.loginUsing);
    // });

    // // Test Schema is working!!!
    // // You shouldn't be able to add in any field that isn't defined in the schema
    // it('insert user successfully, but the field does not defined in schema should be undefined', async () => {
    //     const userWithInvalidField = new UserModel({ name: 'TekLoon', gender: 'Male', nickname: 'Handsome TekLoon' });
    //     const savedUserWithInvalidField = await userWithInvalidField.save();
    //     expect(savedUserWithInvalidField._id).toBeDefined();
    //     expect(savedUserWithInvalidField.nickkname).toBeUndefined();
    // });

    // async function removeAllCollections () {
    //   const collections = Object.keys(mongoose.connection.collections)
    //   for (const users of collections) {
    //     const collection = mongoose.connection.collections[users]
    //     await collection.deleteMany()
    //   }
    // }
    
    afterEach(async () => {
      // await removeAllCollections()
    })
})