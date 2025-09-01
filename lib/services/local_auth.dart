import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LocalAuthService {
  static const String _credentialsPath = 'assets/local_credentials.json';
  
  // Load and parse the local credentials JSON file
  static Future<Map<String, dynamic>> _loadCredentials() async {
    try {
      final String jsonString = await rootBundle.loadString(_credentialsPath);
      return json.decode(jsonString);
    } catch (e) {
      debugPrint('Error loading local credentials: $e');
      return {};
    }
  }
  
  // Check if the provided credentials match the local user
  static Future<bool> checkLocalCredentials(String email, String password) async {
    try {
      final Map<String, dynamic> credentials = await _loadCredentials();
      
      if (credentials.containsKey('local_user')) {
        final localUser = credentials['local_user'];
        return localUser['email'] == email && localUser['password'] == password;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error checking local credentials: $e');
      return false;
    }
  }
  
  // Get the local user email
  static Future<String?> getLocalUserEmail() async {
    try {
      final Map<String, dynamic> credentials = await _loadCredentials();
      
      if (credentials.containsKey('local_user')) {
        return credentials['local_user']['email'];
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting local user email: $e');
      return null;
    }
  }
}
