import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _trips = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  String? _errorMessage;
  bool _isFetchingNextPage = false;
  int _currentPage = 1;
  final int _pageSize = 10; // Customize the page size as needed

  List<Map<String, dynamic>> get trips => _trips;
  bool get isLoading => _isLoading;
  bool get hasMoreData => _hasMoreData;
  String? get errorMessage => _errorMessage;
  bool get isFetchingNextPage => _isFetchingNextPage;

  // Method to reset the history when refreshing
  void resetHistory() {
    _trips.clear();
    _currentPage = 1;
    _hasMoreData = true;
    notifyListeners();
  }

  // Fetch trips from the API for user
  Future<void> fetchTripsRegularUser() async {
    if (_isLoading || (!_hasMoreData && _trips.isNotEmpty)) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Retrieve the access token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        _errorMessage = "Access token is missing. Please log in again.";
        return;
      }

      // Set up the Dio instance with the authorization header
      final dio = Dio();
      dio.options.headers["Authorization"] = "Bearer $accessToken";

      // Make the API request
      final response = await dio.get(
        'https://taximeter.onrender.com/trips/my-trips?page=$_currentPage&limit=$_pageSize',
      );

      if (response.statusCode == 200) {
        var data = response.data['data'] as List;

        // Add new data to the existing list
        if (data.isNotEmpty) {
          _trips.addAll(data.map((trip) => trip as Map<String, dynamic>));
          _currentPage++;
        }

        // Check if more data is available
        _hasMoreData = data.length == _pageSize;
      } else {
        _errorMessage = "Failed to load trips. Please try again later.";
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch trips from the API for admin
  Future<void> fetchTrips() async {
    if (_isLoading || (!_hasMoreData && _trips.isNotEmpty))
      return; // Prevent fetching if loading or no more data

    _isLoading = true;
    notifyListeners();

    try {
      // Simulating an API request with a delay
      final response = await Dio().get(
        'https://taximeter.onrender.com/trips?page=$_currentPage&limit=$_pageSize',
      );

      if (response.statusCode == 200) {
        var data = response.data['data'] as List;

        // Add new data to the existing list
        if (data.isNotEmpty) {
          _trips.addAll(data.map((trip) => trip as Map<String, dynamic>));
          _currentPage++;
        }

        // Check if more data is available
        _hasMoreData = data.length == _pageSize;
      } else {
        _errorMessage = "Failed to load trips. Please try again later.";
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to load the next page for pagination
  Future<void> loadNextPage() async {
    if (_isFetchingNextPage || !_hasMoreData)
      return; // Prevent multiple page fetches

    _isFetchingNextPage = true;
    notifyListeners();

    try {
      await fetchTrips();
    } catch (e) {
      _errorMessage = "Failed to load more trips: $e";
    } finally {
      _isFetchingNextPage = false;
      notifyListeners();
    }
  }

  // Search trips based on the query
  List<Map<String, dynamic>> searchTrips(String query, String searchType) {
    if (query.isEmpty) return _trips;

    return _trips.where((trip) {
      switch (searchType) {
        case 'city':
          return trip['city'].toLowerCase().contains(query.toLowerCase());
        case 'plateNumber':
          return trip['plateNumber']
              .toLowerCase()
              .contains(query.toLowerCase());
        case 'name':
        default:
          return trip['name'].toLowerCase().contains(query.toLowerCase());
      }
    }).toList();
  }
}

class TripUpdater {
  final Dio _dio = Dio();

  Future<void> updateTrip({
    required int tripId,
    required String duration,
    required double distance,
    required String city,
    required int fees,
    required int waitTime,
  }) async {
    try {
      // Retrieve token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        throw Exception("No access token found. Please log in again.");
      }

      // Set authorization header
      _dio.options.headers["Authorization"] = "Bearer $accessToken";

      // Make the API call to update the trip
      final response = await _dio.put(
        'https://taximeter.onrender.com/trips/$tripId',
        data: {
          "id": tripId,
          "duration": duration,
          "distance": distance,
          "city": city,
          "fees": fees,
          "waitTime": waitTime,
        },
      );

      if (response.statusCode == 200) {
        print("Trip updated successfully.");
      } else {
        print("Failed to update trip: ${response.statusCode}");
      }
    } catch (e) {
      print("An error occurred while updating the trip: $e");
    }
  }
}
