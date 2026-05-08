require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');
const { errorHandler } = require('./middleware/errorMiddleware');

const app = express();

// Connect Database
connectDB();

// Init Middleware
app.use(express.json());
app.use(cors());

// Global Request Logger - MUST BE ABOVE ROUTES
app.use((req, res, next) => {
  const time = new Date().toLocaleTimeString();
  console.log(`\n>>> [${time}] ${req.method} ${req.url}`);
  if (req.body && Object.keys(req.body).length > 0) {
    console.log('    BODY:', JSON.stringify(req.body, null, 2));
  }
  next();
});
app.use('/uploads', express.static('uploads'));

app.get('/', (req, res) => res.send('Gym SaaS API Running'));

// Define Routes
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/members', require('./routes/memberRoutes'));
app.use('/api/payments', require('./routes/paymentRoutes'));
app.use('/api/attendance', require('./routes/attendanceRoutes'));
app.use('/api/dashboard', require('./routes/dashboardRoutes'));
app.use('/api/whatsapp', require('./routes/whatsappRoutes'));
app.use('/api/gym', require('./routes/gymRoutes'));
app.use('/api/expenses', require('./routes/expenseRoutes'));
app.use('/api/trainers', require('./routes/trainerRoutes'));
app.use('/api/reports', require('./routes/reportRoutes'));

// Error Handler Middleware
app.use(errorHandler);


const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Server started on port ${PORT}`));
