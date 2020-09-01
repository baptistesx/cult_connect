module.exports = {
    mongodbMemoryServerOptions: {
      instance: {
        dbName: 'db_test'
      },
      binary: {
        version: '4.0.2', // Version of MongoDB
        skipMD5: true
      },
      autoStart: false
    }
  };