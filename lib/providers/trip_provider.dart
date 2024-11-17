import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripsProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;

  // List to store the available cities
  List<String> availableCities = [];

  // Method to fetch available cities from the settings API with pagination support
  Future<void> fetchAvailableCities() async {
    try {
      isLoading = true;
      notifyListeners();

      List<String> cities = [];
      int page = 1;
      int limit = 100; // Increase the limit if necessary

      while (true) {
        final url =
            'https://taximeter.onrender.com/setting?page=$page&limit=$limit';
        final response = await Dio().get(url);

        if (response.statusCode == 200) {
          List settings = response.data['Settings'];

          // Extract city names and add them to the list
          cities.addAll(settings.map((setting) => setting['city'] as String));

          // Check if there's another page
          if (response.data['numPage'] > page) {
            page++; // Move to the next page
          } else {
            break; // No more pages
          }
        } else {
          errorMessage = "Failed to fetch cities. Please try again.";
          break;
        }
      }

      // Update the available cities list
      availableCities = cities;
      errorMessage = null;
    } catch (e) {
      errorMessage = "An error occurred while fetching cities.";
      print("Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

// Method to create a trip
  Future<void> createTrip({
    required String duration,
    required double distance,
    required String city,
    required double fees,
    required int waitTime,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw Exception("User not authenticated. Please log in.");
      }

      final url = 'https://taximeter.onrender.com/trips';
      final data = {
        'duration': duration,
        'distance': distance,
        'city': city,
        'fees': fees,
        'waitTime': waitTime,
      };

      final response = await Dio().post(
        url,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      print(response.statusCode);
      if (response.statusCode == 201) {
        // Check if the response message contains the word "successfully" (case-insensitive)
        if (response.data['message'].toString() ==
            "Trip created successfully") {
          successMessage = "Trip created successfully!";
          errorMessage = null;
        } else {
          successMessage = null;
          errorMessage = "Failed to create the trip. Please try again.";
        }
      }
    } catch (e) {
      successMessage = null;
      errorMessage = "An error occurred while creating the trip.";
      print("Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
