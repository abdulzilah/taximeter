import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';
import 'package:taximeter_project/utils/colors.dart';
import 'package:taximeter_project/utils/custom_widgets.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  PhoneNumber? _phoneNumber;
  int _secondsLeft = 0;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;
  bool _isSendingOtp = false;
  bool _isResendingOtp = false;
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  CustomWidgets.buildHeadline('Login'),
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
                        'Enter your phone number to recieve an OTP to verify your account',
                        TextAlign.start),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              // Phone Number input with country code picker
              _isOtpSent
                  ? Container()
                  :  Material(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: coloringThemes.containers),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InternationalPhoneNumberInput(
                              onInputChanged: (PhoneNumber number) {
                                _phoneNumber = number;
                              },
                              selectorConfig: SelectorConfig(
                                selectorType: PhoneInputSelectorType.DIALOG,
                              ),
                              ignoreBlank: false,
                              autoValidateMode:
                                  AutovalidateMode.onUserInteraction,
                              initialValue: _phoneNumber,
                              textFieldController: _phoneController,
                              inputDecoration: const InputDecoration(
                                border: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent)),
                                labelText: 'Phone Number',
                              ),
                            ),
                          ),
                        ),
                      ),
                    
              _isOtpSent ? Container() : SizedBox(height: 28),
              // Send OTP section
              _isOtpSent
                  ? Container()
                  : InkWell(
                        onTap: _isSendingOtp
                            ? null
                            : () async {
                                // Validate phone number before sending OTP
                                if (_phoneController.text.isNotEmpty &&
                                    _phoneNumber != null) {
                                  setState(() {
                                    _isSendingOtp = true;
                                  });
                                  final fullPhoneNumber =
                                      _phoneNumber!.phoneNumber!;
                                  await _authProvider.sendOtp(fullPhoneNumber);

                                  if (_authProvider.successMessage != null) {
                                    setState(() {
                                      _isOtpSent = true; // OTP has been sent
                                    });
                                  }
                                  setState(() {
                                    _isOtpSent = true;
                                    _isSendingOtp = false;
                                  });
                                } else {
                                  // Show error if phone number is invalid
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Please enter a valid phone number')),
                                  );
                                }
                              },
                        child: _isSendingOtp
                            ? CircularProgressIndicator()
                            : Container(
                                height: 65,
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: coloringThemes.primary),
                                child: Center(
                                  child: Text(
                                    "Send OTP",
                                    style: GoogleFonts.quicksand(
                                      color: Colors.white,
                                      fontSize: 27,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    
              _isOtpSent ? Container() : SizedBox(height: 28),

              // OTP Verification Section
              _isOtpSent
                  ?  Material(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: coloringThemes.containers),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _otpController,
                              decoration:
                                  InputDecoration(labelText: 'Enter OTP'),
                            ),
                          ),
                        ),
                      ):Container(),
                    
                
              SizedBox(height: 28),
              !_isOtpSent
                  ? Container()
                  : InkWell(
                        onTap: _isSendingOtp
                            ? null
                            : () async {
                                if (_otpController.text.isNotEmpty) {
                                  setState(() {
                                    _isSendingOtp = true;
                                  });
                                  final fullPhoneNumber =
                                      _phoneNumber!.phoneNumber!;
                                  await _authProvider.verifyOtp(context,
                                      fullPhoneNumber, _otpController.text);
                                  setState(() {
                                    _isSendingOtp = false;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Please enter the OTP.')),
                                  );
                                }
                              },
                        child: _isSendingOtp
                            ? CircularProgressIndicator()
                            : Container(
                                height: 65,
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: coloringThemes.primary),
                                child: Center(
                                  child: Text(
                                    "Verify OTP",
                                    style: GoogleFonts.quicksand(
                                      color: Colors.white,
                                      fontSize: 27,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    
              SizedBox(height: 8),

              // Resend OTP button
              InkWell(
                onTap: _isResendingOtp || _secondsLeft > 0
                    ? null
                    : () async {
                        setState(() {
                          _isResendingOtp = true; // Disable while resending
                        });
                        final fullPhoneNumber = _phoneNumber!.phoneNumber!;
                        await _authProvider.sendOtp(fullPhoneNumber);
                        setState(() {
                          _isOtpSent = false;
                          _isResendingOtp = false;
                        });
                      },
                child: _isResendingOtp
                    ? CircularProgressIndicator()
                    : _secondsLeft == 0
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              'Resend OTP',
                              style: TextStyle(
                                  color: coloringThemes.primary,
                                  decoration: TextDecoration.underline),
                            ),
                          )
                        : Text('Resend in $_secondsLeft s'),
              ),
              SizedBox(height: 8),

              // Error message display
              if (_authProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _authProvider.errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              // Success message display
              if (_authProvider.successMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _authProvider.successMessage!,
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
