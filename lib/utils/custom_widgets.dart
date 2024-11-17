import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class CustomWidgets {
  // Mesh Background Widget
  static Widget buildMeshBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: Image.asset('assets/background.png').image,
        ),
      ),
    );
  }

  // Headline Widget
  static Widget buildHeadline(String text) {
    return Text(
      text,
      style: GoogleFonts.quicksand(
        color: const Color(0xFF45474B),
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  // Subtitle Widget
  static Widget buildSubtitle(String text, TextAlign algn) {
    return Text(
      text,
      textAlign: algn,
      style: GoogleFonts.quicksand(
        color: const Color(0xFF45474B),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Lottie Animation Widget
  static Widget buildLottie(String url) {
    return Lottie.network(
      url,
      width: 200,
      height: 200,
      fit: BoxFit.contain,
      animate: true,
    );
  }

  // Phone Input Row Widget (Combines Country Code Box and Phone Number Box)
  static Widget buildPhoneInputRow() {
    return Row(
      children: [
        buildCountryCodeBox(),
        const SizedBox(width: 10),
        Expanded(child: buildPhoneNumberBox()),
      ],
    );
  }

  // Country Code Box Widget
  static Widget buildCountryCodeBox() {
    return Material(
      color: Colors.transparent,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: 100,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'LB  | +961',
            style: GoogleFonts.inter(
              color: const Color(0xFFFF4C4C),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  // Phone Number Box Widget
  static Widget buildPhoneNumberBox() {
    return Material(
      color: Colors.transparent,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '70858410',
                style: GoogleFonts.inter(
                  color: const Color(0xFFFF4C4C),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                backgroundColor: const Color(0xFFFF4C4C),
                radius: 12.5,
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Divider Widget
  static Widget buildDivider() {
    return Divider(
      color: const Color(0x648D6760),
      thickness: 0.5,
    );
  }

  // Agreement Text Widget
  static Widget buildAgreementText() {
    return Column(
      children: [
        Text(
          'By Signing In you agree to our',
          style: GoogleFonts.inter(color: const Color(0xFF45474B)),
        ),
        const SizedBox(height: 3),
        Text(
          'Terms and Conditions',
          style: GoogleFonts.inter(
            color: const Color(0xFF45474B),
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  //text field widget for sign up
  static Widget textFieldWithIcon({
    required IconData icon,
    required String hintText,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 25, 0, 0),
      child: Material(
        color: Colors.transparent,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xD6FF0000), // Customize color as needed
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                child: Icon(
                  icon,
                  color: Colors.white, // Customize icon color
                  size: 24,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                          color: Colors.white54), // Customize hint text color
                      border: InputBorder.none,
                    ),
                    style:
                        TextStyle(color: Colors.white), // Customize text color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Button Widget
  static Widget buildButton({
    required String text,
    Icon? icon,
    required VoidCallback onPressed,
  }) {
    return Align(
      alignment: AlignmentDirectional(0, 1),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 30),
        child: Material(
          color: Colors.transparent,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: onPressed,
            child: Container(
              width: double.infinity,
              height: 65,
              decoration: BoxDecoration(
                color: Color(0xD6FF0000),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 4),
                    icon,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Card Widget
  static Widget CardWidget({
    required String text,
    required String text2,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 8, 0),
        child: Material(
          color: Colors.transparent,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Color(0xFFFF0000),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            color: Colors.white,
                            fontSize: 14,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 25),
                    child: Text(
                      text2,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 20,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Card Widget
  static Widget BigCardWidget({
    required String text,
    required String text2,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Color(0xFFFF0000),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                            child: Text(
                              text,
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                color: Colors.white,
                                fontSize: 14,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 35, 0, 25),
                        child: Text(
                          text2,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 48,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
