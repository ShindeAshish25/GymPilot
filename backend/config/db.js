const mongoose = require('mongoose');
const config = require('dotenv').config();

const connectDB = async () => {
  try {
    let mongoUri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/gymsaas';
    
    // If URI ends with /, append default database name
    if (mongoUri.endsWith('/')) {
      mongoUri += '';
    }
    
    await mongoose.connect(mongoUri);
    console.log('MongoDB Connected to:', mongoUri);
  } catch (err) {
    console.error(err.message);
    // Exit process with failure
    process.exit(1);
  }
};

module.exports = connectDB;
