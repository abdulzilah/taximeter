import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'https://taximeter.onrender.com';

  Future<void> sendOtp(String phoneNumber) async {
    final url = Uri.parse('$baseUrl/auth/sendOTP');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      if (response.statusCode == 200) {
        print('OTP sent successfully');
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Failed to send OTP: ${error['message']}');
      }
    } catch (e) {
      throw Exception('Error sending OTP: $e');
    }
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    final url = Uri.parse('$baseUrl/auth/verify-otp');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        print('OTP verified successfully');
      } else {
        final error = jsonDecode(response.body);
        throw Exception('OTP verification failed: ${error['message']}');
      }
    } catch (e) {
      throw Exception('Error verifying OTP: $e');
    }
  }
}
