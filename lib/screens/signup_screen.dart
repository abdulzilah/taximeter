import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:taximeter_project/providers/auth_provider.dart';
import 'package:taximeter_project/utils/colors.dart';
import 'package:taximeter_project/utils/custom_widgets.dart';

class SignUpScreen extends StatefulWidget {
  final String phoneNumber;

  // Accept the phone number as a parameter from the previous screen
  SignUpScreen({required this.phoneNumber});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  File? _driverLicenseFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickLicenseImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _driverLicenseFile = File(pickedFile.path);
      });
    }
  }

  void _submitSignUp() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check for required fields
    if (_nameController.text.isNotEmpty &&
        _plateNumberController.text.isNotEmpty &&
        _driverLicenseFile != null) {
      // Call signUp method from AuthProvider
      authProvider.signUp(
        context,
        widget.phoneNumber,
        _nameController.text,
        _plateNumberController.text,
        _driverLicenseFile!,
      );
    } else {
      // Show an error message if required fields are empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and upload license")),
      );
    }
  }

  InputDecoration inputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.white),
      hintStyle: TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white70),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: coloringThemes.Mainbackground,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 80,
              ),
              Row(
                children: [
                  CustomWidgets.buildHeadline('New Here?'),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    width: 300,
                    child: CustomWidgets.buildSubtitle(
                        'Please enter your info to create your account',
                        TextAlign.start),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              // Pre-set, non-editable phone number input
              Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: coloringThemes.primary,
                  ),
                  child: TextField(
                    controller: TextEditingController(text: widget.phoneNumber),
                    enabled: false,
                    decoration: inputDecoration('', Icons.phone),
                  ),
                ),
              ),

              // Full name input
              SizedBox(
                height: 20,
              ),
              // Pre-set, non-editable phone number input
              Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: coloringThemes.primary,
                  ),
                  child: TextField(
                    controller: _nameController,
                    decoration: inputDecoration('Full Name', Icons.person),
                  ),
                ),
              ),

              // Plate number input (only numeric)
              SizedBox(
                height: 20,
              ),
              // Pre-set, non-editable phone number input
              Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: coloringThemes.primary,
                  ),
                  child: TextField(
                    controller: _plateNumberController,
                    keyboardType: TextInputType.number,
                    decoration:
                        inputDecoration('Plate Number', Icons.car_rental),
                    inputFormatters: [
                      // Use input formatter to allow only numeric values
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Driver License file upload
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _driverLicenseFile == null
                          ? 'Driver License'
                          : 'File: ${_driverLicenseFile!.path.split('/').last}',
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 170,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: coloringThemes.primary),
                    child: IconButton(
                      icon: Icon(
                        Icons.upload_file,
                        color: Colors.white,
                      ),
                      onPressed: _pickLicenseImage,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Sign Up Button with loading indicator

              InkWell(
                onTap: authProvider.isLoading ? null : _submitSignUp,
                child: Container(
                  child: authProvider.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Material(
                            elevation: 10,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: 65,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: coloringThemes.primary,
                              ),
                              child: Center(
                                child: Text(
                                  "Sign Up",
                                  style: GoogleFonts.quicksand(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              ),

              // Display success or error message
              if (authProvider.successMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    authProvider.successMessage!,
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              if (authProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    authProvider.errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
