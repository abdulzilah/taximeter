import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  Future<String?> initiateCheckout({
    required String amount,
    required String gateway,
    required String currency,
    required String phoneNumber,
  }) async {
    try {
      // Set up Dio with headers
      Dio dio = Dio();

      // Prepare request body
      final data = {
        'phoneNumber': phoneNumber,
        'amount': amount,
        'gateway': gateway,
        'currency': currency,
      };

      // Send POST request
      final response = await dio.post(
        'https://taximeter.onrender.com/payment/checkout',
        data: data,
      );

      // Check for successful response
      if (response.statusCode == 201) {
        // Parse and return the redirectUrl
        String redirectUrl = response.data['redirectUrl'];
        return redirectUrl;
      } else {
        throw Exception(
            "Failed to initiate checkout. Status code: ${response}");
      }
    } catch (e) {
      print("Error initiating checkout: $e");
      return null;
    }
  }
}
