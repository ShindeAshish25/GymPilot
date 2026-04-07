---
description: Deploying the Gym SaaS application to production
---

# Production Deployment Workflow

Follow these steps to deploy the Gym SaaS application to a production environment.

## 1. Backend Deployment (Node.js)

### Environment Variables
Ensure the following variables are set in your production environment (e.g., Heroku, AWS, Vercel):
- `PORT`: 5000 (or as provided)
- `MONGO_URI`: Your production MongoDB connection string.
- `JWT_SECRET`: A strong, random string for JWT signing.
- `NODE_ENV`: `production`

### Build and Start
1. Install production dependencies:
   ```bash
   cd backend
   npm install --production
   ```
2. Start the server:
   ```bash
   npm start
   ```

## 2. Frontend Deployment (Flutter Web/Mobile)

### App Branding
1. Update `ApiService.baseUrl` in `lib/data/services/api_service.dart` to your production API URL.
2. Ensure you have the production `assets/` and `gymLogo` handling ready.

### Build (Web example)
// turbo
1. Build the flutter web project:
   ```bash
   cd frontend
   flutter build web
   ```
2. Deploy the `build/web` folder to your static hosting (e.g., Firebase Hosting, Netlify).

## 3. Post-Deployment Verification
1. Test the signup flow with a real image.
2. Verify that `planEndDate` is calculated correctly in MongoDB.
3. Test login and access protected routes.
4. Verify that expired subscriptions are correctly blocked by the `authMiddleware`.
