# Gym Mobile SaaS System

## Phase 1: Frontend (Flutter)

- [x] Initialize Flutter project `frontend`
- [x] Setup Clean Architecture folder structure
- [x] Configure routing (e.g., GoRouter) and state management (e.g., Provider/Riverpod)
- [/] Core Setup
  - [x] Set up constants (colors, text styles)
  - [x] Set up themes (light/dark mode)
  - [/] Create core UI widgets (custom buttons, text fields)
- [x] Data Layer Implementation
  - [x] Create models (Member, Trainer, Payment, Gym, Attendance)
  - [x] Create API services structure
  - [x] Create repository implementations
- [x] Feature: Authentication
  - [x] Login Screen UI
  - [x] Sign Up Screen UI
  - [x] Authentication Provider integration
- [x] Feature: Dashboard
  - [x] Dashboard Screen UI (Stats, Charts, Bottom Navigation)
  - [x] Dashboard Provider integration
- [x] Feature: Members
  - [x] Member List Screen UI
  - [x] Add/Edit Member Screen UI
  - [x] Member Profile Screen UI
  - [x] Member Provider integration
- [x] Feature: Attendance
  - [x] QR Scan Screen UI
  - [x] Check-in Confirmation UI
- [x] Feature: Trainers
  - [x] Trainer List/Profile Screen UI
- [x] Feature: Reports & Settings
  - [x] Reports Generation Screen UI
  - [x] Settings Screen UI (Gym Info, Subscription)

## Phase 2: Backend (Node.js + Express + MongoDB)

- [/] Initialize Node.js project `backend`
- [/] Install dependencies (Express, Mongoose, JWT, bcrypt, etc.)
- [x] Setup database connection to MongoDB
- [x] Create Mongoose Models
  - [x] Gym Model
  - [x] Member Model
  - [x] Trainer Model
  - [x] Payment Model
  - [x] Attendance Model
  - [x] Subscription Plan Model
- [x] Implement Controllers & Routes
  - [x] Authentication APIs (Register Gym, Login)
  - [x] Members APIs (CRUD)
  - [x] Payments APIs (Add, Get)
  - [x] Attendance APIs (Check-in, Get)
- [x] Setup Middlewares
  - [x] JWT Authentication Middleware
  - [x] Error Handling Middleware
- [ ] Integration Testing

## Phase 3: Integration

- [x] Connect Flutter Data Services to Node.js Backend APIs
- [x] Replace mock repositories with actual API calls
- [x] End-to-end testing

## Phase 4: Advanced Features

- [x] Feature: QR Code Check-in System
  - [x] Add `qr_flutter` to generate member QR codes
  - [x] Add `qr_code_scanner` to scan member QR codes
  - [x] Link Attendance APIs with scanned QR member IDs
- [x] Feature: WhatsApp Reminders
  - [x] Backend API to send payment reminder
  - [x] Frontend integration on member list

