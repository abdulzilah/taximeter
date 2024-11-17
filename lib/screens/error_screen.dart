import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ErrorScreen extends StatelessWidget {
  final String errorMessage;

  // Constructor to pass the error message
  ErrorScreen({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error description
              Text(
                'An error occurred:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
              SizedBox(height: 20),

              // Button to close and restart the app
              ElevatedButton(
                onPressed: () {
                  // Close the app using SystemNavigator.pop()
                  SystemNavigator.pop();
                },
                child: Text('Restart App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
