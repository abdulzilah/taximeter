import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taximeter_project/screens/signup_screen.dart';

class AuthProvider extends ChangeNotifier {
  String? successMessage;
  String? errorMessage;
  bool isLoading = false;
  bool isAdmin = false; // Track if user is admin
  bool canEdit = false; // Track if user is admin

  // Method to send OTP to the phone number
  Future<void> sendOtp(String phoneNumber) async {
    try {
      isLoading = true;
      notifyListeners();

      // API request to send OTP
      final response = await Dio().post(
        'https://taximeter.onrender.com/auth/sendOTP',
        data: {
          'phoneNumber': phoneNumber,
        },
      );

      // Parse the response
      if (response.statusCode == 200 && response.data['success'] == true) {
        successMessage = response.data['message']; // OTP sent successfully
        errorMessage = null;
      } else {
        successMessage = null;
        errorMessage =
            response.data['message'] ?? "Failed to send OTP. Please try again.";
      }
    } catch (e) {
      successMessage = null;
      errorMessage =
          "An error occurred. Please check your network and try again.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

// Method to verify OTP and navigate based on registration status
  Future<void> verifyOtp(
      BuildContext context, String phoneNumber, String otp) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await Dio().post(
        'https://taximeter.onrender.com/auth/verify-otp',
        data: {
          'phoneNumber': phoneNumber,
          'code': otp,
        },
      );
      print("otp response: $response");

      if (response.data['message'].toString().contains("verified")) {
        successMessage = response.data['message'];
        errorMessage = null;

        bool isRegistered = response.data['isRegistered'] ?? false;
        print("otp registered: $isRegistered");

        if (isRegistered) {
          // Save accessToken in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', response.data['accessToken']);

          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => SignUpScreen(
                        phoneNumber: phoneNumber,
                      )));
        }
      } else {
        successMessage = null;
        errorMessage = "Invalid OTP. Please try again.";
      }
    } catch (e) {
      print("otp response: $e");

      successMessage = null;
      errorMessage = "An error occurred. Please try again.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic>? userProfile;

  Future<void> signUp(
    BuildContext context,
    String phoneNumber,
    String name,
    String plateNumber,
    File driverLicense,
  ) async {
    try {
      isLoading = true;
      notifyListeners();

      // Prepare form data with file upload
      FormData formData = FormData.fromMap({
        'phoneNumber': phoneNumber,
        'name': name,
        'plateNumber': plateNumber,
        'driverLicense': await MultipartFile.fromFile(
          driverLicense.path,
          filename: driverLicense.path.split('/').last,
        ),
      });

      final response = await Dio().post(
        'https://taximeter.onrender.com/auth/signup',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        // Successful signup
        successMessage = "User registered successfully.";
        errorMessage = null;
        Navigator.pushReplacementNamed(context, '/home');
      } else if (response.statusCode == 400) {
        // Failed to upload driver license
        successMessage = null;
        errorMessage = "Failed to upload driver license.";
      } else if (response.statusCode == 403) {
        // User already exists
        successMessage = null;
        errorMessage =
            "User with this phone number or plate number already exists.";
      } else {
        // Generic error message for other cases
        successMessage = null;
        errorMessage = "Sign up failed. Please try again.";
      }
    } catch (e) {
      print("Sign up error: $e");
      successMessage = null;
      errorMessage = "An error occurred. Please try again.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Fetch user profile
  Future<void> fetchUserProfile() async {
    print("in fetching");
    try {
      isLoading = true;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw Exception("User not authenticated. Please log in.");
      }

      final response = await Dio().get(
        'https://taximeter.onrender.com/auth/profile',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      print(response);
      if (response.statusCode == 200) {
        userProfile = response.data;
        isAdmin = userProfile?['role'] == 'ADMIN'; // Check admin status
        canEdit = userProfile?['canEdit'];
        errorMessage = null;
      } else {
        errorMessage = "Failed to fetch user profile.";
      }
    } catch (e) {
      errorMessage = "An error occurred while fetching user profile.";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears saved tokens and session data

    // Navigate to the onboarding screen
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  Future<void> _saveToken(String accessToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
  }

  Future<bool> isUserSignedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('accessToken');
  }
}
