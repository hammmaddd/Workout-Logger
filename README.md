# Workout Logger

Workout Logger is a fitness tracking application for logging workouts, nutrition, body metrics, and progress in one place. It combines a Flutter mobile application with a Node.js/Express backend, MongoDB, Firebase authentication, and AI-powered coaching features.

## Features

### Workout Tracking

* Create and manage workouts
* Add exercises, sets, reps, weight, duration, rest time, RPE, and notes
* Repeat previous workouts
* Workout templates
* Duplicate previous sets
* Exercise database with muscle groups, equipment, difficulty, instructions, and safety guidance
* Active workout timer and rest timer
* Workout history
* Personal records (PRs)
* Estimated 1RM and training volume
* Progressive overload tracking and recommendations

### Progress & Analytics

* Weekly and monthly workout statistics
* Training volume by muscle group
* Sets and reps tracking
* Exercise strength progression
* Workout frequency and duration
* Progress charts
* Weight tracking
* BMI calculation
* Body measurements
* Workout streaks
* Calendar and historical activity

### Nutrition Tracking

* Breakfast, lunch, dinner, snacks, and drinks
* Custom meals and foods
* Calories and macronutrient tracking
* Protein, carbohydrates, fat, fiber, sugar, and sodium
* Water intake tracking
* Nutrition goals
* Pakistani food support
* Daily and weekly nutrition summaries
* Nutrition progress and streaks

### AI Fitness Coach

* Personalized workout insights
* Performance analysis
* Training volume and frequency analysis
* Recovery-aware recommendations
* Nutrition and protein analysis
* Weight-trend analysis
* Goal-based recommendations
* AI-generated workout planning
* Exercise recommendations based on training history and available equipment

### Authentication & User Profiles

* User registration and login
* Firebase authentication
* User profiles
* Fitness goals
* Activity level
* Training experience
* Workout preferences
* Target weight and body information

### Notifications

* Workout reminders
* Rest reminders
* Meal reminders
* Water reminders
* Protein reminders
* Progress reports
* Streak notifications

### Data & Privacy

* Workout, nutrition, weight, and measurement history
* Data export and backup
* JSON/CSV export support
* Backup and restore functionality
* Local-first approach for personal data
* Sensitive credentials excluded from version control

## Tech Stack

### Frontend

* Flutter
* Dart
* Material UI

### Backend

* Node.js
* Express.js
* JavaScript
* REST API

### Database

* MongoDB
* Mongoose

### Authentication

* Firebase Authentication
* Firebase Admin SDK
* JWT

### AI

* Google Gemini API

### Backend Libraries

* Axios
* Joi
* bcryptjs
* jsonwebtoken
* Nodemailer
* dotenv
* CORS

### Development & Testing

* Jest
* Supertest
* ESLint
* Prettier
* Nodemon
* Postman

## Screenshots

### Dashboard

![Dashboard](Frontend%20Images/image.png)

### Workout Tracking

![Workout](Frontend%20Images/image%20\(1\).png)

### Workout Progress

![Workout Progress](Frontend%20Images/image%20\(2\).png)

### Exercise Tracking

![Exercise Tracking](Frontend%20Images/image%20\(3\).png)

### Nutrition

![Nutrition](Frontend%20Images/image%20\(4\).png)

### Nutrition Progress

![Nutrition Progress](Frontend%20Images/image%20\(5\).png)

### Analytics

![Analytics](Frontend%20Images/image%20\(2\)%20-%20Copy.png)

### AI Coach

![AI Coach](Frontend%20Images/image%20\(3\)%20-%20Copy.png)

### Progress Tracking

![Progress Tracking](Frontend%20Images/image%20\(4\)%20-%20Copy.png)

### Additional Screens

![Application Screen](Frontend%20Images/image%20-%20Copy.png)

## Backend Setup

Install the backend dependencies:

```bash
npm install
```

Create a `.env` file based on `.env.example` and configure the required environment variables.

Start the development server:

```bash
npm run dev
```

For production:

```bash
npm start
```

## Environment Variables

The backend requires configuration for:

```env
NODE_ENV=development
PORT=5000
MONGODB_URI=your_mongodb_connection_string
FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json
GEMINI_MODEL=gemini-3.7-flash
GEMINI_API_KEY=your_gemini_api_key
JWT_SECRET=your_jwt_secret
```

Do not commit `.env`, Firebase service-account private keys, or other credentials to the repository.

## Flutter Setup

Navigate to the Flutter application:

```bash
cd workout_logger
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Android APK

Build a release APK with:

```bash
flutter build apk --release
```

The generated APK can be found in the Flutter build output directory.

## Testing

Backend tests:

```bash
npm test
```

Lint the project:

```bash
npm run lint
```

Automatically fix supported lint issues:

```bash
npm run lint:fix
```

## API Testing

The repository includes Postman collections and environment configuration for testing the Workout Logger API.

Import the collection into Postman and configure the required environment values before making authenticated requests.

## Security

* Environment files are excluded through `.gitignore`
* Firebase Admin service-account credentials are not stored in the repository
* Database credentials should be supplied through environment variables
* JWT secrets are configured through environment variables
* API credentials should never be committed to source control

