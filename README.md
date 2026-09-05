<div align="center">

<img src="assets/logo/logo.png" alt="CodeVerse" width="140"/>

# CodeVerse

**Discover the Magic of Coding!**

An AI-powered mobile application that teaches programming concepts to children
aged 8–12 through personalised, generated stories and interactive quizzes.

![Flutter](https://img.shields.io/badge/Flutter-3.22.3-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.4.4-0175C2?logo=dart&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.12.3-3776AB?logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-3.1.0-000000?logo=flask&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?logo=firebase&logoColor=black)
![Gemini](https://img.shields.io/badge/Google-Gemini%20API-4285F4?logo=google&logoColor=white)

</div>

---

## Table of Contents

- [About](#about)
- [Screenshots](#screenshots)
- [Features](#features)
- [System Architecture](#system-architecture)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [1. Clone the repository](#1-clone-the-repository)
  - [2. Firebase setup](#2-firebase-setup)
  - [3. Backend setup](#3-backend-setup)
  - [4. Flutter setup](#4-flutter-setup)
  - [5. Running the application](#5-running-the-application)
- [Data Model](#data-model)

---

## About

Learning to program is difficult for young children because most introductory
material is abstract. CodeVerse addresses this by wrapping each concept in a
narrative: a child chooses a programming concept and a story genre, and the
application generates a personalized story in which a character solves a problem
using that concept. A five-question quiz then checks comprehension, with hints
available if the child gets stuck, and points contribute to a leaderboard.

The application covers four foundational concepts:

| Concept | What it teaches |
|---|---|
| **Sequence** | Doing things step by step, in order |
| **Loops** | Repeating actions |
| **Conditionals** | Choosing what happens next |
| **Variables** | Keeping track of information |

and four narrative genres: **Adventure**, **Fantasy**, **Fairy Tales** and
**Mystery**.

---

## Screenshots

### Onboarding and Authentication

| Splash | Onboarding I | Onboarding II |
|:---:|:---:|:---:|
| <img src="docs/screenshots/Splash Screen.png" width="220"/> | <img src="docs/screenshots/On Boarding Screen I.png" width="220"/> | <img src="docs/screenshots/On Boarding Screen II.png" width="220"/> |

| Onboarding III | Welcome | Login |
|:---:|:---:|:---:|
| <img src="docs/screenshots/On Boarding Screen III.png" width="220"/> | <img src="docs/screenshots/Welcome Screen.png" width="220"/> | <img src="docs/screenshots/Login Screen.png" width="220"/> |

| Sign Up | Email Verification | Logout |
|:---:|:---:|:---:|
| <img src="docs/screenshots/Signup Screen.png" width="220"/> | <img src="docs/screenshots/Email Verification Screen.png" width="220"/> |<img src="docs/screenshots/Logout Confirmation Message Screen.png" width="220"/> |

| Forget Password | Password Reset via Email | Password Reset via Contact |
|:---:|:---:|:---:|
| <img src="docs/screenshots/Forget Password Screen.png" width="220"/> | <img src="docs/screenshots/Forget Password - Email Screen.png" width="220"/> | <img src="docs/screenshots/Forget Password - Contact Screen.png" width="220"/> |

### Core Experience

| Dashboard | Category Stories | Category Stories |
|:---:|:---:|:---:|
| <img src="docs/screenshots/Dashboard Screen.png" width="220"/> | <img src="docs/screenshots/Sequence Stories.png" width="220"/> | <img src="docs/screenshots/Loops Stories.png" width="220"/> |

| Category Stories | Category Stories | Create Story I |
|:---:|:---:|:---:|
| <img src="docs/screenshots/Conditionals Stories.png" width="220"/> | <img src="docs/screenshots/Variables Stories.png" width="220"/> | <img src="docs/screenshots/Concept Question Screen.png" width="220"/> |

| Create Story II | Loading Story | Generated Story |
|:---:|:---:|:---:|
| <img src="docs/screenshots/Genre Question Screen.png" width="220"/> | <img src="docs/screenshots/Loading Screen.png" width="220"/> | <img src="docs/screenshots/Story Screen.png" width="220"/> |

| Quiz Screen | Question with Hint | Quiz Result |
|:---:|:---:|:---:|
| <img src="docs/screenshots/Question Screen.png" width="220"/> | <img src="docs/screenshots/Question With Hint Screen.png" width="220"/> | <img src="docs/screenshots/Marks Screen.png" width="220"/> |

| Review Answers I | Review Answers II | Leaderboard |
|:---:|:---:|:---:|
| <img src="docs/screenshots/Review Quiz Screen I.png" width="220"/> | <img src="docs/screenshots/Review Quiz Screen II.png" width="220"/> | <img src="docs/screenshots/Leaderboard Screen.png" width="220"/> |

### Profile

| Profile | Edit Profile | Delete Profile |
|:---:|:---:|:---:|
| <img src="docs/screenshots/Profile Screen.png" width="220"/> | <img src="docs/screenshots/Update Profile Screen.png" width="220"/> | <img src="docs/screenshots/Profile Delete Confirmation Message Screen.png" width="220"/> |

---

## Features

**Story generation**
- Original stories generated on demand from a chosen concept and genre
- The concept drives the plot; the character solves a real problem using it
- Text-to-speech playback so early readers can listen along

**Comprehension quiz**
- Five multiple-choice questions generated from each story
- A hint appears automatically if a question is unanswered after 60 seconds
- Score summary with an answer review showing correct and incorrect answers with chosen options

**Progress and motivation**
- Points accumulate across quizzes
- Leaderboard ranking all users, with the current user highlighted

**Accounts**
- Email/password registration with email verification
- Google Sign-In
- Password reset by email
- Profile management

**Library**
- Stories grouped into four concept categories
- Every story the user has generated is saved and re-readable

---

## System Architecture

```
┌──────────────────────────────┐
│      Flutter Application     │
│                              │
│  Screens ──> GetX Controllers│
│                   │          │
│                   v          │
│            Repositories      │
└──────┬───────────────┬───────┘
       │               │
       │ HTTP POST     │ Firebase SDK
       │               │
       v               v
┌──────────────┐  ┌──────────────────────┐
│ Flask Backend│  │  Firebase            │
│              │  │  - Authentication    │
│  /generate_  │  │  - Cloud Firestore   │
│    story     │  └──────────────────────┘
│      │       │            ^
│      v       │            │
│  Gemini API  │  Admin SDK │
│              ├────────────┘
└──────────────┘
```

**Request flow for generating a story**

1. The child selects a concept and a genre in the Flutter app.
2. The app posts to `POST /generate_story` with the concept, genre and their
   email address.
3. The backend makes four sequential calls to the Gemini API: story, title,
   quiz questions, then all hints in one batch.
4. The backend parses the quiz text into structured questions, options and
   answers, writes the whole record to Firestore, and returns it as JSON.
5. The app renders the story and, on request, the quiz.

---

## Technology Stack

| Layer | Technology |
|---|---|
| Mobile client | Flutter, Dart |
| State management | GetX |
| Backend | Python, Flask |
| AI | Google Gemini API (`google-generativeai`) |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| Speech | `flutter_tts` |

---

## Project Structure

```
codeverse/
├── backend/                       Flask API
│   ├── app.py                     Endpoints, generation, parsing
│   ├── requirements.txt
│   ├── .env.example               Template - copy to .env
│   └── serviceAccountKey.json     NOT committed; see setup
│
├── lib/
│   ├── main.dart                  Entry point, Firebase init
│   ├── firebase_options.dart      Generated by FlutterFire CLI
│   └── src/
│       ├── common_widgets/        Shared UI components
│       ├── constants/             Colours, sizes, strings, image paths
│       ├── features/
│       │   ├── authentication/    Login, signup, OTP, onboarding
│       │   │   ├── controllers/
│       │   │   ├── models/
│       │   │   └── screens/
│       │   └── core/              Dashboard, stories, quiz, profile
│       │       ├── controllers/
│       │       └── screens/
│       ├── repository/            Firebase data access
│       │   ├── authentication_repository/
│       │   └── user_repository/
│       ├── services/              User score updates
│       └── utils/                 Theme, validators, notifications
│
├── assets/
│   ├── images/                    Story covers, onboarding, profile
│   └── logo/                      App logo and icon
│
├── docs/screenshots/              Screenshots used in this README
└── android/  ios/                 Platform projects
```

---

## Getting Started

### Prerequisites

| Requirement | Version |
|---|---|
| Flutter SDK | 3.22.3 or later |
| Dart SDK | 3.4.4 (bundled with Flutter) |
| Python | 3.10 or later |
| Android Studio / Xcode | For emulator or device builds |
| Google account | For Firebase and the Gemini API |

Verify Flutter is ready:

```bash
flutter doctor
```

### 1. Clone the repository

```bash
git clone https://github.com/jenshikaj/CodeVerse-story-based-programming-app-for-kids.git
cd CodeVerse
```

### 2. Firebase setup

This project needs your own Firebase project; no credentials are included.

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com).

2. Enable **Authentication** and turn on the **Email/Password** and **Google**
   sign-in providers.

3. Create a **Cloud Firestore** database.

4. Register an Android app. The package name must match `applicationId` in
   `android/app/build.gradle`.

5. Add your **SHA-1 fingerprint** to the Android app — Google Sign-In fails
   silently without it:

   ```bash
   cd android
   ./gradlew signingReport      # .\gradlew signingReport on Windows
   ```

   Copy the SHA1 under `Variant: debug`.

6. Generate the Flutter configuration:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   This writes `lib/firebase_options.dart` and `android/app/google-services.json`.

7. Download a service account key for the backend:
   **Project settings → Service accounts → Generate new private key**.
   Save it as `backend/serviceAccountKey.json`.

### 3. Backend setup

```bash
cd backend
python -m venv venv

# Windows
venv\Scripts\activate
# macOS / Linux
source venv/bin/activate

pip install -r requirements.txt
```

Get a Gemini API key from [aistudio.google.com/apikey](https://aistudio.google.com/apikey),
then create `backend/.env` from the template:

```env
GEMINI_API_KEY=your_key_here
GEMINI_MODEL=gemini-3.5-flash
```

Start the server:

```bash
python app.py
```

Confirm it is running in Postman and check which model it is using:

```
GET http://127.0.0.1:5000/health
```

### 4. Flutter setup

```bash
flutter pub get
```

### 5. Running the application

With the backend running in one terminal:

```bash
flutter run
```

---

## Data Model

### `Users` collection

| Field | Type | Notes |
|---|---|---|
| `Email` | string | Matches the Firebase Auth email; used for lookups |
| `FullName` | string | Full Name|
| `Phone` | string | Contact Number|
| `ProfileImage` | string | Base64-encoded image, or empty |
| `Score` | number | Cumulative quiz points |
| `CreatedAt` | timestamp | Account Created Date and Time |

### `stories` collection

| Field | Type | Notes |
|---|---|---|
| `title` | string | Story Title |
| `story` | string | Full narrative text |
| `mcqs` | string | Multiple Choices of Questions |
| `questions` | array | Questions |
| `hints` | array | Hints for each generated question |
| `concept` | string | Used to group stories on the dashboard |
| `genre` | string | Story Genre |
| `language` | string | English |
| `email` | string | User email |
| `created_at` | timestamp | Story Created Date and Time |

---

**Author:** Jenshika J | 
**Role:** Associate Software Engineer | 
**Year:** 2025 |

<div align="center">
Happy Coding!
</div>
