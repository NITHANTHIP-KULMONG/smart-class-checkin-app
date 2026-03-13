# Smart Class Check-in App

Smart Class Check-in is a web-based application built with Flutter that allows students to check in before class and submit feedback after class.
The system verifies attendance using QR code scanning and GPS location, and stores data in Firebase Firestore.

## Live Demo

https://smart-class-checkin-app.web.app/

## Features

### 1. Student Check-in (Before Class)

Students can perform the following actions before class starts:

* Scan QR Code to verify attendance
* Capture GPS location
* Record check-in timestamp
* Enter previous class topic
* Enter expected topic for today
* Select mood level (1–5)

All check-in data is saved to Firebase Firestore.

### 2. Finish Class (After Class)

After the class session, students can:

* Scan QR Code again
* Capture GPS location
* Submit reflection about what they learned
* Provide feedback about the class

All reflection data is stored in Firebase Firestore.

## Technologies Used

* Flutter (Web Application)
* Firebase Core
* Cloud Firestore
* Mobile Scanner (QR Code scanning)
* Geolocator (GPS location)
* Material 3 UI

## Project Structure

lib/

* main.dart (Application entry point)
* home_screen.dart (Main menu screen)
* checkin_screen.dart (Before class check-in)
* finish_screen.dart (After class reflection)

## Installation

1. Clone the repository

```
git clone https://github.com/NITHANTHIP-KULMONG/smart-class-checkin-app.git
```

2. Navigate to the project directory

```
cd smart-class-checkin-app
```

3. Install dependencies

```
flutter pub get
```

4. Run the application

```
flutter run
```

For web version:

```
flutter run -d chrome
```

## Build for Web

To build the project for production:

```
flutter build web
```

## Firebase Deployment

Deploy the web app using Firebase Hosting:

```
firebase deploy
```

## Firestore Collections

The application stores data in the following collections:

### checkins

Stores student check-in data before class.

Example fields:

* qrCode
* latitude
* longitude
* timestamp
* previousClassTopic
* expectedTopicToday
* mood
* createdAt

### finish_class

Stores reflection and feedback after class.

Example fields:

* qrCode
* latitude
* longitude
* whatDidYouLearnToday
* feedbackAboutClass
* submittedAt
* createdAt

## Author

Nithanthip Kulmong – Smart Class Check-in System
StudentID - 6731503018