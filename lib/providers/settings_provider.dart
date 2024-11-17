import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;
  List<Map<String, dynamic>> settingsList = [];
  Map<String, dynamic>? selectedSettings;

  double calculateFare({
    required double duration,
    required double distance,
    required double waitTime,
  }) {
    if (selectedSettings == null) return 0.0;

    int baseFare = selectedSettings!['baseFarePrice'] ?? 0.0;
    int baseDuration = selectedSettings!['baseDuration'] ?? 0.0;
    int baseDistance = selectedSettings!['baseDistance'] ?? 0.0;
    int baseWait = selectedSettings!['baseWait'] ?? 0.0;
    int pricePerMin = selectedSettings!['pricePerMin'] ?? 0.0;
    int pricePerKm = selectedSettings!['pricePerKm'] ?? 0.0;

    double durationFare = (duration > baseDuration)
        ? (duration - baseDuration) * pricePerMin
        : 0.0;

    double distanceFare = (distance > baseDistance)
        ? (distance - baseDistance) * pricePerKm
        : 0.0;

    double waitingFare =
        (waitTime > baseWait) ? (waitTime - baseWait) * pricePerMin : 0.0;

    double totalFare = baseFare + durationFare + distanceFare + waitingFare;
    print(totalFare);
    return totalFare;
  }

  // Fetch settings
  Future<void> fetchSettings() async {
    try {
      isLoading = true;
      notifyListeners();

      // Get the saved access token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw Exception("User not authenticated. Please log in.");
      }

      // API endpoint for settings
      final url = 'https://taximeter.onrender.com/setting?page=1&limit=100';

      // Make the API request
      final response = await Dio().get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken', // Authorization header
          },
        ),
      );

      if (response.statusCode == 200) {
        // Parse the response data
        List<Map<String, dynamic>> fetchedSettings =
            List<Map<String, dynamic>>.from(response.data['Settings']);
        settingsList = fetchedSettings;
        selectedSettings = settingsList.isNotEmpty ? settingsList[0] : null;
        errorMessage = null;
      } else {
        errorMessage = "Failed to fetch settings. Please try again.";
      }
    } catch (e) {
      errorMessage = "An error occurred while fetching settings.";
      print("Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Method to create new settings
  Future<void> createSettings(Map<String, dynamic> newData, context) async {
    try {
      // Ensure newData is not null and contains the necessary data
      if (newData == null || newData.isEmpty) {
        errorMessage = "No data provided to create new settings.";
        notifyListeners();
        return;
      }

      isLoading = true;
      notifyListeners();

      // Get the access token from your auth provider or wherever it's stored
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      // Ensure the access token is available
      if (accessToken == null) {
        errorMessage = "User not authenticated. Please log in.";
        notifyListeners();
        return;
      }

      // Define the request body as per the provided structure
      Map<String, dynamic> requestBody = {
        'country': newData['country'],
        'city': newData['city'],
        'baseFarePrice': newData['baseFarePrice'],
        'baseDuration': newData['baseDuration'],
        'currency': newData['currency'],
        'subscriptionFees': newData['subscriptionFees'],
        'pricePerMin': newData['pricePerMin'],
        'pricePerKm': newData['pricePerKm'],
        'baseWait': newData['baseWait'],
        'baseDistance': newData['baseDistance'],
      };
      print("Request Body for creating settings: $requestBody");

      // Make the API request to create new settings with the access token in the header
      final response = await Dio().post(
        'https://taximeter.onrender.com/setting',
        data: requestBody,
        options: Options(
          headers: {
            'Authorization':
                'Bearer $accessToken', // Add the access token to the headers
          },
        ),
      );

      if (response.statusCode == 200) {
        // Assuming the API returns the created setting in the response
        Map<String, dynamic> createdSetting = response.data['Setting'];
        settingsList.add(
            createdSetting); // Add the newly created setting to the settings list
        errorMessage = null;
      } else {
        errorMessage = "Failed to create settings.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a valid phone number')),
        );
      }
    } catch (e) {
      errorMessage = "An error occurred while creating settings.";
      print("Error: $e");
    } finally {
      await fetchSettings();
      isLoading = false;
      notifyListeners();
    }
  }

  // Edit settings data
  Future<void> editSettings(Map<String, dynamic> updatedData) async {
    try {
      // Ensure updatedData is not null and contains the necessary data
      if (updatedData == null || updatedData.isEmpty) {
        errorMessage = "No data provided to update.";
        notifyListeners();
        return;
      }

      isLoading = true;
      notifyListeners();

      // Get the access token from your auth provider or wherever it's stored
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      // Define the request body as per the provided structure
      Map<String, dynamic> requestBody = {
        'id': updatedData['id'],
        'country': updatedData['country'],
        'city': updatedData['city'],
        'baseFarePrice': updatedData['baseFarePrice'],
        'baseDuration': updatedData['baseDuration'],
        'currency': updatedData['currency'],
        'subscriptionFees': updatedData['subscriptionFees'],
        'pricePerMin': updatedData['pricePerMin'],
        'pricePerKm': updatedData['pricePerKm'],
        'baseWait': updatedData['baseWait'],
      };
      print(requestBody);

      // Make the API request to update the settings with the access token in the header
      final response = await Dio().put(
        'https://taximeter.onrender.com/setting',
        data: requestBody,
        options: Options(
          headers: {
            'Authorization':
                'Bearer $accessToken', // Add the access token to the headers
          },
        ),
      );
      print('response data is : $response');
      if (response.statusCode == 200) {
        // Log the entire response to debug
        print('Response data: ${response.data}');

        // Check if 'Setting' exists in the response
        if (response.data != null && response.data['Setting'] != null) {
          // Update the local settings list with the updated data
          int index = settingsList
              .indexWhere((setting) => setting['id'] == updatedData['id']);
          if (index != -1) {
            settingsList[index] = response
                .data['Setting']; // Use 'Setting' instead of 'updatedSetting'
          }
          errorMessage = null;
        } else {
          errorMessage = "No updated settings returned from the API.";
        }
      } else {
        errorMessage = "Failed to update settings.";
      }
    } catch (e) {
      errorMessage = "An error occurred while updating settings.";
      print("Error: $e");
    } finally {
      await fetchSettings();
      isLoading = false;
      notifyListeners();
    }
  }

  // Set the selected city for the settings
  void setSelectedCity(String city) {
    selectedSettings = settingsList
        .firstWhere((setting) => setting['city'] == city, orElse: () => {});
    notifyListeners();
  }

  // Get a list of cities for dropdown
  List<String> getAvailableCities() {
    return settingsList
        .map((setting) => setting['city'] as String)
        .toList(); // Return list of cities
  }

  Map<String, dynamic>? getSelectedCityDetails([String? city]) {
    // Find the settings for the provided city or use selectedSettings if no city is provided
    Map<String, dynamic>? citySettings = city != null
        ? settingsList.firstWhere(
            (setting) => setting['city'] == city,
            orElse: () => {},
          )
        : selectedSettings;

    if (citySettings == null || citySettings.isEmpty) {
      return null; // Return null if no settings found for the specified city
    }
    return {
      'subscriptionFee': citySettings['subscriptionFees'],
      'currency': citySettings['currency'],
    };
    
  }

  // Get selected settings data
  Map<String, dynamic>? getSelectedSettings() {
    return selectedSettings;
  }
}
