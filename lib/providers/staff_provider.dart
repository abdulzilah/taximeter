import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaffProvider extends ChangeNotifier {
  bool isLoading = false;
  List<dynamic> staff = [];
  String? errorMessage;

  StaffProvider() {
    fetchStaff();
  }

  // Method to fetch staff data
  Future<void> fetchStaff() async {
    try {
      isLoading = true;
      notifyListeners();

      // Get the saved access token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("User not authenticated. Please log in.");
      }

      // Make the API request to get users (this is the correct endpoint)
      final url =
          'https://taximeter.onrender.com/users?page=1&limit=100'; // Adjust with the correct URL
      final response = await Dio().get(
        url,
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
        }),
      );

      print(
          "Response from API: ${response.data}"); // Debugging the full response

      if (response.statusCode == 200) {
        // Correctly reference 'users' from the response data
        List newStaff = response.data['users']
            .where((user) => user['role'] == 'ADMIN') // Filter by role 'ADMIN'
            .toList();

        print("Filtered staff: $newStaff"); // Debugging filtered staff

        staff = newStaff;
        errorMessage = null;
      } else {
        errorMessage = "Failed to fetch staff data. Please try again.";
      }
    } catch (e) {
      errorMessage = "An error occurred while fetching staff data.";
      print("Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Method to update a user's role and canEdit status
  Future<void> updateUser(
      {required String userId,
      required String role,
      required bool canEdit,
      context}) async {
    try {
      isLoading = true;
      notifyListeners();

      // Get the saved access token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception("User not authenticated. Please log in.");
      }

      // Make the API request to update the user
      final url = 'https://taximeter.onrender.com/auth/admin/update-user';
      final response = await Dio().patch(
        url,
        data: {
          'phoneNumber': userId,
          'role': role,
          'canEdit': canEdit,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
        }),
      );

      print("Updated user: $response"); // Debugging updated user

      if (response.statusCode == 200) {
        // Update was successful, fetch the staff again to reflect the changes
        await fetchStaff();
        errorMessage = null;
      } else {
        errorMessage = "Failed to update user. Please try again.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid phone number')),
        );
      }
    } catch (e) {
      errorMessage = "An error occurred while updating the user.";
      print("Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
