# GymPilot Project Context

GymPilot is a comprehensive Gym Management SaaS platform designed for gym owners to manage their facilities, members, trainers, payments, and attendance.

## Tech Stack

### Backend
- **Framework:** Node.js with Express.js
- **Database:** MongoDB with Mongoose ODM
- **Authentication:** JWT (JSON Web Tokens) and bcryptjs for password hashing
- **File Uploads:** Multer for handling multipart/form-data (logos, photos)
- **Services:** Nodemailer for OTP emails, custom WhatsApp service for notifications

### Frontend
- **Framework:** Flutter (Dart)
- **State Management:** Provider
- **Navigation:** go_router
- **Networking:** http package
- **UI Components:** glassmorphism, flutter_animate, google_fonts, lottie, fl_chart
- **Utilities:** shared_preferences for local storage, qr_flutter/mobile_scanner for attendance

---

## Code Structure & Flow

### Backend (`/backend`)
- `server.js`: Entry point, initializes Express, connects to DB, and defines top-level routes.
- `models/`: Mongoose schemas for Gym, Member, Trainer, Payment, Attendance, Expense, etc.
- `controllers/`: Logic for handling requests.
    - `authController.js`: Handles Gym registration, login, OTP verification, and password resets.
    - `memberController.js`: CRUD operations for gym members.
    - `trainerController.js`: CRUD operations for trainers.
    - `paymentController.js`: Recording and retrieving member payments.
    - `attendanceController.js`: Handling check-ins (often via QR scan).
    - `dashboardController.js`: Aggregating stats for the admin dashboard.
- `routes/`: Express routers mapping URLs to controllers.
- `middleware/`: Custom middleware like `authMiddleware.js` (JWT validation) and `errorMiddleware.js`.
- `services/`: External integrations (Email, WhatsApp).
- `utils/`: Helper functions (OTP generation, membership status calculations).

### Frontend (`/frontend`)
- `lib/main.dart`: Entry point, sets up Providers and GoRouter.
- `lib/core/`: Constants, themes, shared widgets, and general utilities.
- `lib/data/`:
    - `models/`: Dart classes representing the data entities.
    - `services/api_service.dart`: Centralized class for making HTTP requests to the backend.
- `lib/providers/`: State management classes (e.g., `AuthProvider`, `MemberProvider`) that use `ApiService` and notify listeners.
- `lib/features/`: Feature-based UI organization.
    - `auth/`: Login, Signup, OTP, Forgot Password screens.
    - `dashboard/`: Overview of gym stats.
    - `members/`: List, Add/Edit Member, Member Profile.
    - `attendance/`: QR scanning and history.
    - `trainers/`, `expenses/`, `reports/`, etc.

---

## Key Data Flows

### 1. Authentication Flow
- **Signup:** Gym owner registers -> OTP sent to email -> OTP verified -> Gym account created -> JWT issued.
- **Login:** Gym owner enters credentials -> Backend validates -> JWT issued -> Frontend stores JWT in SharedPreferences.
- **Protected Routes:** Frontend includes JWT in `x-auth-token` header for API requests. Backend `authMiddleware` verifies the token.

### 2. Member Management Flow
- **Add Member:** Admin fills form -> Frontend sends POST to `/api/members` -> Backend saves member linked to `gymId`.
- **Status Calculation:** Member status (Active, Expiring Soon, Expired) is calculated dynamically based on `membershipEndDate`.

### 3. Attendance Flow
- **Check-in:** Frontend scans QR (contains `memberId`) -> POST to `/api/attendance` -> Backend records timestamped attendance record.

---

## API Endpoints Overview

| Category | Base Path | Key Endpoints |
| :--- | :--- | :--- |
| **Auth** | `/api/auth` | `/register`, `/login`, `/send-otp`, `/verify-otp`, `/reset-password` |
| **Members** | `/api/members` | `GET /`, `POST /`, `PUT /:id`, `DELETE /:id`, `/expiring` |
| **Trainers** | `/api/trainers` | `GET /`, `POST /`, `PUT /:id`, `DELETE /:id` |
| **Payments** | `/api/payments` | `GET /member/:memberId`, `POST /` |
| **Attendance** | `/api/attendance` | `POST /`, `GET /member/:memberId`, `GET /today` |
| **Dashboard** | `/api/dashboard` | `GET /stats` |
| **Expenses** | `/api/expenses` | `GET /`, `POST /`, `GET /categories` |
