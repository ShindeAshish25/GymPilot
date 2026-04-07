# Gym SaaS Project - Master Roadmap

## Project Summary
A comprehensive Gym Management System (SaaS) designed for gym owners to manage their business efficiently.
- **Frontend**: Flutter (Mobile Application)
- **Backend**: Node.js, Express, MongoDB
- **Key Features**: Multi-tenancy, Subscription Management, Attendance Tracking, Payment Processing, and Reporting.

---

## 1. Project Flows

### A. Frontend Flow (Mobile App)
The user journey starts from authentication and leads to day-to-day operations.

1.  **Onboarding & Auth**
    *   **Splash Screen**: App branding and initial check.
    *   **Signup**: Gym Owner registers with Gym Name, Owner Name, Email, and Password.
    *   **Gym Setup**: Upload Gym Logo, Choose Plan (Basic, Pro, Premium), and Set Operating Hours.
    *   **Login**: Secure access using email and password.

2.  **Dashboard (Main Hub)**
    *   Overview of Active Members, Expiring Members, and Daily Attendance.
    *   Quick actions: Add Member, Mark Attendance.

3.  **Member Management**
    *   **Add Member**: Name, Phone, Photo, Joining Date, Plan start/end.
    *   **Member List**: Search, Filter by status (Active/Expired).
    *   **Member Profile**: View statistics, Payment history, and Attendance logs.

4.  **Attendance System**
    *   **Manual Mark**: Simple toggle/button for today.
    *   **QR Code**: Scan member's app-generated QR for instant entry (Future Phase).

5.  **Finance & Payments**
    *   Mark subscription as paid.
    *   Receive notifications for upcoming renewals.

6.  **Reports**
    *   **Revenue Reports**: Monthly/Weekly income.
    *   **Attendance Reports**: Peak hours and frequency logs.
    *   **Expiry Reports**: List of members needing renewal.

### B. Backend Flow (API & Logic)
The server handles data persistence, security, and complex calculations.

1.  **Authentication & Gym Management**
    *   `POST /api/auth/register`: Validate and create Gym + Admin user.
    *   `POST /api/auth/login`: Issue JWT.
    *   `GET/PUT /api/gym`: Manage gym profile and settings.

2.  **Member & Subscription Logic**
    *   `POST /api/members`: Create member link to the Gym ID.
    *   Subscription calculation logic (End Date = Start Date + Plan Duration).

3.  **Attendance Execution**
    *   `POST /api/attendance`: Record timestamp and member ID. Prevent double entries for the same day.

4.  **Reporting Engine**
    *   Aggregation pipelines in MongoDB to calculate revenue and attendance trends.
    *   `GET /api/dashboard`: Aggregated stats for the home screen.

---

## 2. Implementation的任务 (End-to-End)

### Phase 1: Foundation (Backend & Setup)
- [x] Initialize Node.js environment with Express.
- [x] Setup MongoDB connection with Mongoose.
- [x] Create **Gym** and **User** Models with Multi-tenant support (GymID).
- [x] Implement Auth Routes (Signup/Login) with JWT.
- [x] Create Error Handling and Auth Middlewares.

### Phase 2: Frontend Onboarding (Auth)
- [x] Setup Flutter project with `lib` architecture (Data, Features, Providers).
- [x] Implement UI for Login and Signup screens with premium Red theme.
- [x] Implement Welcome Screen (Gympilot Hero) with interactive animations.
- [x] Implement Payment Gateway Screen with dynamic invoice calculation.
- [x] Add "1 Month Free Trial" automation in Signup and Backend.
- [x] Integrate Auth API into Flutter using `http`/`dio`.
- [x] Implement Secure Storage for JWT tokens.
- [x] Profile/Gym Setup screen for logo upload and plan selection.
- [x] Standardize premium UI components (GradientButton, Rounded Fields).

### Phase 3: Core Features (Members & Attendance)
- [x] **Backend**: Member CRUD endpoints.
- [x] **Frontend**: Build Member List and Add Member screens (Updated with Red Theme).
- [ ] **Backend**: Attendance marking logic.
- [ ] **Frontend**: Implement Attendance UI (Daily list).
- [ ] **Backend**: Dashboard stats API (Aggregate counts).
- [ ] **Frontend**: Interactive Dashboard with charts (Revenue/Attendance).

### Phase 4: Finance & Subscriptions
- [x] **Backend**: Payment Schema and tracking.
- [x] **NEW**: Backend logic for Trial vs Paid plan end dates.
- [ ] **Frontend**: Payment history and "Mark Paid" functionality.
- [ ] **Backend**: Automated check for expiring subscriptions.
- [ ] **Frontend**: Notifications for overdue payments.

### Phase 5: Reports & Polish
- [ ] **Backend**: Advanced analytics endpoints for Reports feature.
- [ ] **Frontend**: Reports screen with date range filters.
- [x] **UI/UX**: Premium styling overhaul (Vibrant Red & Glassmorphism accents).
- [/] **Testing**: End-to-end flow validation (Signup -> Welcome -> Payment -> Login).
- [ ] **Deployment**: Prepare for production deployment.
