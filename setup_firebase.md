# Firebase Setup Guide for Your Flutter App

## Current Issue
Your app is failing during registration because of Firebase permission errors. This happens because:

1. **No Firebase Configuration**: Missing `google-services.json` and proper Firebase initialization
2. **Package Conflicts**: Using both `firedart` (desktop) and `firebase_core` (mobile)
3. **No Authentication**: Firebase requires proper authentication setup

## Solution Steps

### Step 1: Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your existing project `shopwise-86248` OR create a new one
3. Click "Project Settings" (gear icon)
4. In the "Your apps" section, click "Add app" → Android
5. Follow these steps:
   - **Package name**: `com.example.mobile` (from your AndroidManifest.xml)
   - **App nickname**: Your app name
   - **SHA-1**: Optional for now
   - Download `google-services.json`

### Step 2: Add Firebase Configuration Files

1. **For Android**: Copy `google-services.json` to `android/app/` folder
2. **Update build.gradle files**:

**android/build.gradle.kts:**
```kotlin
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'  // Add this line
}
```

**android/app/build.gradle.kts:**
```kotlin
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id 'com.google.gms.google-services'  // Add this line
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation 'com.google.firebase:firebase-analytics-ktx'  // Add this
}
```

### Step 3: Update pubspec.yaml

Replace Firebase dependencies with proper ones:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Remove firedart - it's for desktop only
  # firedart: ^0.9.0+1
  
  # Keep these Firebase packages
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3  # Add for authentication
  cloud_firestore: ^4.13.6  # Add for Firestore database
  
  # Remove firebase_database if using Firestore
  # firebase_database: ^10.4.0
```

### Step 4: Update Firebase Service

Replace `lib/services/firebase_database.dart` with proper Firebase implementation:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register new user
  Future<bool> register(String email, String name, String phoneNumber, String password) async {
    try {
      // Create user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return false; // Email already exists
      }
      throw e; // Other errors
    } catch (e) {
      throw e;
    }
  }

  // Login user
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
```

### Step 5: Update main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_project/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}
```

### Step 6: Setup Firestore Security Rules

In Firebase Console → Firestore Database → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow authenticated users to read products
    match /products/{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null; // Adjust as needed
    }
  }
}
```

### Step 7: Run Flutter Commands

```bash
flutter clean
flutter pub get
flutter run
```

## Alternative: Quick Local Database Solution

If you want to avoid Firebase complexity for now, you can implement local storage:

1. Add `sqflite` package for local database
2. Replace Firebase calls with local database operations
3. This won't require internet connection but data won't sync across devices

Would you like me to implement the local database solution instead?
