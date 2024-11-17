import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taximeter_project/utils/colors.dart';
import 'package:taximeter_project/utils/custom_widgets.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          children: [
            Stack(
              children: [
                CustomWidgets.buildMeshBackground(),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomWidgets.buildHeadline('Welcome to Taxi Meter!'),
                        SizedBox(height: 16),
                        CustomWidgets.buildSubtitle(
                            'Easily calculate your fare with just one tap! Let Taxi Meter handle the math while you focus on the ride',
                            TextAlign.center),
                        SizedBox(height: 16),
                        CustomWidgets.buildLottie(
                          'https://lottie.host/b9503a40-bfbe-4666-a676-6dc620a92930/CslGQFT9Wi.json',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                CustomWidgets.buildMeshBackground(),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomWidgets.buildHeadline('Track Distance and Time'),
                        SizedBox(height: 16),
                        CustomWidgets.buildSubtitle(
                            'Start the trip and watch as we calculate the distance traveled and time, ensuring an accurate fare.',
                            TextAlign.center),
                        SizedBox(height: 16),
                        CustomWidgets.buildLottie(
                          'https://lottie.host/0e2a93f2-4282-48d5-a512-e7314c6abfa7/eWZ7cqHeOG.json',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomSheet: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Container(
                height: 65,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: coloringThemes.primary,
                ),
                child: Center(
                  child: Text(
                    "Login",
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
        ));
  }
}
