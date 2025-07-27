// Firebase User

import 'package:firedart/firedart.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
import 'package:encrypt/encrypt.dart' as ee;
import 'package:email_validator/email_validator.dart';

const apiKey = "AIzaSyCjZK5ojHcJQh8Sr0sdMG0Nlnga4D94FME";
const projectId = "shopwise-86248";

class User {
  // Instance Variables
  String email;
  String password;
  String phNo;

  final key = "%D*G-JaNdRgUkXp2";

  // Constructor
  User({required this.email, this.password = "", this.phNo = ""});

  // -----------------------
  // ----- SET LOCATION ----
  // -----------------------
  Future<bool> setLocation(double lat, double lon) async {
    // set user location
    // return true if success
    // return false if failed
    // Function called to set location

    try {
      Firestore.instance.collection("appData");

      await Firestore.instance.collection("appData").document(email).set({
        "location": GeoPoint(lat, lon),
      });
      // Location set successfully
      return Future<bool>.value(true);
    } catch (e) {
      return Future<bool>.value(false);
    }
  }

// --------------------------
// ---- GET LOCATION --------
// --------------------------
  Future<Document> getLocation() async {
    // Getting the User Location if exists
    // return the document if exists
    if (await Firestore.instance.collection("appData").document(email).exists) {
      var data = Firestore.instance.collection("appData").document(email).get();

      // Process location data if needed

      return Future<Document>.value(data);
    } else {
      // No location data found for user
      throw Exception("No Data Found");
    }
  }

// --------------------------
// ---- REGISTER  -----------
// --------------------------
  Future<bool> register() async {
    // Registering the user

    if (await Firestore.instance.collection("appData").document(email).exists) {
      // User already exists in database
      return Future<bool>.value(false);
    } else {
      try {
        Firestore.instance.collection("appData");
        await Firestore.instance.collection("appData").document(email).set({
          "email": email,
          "password": password,
          "phNo": phNo,
        });
        // User registered successfully
        return Future<bool>.value(true);
      } catch (e) {
        return Future<bool>.value(false);
      }
    }
  }

// --------------------------
// ---- LOGIN  -----------
// --------------------------
  Future<bool> login() async {
    // Login the user

    if (await Firestore.instance.collection("appData").document(email).exists) {
      var data =
          await Firestore.instance.collection("appData").document(email).get();
      var password = decrypt(data["password"]);

      if (data["password"] == password) {
        // Login successful
        return Future<bool>.value(true);
      } else {
        // Incorrect password provided
        return Future<bool>.value(false);
      }
    } else {
      // User not found in database
      return Future<bool>.value(false);
    }
  }

// -------------------------
// --- PASSWORD ENCRYPTION--
// -------------------------

  String encrypt(String plainText) {
    // Encrypting the password
    // return the encrypted password
    final newKey =
        ee.Key.fromUtf8(key); // 32 bytes for AES-256, 16 bytes for AES-128
    final iv = ee.IV.fromLength(16);

    // Key generated for encryption

    final encrypter = ee.Encrypter(ee.AES(newKey));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  String decrypt(String encryptedText) {
    // Decrypting the password
    // return the decrypted password
    final newKey = ee.Key.fromUtf8(key);
    final iv = ee.IV.fromLength(16);

    final encrypter = ee.Encrypter(ee.AES(newKey));

    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }

// -------------------------
// -------- VALIDATION -----
// -------------------------

// Email Validation
  bool validateEmail() {
    // Validate the email
    // return true if valid
    // return false if invalid
    if (EmailValidator.validate(email)) {
      return true;
    } else {
      return false;
    }
  }

// Password Validation
  bool validatePassword(String password, [int minLength = 6]) {
    if (password.isEmpty) {
      return false;
    }
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasMinLength = password.length >= minLength;

    return hasDigits &
        hasUppercase &
        hasLowercase &
        hasMinLength;
  }
}
