import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:taximeter_project/providers/settings_provider.dart';
import 'package:taximeter_project/providers/trip_provider.dart';
import 'package:taximeter_project/providers/auth_provider.dart';
import 'package:taximeter_project/screens/signup_screen.dart';
import 'package:taximeter_project/services/payment_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:taximeter_project/utils/colors.dart';
import 'package:taximeter_project/utils/custom_widgets.dart';
import 'package:geolocator/geolocator.dart';

class CreateTripScreen extends StatefulWidget {
  @override
  _CreateTripScreenState createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  String? selectedCity;
  String duration = '';
  double distance = 0;
  double fees = 0;
  int waitTime = 0;
  late final AuthProvider _authProvider;
  double totalDistance = 0.0; // Total distance covered in meters
  int elapsedTimeInSeconds = 0; // Time elapsed in seconds
  Position? lastPosition; // Stores the last known position
  StreamSubscription<Position>? positionStream;
  late DateTime startTime; // Start time of the tracking
  bool _isTracking = false; // Flag to track whether tracking has started
  bool _isFetchingGps = false; // Flag to show if we are fetching GPS data
  late Timer _timer; // Timer to update the elapsed time in real-time
  bool checkoutLoading = false;

  void handleCheckout(BuildContext context, String amount, String currency,
      String phoneNumber) async {
    PaymentService paymentService = PaymentService();
    String? redirectUrl = await paymentService.initiateCheckout(
        amount: amount,
        gateway: "checkout",
        currency: currency,
        phoneNumber: phoneNumber);

    if (redirectUrl != null) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Checkout"),
            content: Text("Do you want to proceed to the payment page?"),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  _launchUrl(redirectUrl); // Open the URL
                },
              ),
            ],
          );
        },
      );
    } else {
      // Show an error message if the URL is not captured
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to initiate checkout.")),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  // Start tracking location
  void startTrackingDistance() async {
    // Set the flag to indicate we are fetching GPS data
    setState(() {
      _isFetchingGps = true;
    });

    // Check if location services are enabled
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationServiceEnabled) {
      // Show a message if location services are disabled
      print("Location services are disabled. Please enable GPS.");
      setState(() {
        _isFetchingGps = false; // Stop the fetching indicator
      });
      return;
    }

    // Request location permissions
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Get the initial location data
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      totalFare = 0;
      totalDistance = 0;
      // If position is valid, start tracking
      if (position != null) {
        setState(() {
          lastPosition = position; // Store the initial position
          _isFetchingGps = false; // Stop the fetching indicator
          _isTracking = true; // Start tracking
          startTime = DateTime.now(); // Record the start time
        });

        // Start the location stream to track continuous movement
        positionStream = Geolocator.getPositionStream(
            locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Get updates after the user has moved 10 meters
        )).listen((Position currentPosition) {
          if (lastPosition != null) {
            // Calculate the distance covered between the last and current positions
            double distance = Geolocator.distanceBetween(
                lastPosition!.latitude,
                lastPosition!.longitude,
                currentPosition.latitude,
                currentPosition.longitude);

            // Update the total distance
            setState(() {
              totalDistance += distance;
            });
          }

          // Update the last known position
          setState(() {
            lastPosition = currentPosition;
          });
        });

        // Start the real-time timer to update elapsed time every second
        _timer = Timer.periodic(Duration(seconds: 1), (timer) {
          setState(() {
            elapsedTimeInSeconds =
                DateTime.now().difference(startTime).inSeconds;
          });
        });
      } else {
        // If we couldn't fetch the position, show an error
        setState(() {
          _isFetchingGps = false;
        });
        print("Failed to get GPS data.");
      }
    } else {
      // If permission is denied
      setState(() {
        _isFetchingGps = false;
      });
      print("Location permission denied.");
    }
  }

  double totalFare = 0;
  // Stop tracking location
  void stopTrackingDistance() {
    positionStream?.cancel();
    _timer.cancel();

    // Capture the total distance and elapsed time
    double finalDistance = totalDistance;
    double finalElapsedTime = elapsedTimeInSeconds.toDouble();
    // Access the provider and call the calculateFare method

    double fare =
        Provider.of<SettingsProvider>(context, listen: false).calculateFare(
      duration: elapsedTimeInSeconds.toDouble(),
      distance: totalDistance,
      waitTime: 1,
    );
    totalFare = fare;
    setState(() {});
    // Print or use the fare value
    print("Calculated Fare: $fare");
    // You can also show the fare in a dialog or update the UI with it
    Provider.of<TripsProvider>(context, listen: false).createTrip(
      duration: elapsedTimeInSeconds < 60
          ? "0"
          : (elapsedTimeInSeconds / 60).toString(),
      distance: totalDistance,
      city: selectedCity!,
      fees: totalFare,
      waitTime: 0,
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Fare Calculation"),
        content: Text("Total Fare: \$${fare.toStringAsFixed(2)}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );

    setState(() {
      lastPosition = null;
      _isTracking = false;
    });

    // Navigate to TripSummaryScreen with the captured data
  }

  @override
  void dispose() {
    positionStream?.cancel();
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Fetch the available cities when the screen is initialized
    Future.delayed(Duration.zero, () {
      Provider.of<TripsProvider>(context, listen: false).fetchAvailableCities();
      Provider.of<AuthProvider>(context, listen: false).fetchUserProfile();
    });
  }

  // Function to format the elapsed time in hours:minutes:seconds format
  String formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    return _isTracking
        ? "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}"
        : "0.0";
  }

  // Function to open the bottom sheet and show profile data
  void _showProfileBottomSheet() async {
    final profile =
        Provider.of<AuthProvider>(context, listen: false).userProfile;
    _authProvider.fetchUserProfile();

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (ctx, StateSetter setStates) {
              return profile == null
                  ? CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'My Profile',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Material(
                                  elevation: 5,
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: coloringThemes.primary),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.exit_to_app,
                                        color: coloringThemes.Mainbackground,
                                      ),
                                      onPressed: () async {
                                        await _authProvider.signOut(context);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Align(
                              alignment: AlignmentDirectional(0, 0.11),
                              child: Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                                child: Material(
                                  color: Colors.transparent,
                                  elevation: 10,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xD6FF0000),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Text(
                                                '${profile!['name']}',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              Container(
                                                height: 40,
                                                width: 120,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    color: coloringThemes
                                                        .containers),
                                                child: Center(
                                                  child: Text(
                                                    '${profile!['role']}',
                                                    style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      color: coloringThemes
                                                          .primary,
                                                      fontSize: 18,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0, 10, 0, 0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(0, 0, 10, 0),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    elevation: 2,
                                                    shape: const CircleBorder(),
                                                    child: Container(
                                                      width: 25,
                                                      height: 25,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.phone_sharp,
                                                        color:
                                                            Color(0xD6FF4C4C),
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '${profile!['phoneNumber']}',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Colors.white,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding:
                                                EdgeInsetsDirectional.fromSTEB(
                                                    0, 12, 0, 8),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(0, 0, 10, 0),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    elevation: 2,
                                                    shape: const CircleBorder(),
                                                    child: Container(
                                                      width: 25,
                                                      height: 25,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            AlignmentDirectional(
                                                                0, 0),
                                                        child: Icon(
                                                          Icons.car_rental,
                                                          color:
                                                              Color(0xD6FF4C4C),
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  '${profile['plateNumber']}',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Colors.white,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                              child: Material(
                                color: Colors.transparent,
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color(0xD6FF0000),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text(
                                              'Driver License ',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                color: Colors.white,
                                                fontSize: 22,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 8, 0, 0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Driver License',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Colors.white,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(10, 0, 10, 0),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  elevation: 2,
                                                  shape: const CircleBorder(),
                                                  child: Container(
                                                    width: 25,
                                                    height: 25,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          AlignmentDirectional(
                                                              0, 0),
                                                      child: Icon(
                                                        Icons.check_rounded,
                                                        color:
                                                            Color(0xD6FF4C4C),
                                                        size: 16,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                              child: Material(
                                color: Colors.transparent,
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Color(0xD6FF0000),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Text(
                                              'Subscription',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                color: Colors.white,
                                                fontSize: 22,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0, 8, 0, 0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              profile!['isSubscribed']
                                                  ? Material(
                                                      elevation: 5,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100),
                                                            color: coloringThemes
                                                                .containers),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10.0,
                                                                  right: 10,
                                                                  bottom: 4,
                                                                  top: 4),
                                                          child: Text(
                                                            'Subscribed',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Inter',
                                                              color:
                                                                  coloringThemes
                                                                      .primary,
                                                              letterSpacing:
                                                                  0.0,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : InkWell(
                                                      onTap: () async {
                                                        if (selectedCity ==
                                                            null) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(
                                                                    'Please select a city')),
                                                          );
                                                        } else {
                                                          setStates(() {
                                                            checkoutLoading =
                                                                true;
                                                          });
                                                          print(
                                                              checkoutLoading);
                                                          print("got start");

                                                          int amount = await Provider.of<
                                                                          SettingsProvider>(
                                                                      context,
                                                                      listen: false)
                                                                  .getSelectedCityDetails(
                                                                      selectedCity)![
                                                              'subscriptionFee'];
                                                          print("got subs");
                                                          String currency =
                                                              await Provider.of<
                                                                          SettingsProvider>(
                                                                      context,
                                                                      listen:
                                                                          false)
                                                                  .getSelectedCityDetails(
                                                                      selectedCity)!['currency'];
                                                          print("got curr");

                                                          handleCheckout(
                                                              context,
                                                              amount.toString(),
                                                              currency,
                                                              profile['phoneNumber']
                                                                  .toString());
                                                          setStates(() {
                                                            checkoutLoading =
                                                                false;
                                                          });
                                                          print(
                                                              checkoutLoading);
                                                        }
                                                      },
                                                      child: checkoutLoading
                                                          ? Container()
                                                          : Material(
                                                              elevation: 5,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            100),
                                                                    color: coloringThemes
                                                                        .containers),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          10.0,
                                                                      right: 10,
                                                                      bottom: 4,
                                                                      top: 4),
                                                                  child: Text(
                                                                    'Subscribe',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Inter',
                                                                      color: coloringThemes
                                                                          .primary,
                                                                      letterSpacing:
                                                                          0.0,
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                    ),
                                              profile!['isSubscribed']
                                                  ? Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  10, 0, 10, 0),
                                                      child: Material(
                                                        color:
                                                            Colors.transparent,
                                                        elevation: 2,
                                                        shape:
                                                            const CircleBorder(),
                                                        child: Container(
                                                          width: 25,
                                                          height: 25,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          child: Align(
                                                            alignment:
                                                                AlignmentDirectional(
                                                                    0, 0),
                                                            child: Icon(
                                                              Icons
                                                                  .check_rounded,
                                                              color: Color(
                                                                  0xD6FF4C4C),
                                                              size: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Container()
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Stack(
            children: [
              CustomWidgets.buildMeshBackground(),
              Padding(
                padding: EdgeInsets.only(left: 20.0, right: 20),
                child: provider.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 60,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () {},
                                    child: Text(
                                      "Home",
                                      style: GoogleFonts.quicksand(
                                          fontSize: 27,
                                          color: Color(0xFF45474B),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Material(
                                    elevation: 5,
                                    borderRadius: BorderRadius.circular(100),
                                    child: Container(
                                      height: 45,
                                      width: 45,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          color: coloringThemes.Mainbackground),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.person,
                                          color: coloringThemes.primary,
                                        ),
                                        onPressed:
                                            _showProfileBottomSheet, // Open the bottom sheet
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                           
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Material(
                                elevation: 10,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 60,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: coloringThemes.containers,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20.0),
                                        child: Text(
                                          "City:",
                                          style: GoogleFonts.quicksand(
                                              fontSize: 16,
                                              color: coloringThemes.primary,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Material(
                                            elevation: 0,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              width: 105,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: coloringThemes
                                                      .containers),
                                              child: // Dropdown for selecting city
                                                  DropdownButton<String>(
                                                style: TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    color:
                                                        coloringThemes.primary),
                                                value: selectedCity,
                                                hint: Text("Select City"),
                                                onChanged: (String? newCity) {
                                                  setState(() {
                                                    selectedCity = newCity;
                                                  });
                                                },
                                                items: provider.availableCities
                                                    .map<
                                                        DropdownMenuItem<
                                                            String>>(
                                                      (String city) =>
                                                          DropdownMenuItem<
                                                              String>(
                                                        value: city,
                                                        child: Text(city),
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  CustomWidgets.CardWidget(
                                    text: 'Time Travelled',
                                    text2: formatDuration(elapsedTimeInSeconds),
                                    onPressed: () {},
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          8, 0, 0, 0),
                                      child: Material(
                                        color: Colors.transparent,
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFFF0000),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Icon(
                                                      Icons.navigation,
                                                      color: Colors.white,
                                                      size: 16,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  4, 0, 0, 0),
                                                      child: Text(
                                                        'Distance Covered',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Quicksand',
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(0, 0, 0, 25),
                                                  child: Text(
                                                    '${totalDistance.toStringAsFixed(2)} meters',
                                                    style: TextStyle(
                                                      fontFamily: 'Inter',
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      letterSpacing: 0.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
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
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(8),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Icon(
                                                    Icons.money,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                8, 0, 0, 0),
                                                    child: Text(
                                                      'Price',
                                                      style: TextStyle(
                                                        fontFamily: 'Quicksand',
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(0, 35, 0, 25),
                                                child: Text(
                                                  '\$ ${totalFare.toStringAsFixed(2)}',
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
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: CustomWidgets.buildDivider(),
                            ),
                            InkWell(
                                onTap: _isTracking
                                    ? null
                                    : () {
                                        if (selectedCity == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Please select a city')),
                                          );
                                        } else {
                                          startTrackingDistance();
                                        }
                                      }, // Disable the button while tracking
                                child: _isFetchingGps
                                    ? CircularProgressIndicator()
                                    : !_isTracking
                                        ? Material(
                                            elevation: 10,
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            child: Container(
                                              height: 65,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  color:
                                                      coloringThemes.primary),
                                              child: Center(
                                                child: Text(
                                                  'Start Tracking',
                                                  style: TextStyle(
                                                    fontFamily: 'Quicksand',
                                                    color: Colors.white,
                                                    fontSize: 25,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container()),

                            _isTracking
                                ? InkWell(
                                    onTap: _isTracking
                                        ? stopTrackingDistance
                                        : null, // Disable the button if not tracking
                                    child: Material(
                                      elevation: 10,
                                      borderRadius: BorderRadius.circular(30),
                                      child: Container(
                                        height: 65,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            color: coloringThemes.containers),
                                        child: Center(
                                          child: Text(
                                            'Stop Tracking',
                                            style: TextStyle(
                                              fontFamily: 'Quicksand',
                                              color: coloringThemes.primary,
                                              fontSize: 25,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            // GestureDetector(
                            //   onTap: () {
                            //     setState(() {
                            //       tripStarted = false;
                            //     });
                            //     _stopTracking();
                            //     if (selectedCity != null &&
                            //         duration.isNotEmpty) {
                            //       provider.createTrip(
                            //         duration: _timeTraveledNotifier.value,
                            //         distance: _totalDistance,
                            //         city: selectedCity!,
                            //         fees: _fare,
                            //         waitTime: 0,
                            //       );
                            //       _resetTrip();
                            //     } else {
                            //       // Show error message if required fields are empty
                            //     }
                            //     _showTripSummary(provider);
                            //   },
                            //   onPanUpdate: (details) {
                            //     // Swiping in right direction.
                            //     if (details.delta.dx > 0) {
                            //       setState(() {
                            //         tripStarted = true;
                            //       });
                            //       _startTracking();
                            //     }

                            //     // Swiping in left direction.
                            //     if (details.delta.dx < 0) {}
                            //   },
                            //   child: Material(
                            //     elevation: 10,
                            //     borderRadius: BorderRadius.circular(100),
                            //     child: AnimatedContainer(
                            //       duration: Duration(seconds: 1),
                            //       width: tripStarted
                            //           ? 200
                            //           : MediaQuery.of(context).size.width * 0.9,
                            //       height: tripStarted ? 200 : 200,
                            //       decoration: BoxDecoration(
                            //           border: Border.all(
                            //               width: 2,
                            //               color: !tripStarted
                            //                   ? Colors.white
                            //                   : Color(0xFFFF0000)),
                            //           borderRadius: BorderRadius.circular(100),
                            //           color: tripStarted
                            //               ? Colors.white
                            //               : Color(0xFFFF0000)),
                            //       child: Stack(
                            //         children: [
                            //           tripStarted
                            //               ? Container()
                            //               : Row(
                            //                   children: [
                            //                     Padding(
                            //                       padding:
                            //                           const EdgeInsets.all(3.0),
                            //                       child: AnimatedContainer(
                            //                         duration:
                            //                             Duration(seconds: 1),
                            //                         height:
                            //                             tripStarted ? 0 : 65,
                            //                         width: tripStarted ? 0 : 65,
                            //                         decoration: BoxDecoration(
                            //                             borderRadius:
                            //                                 BorderRadius
                            //                                     .circular(100),
                            //                             color: !tripStarted
                            //                                 ? Colors.white
                            //                                 : Color(
                            //                                     0xFFFF0000)),
                            //                         child: Icon(
                            //                           Icons
                            //                               .chevron_right_rounded,
                            //                           color: Color(0xFFFF0000),
                            //                           size: 30,
                            //                         ),
                            //                       ),
                            //                     ),
                            //                     SizedBox(
                            //                       width: 10,
                            //                     ),
                            //                     Text(
                            //                       "Swipe to start trip",
                            //                       style: GoogleFonts.quicksand(
                            //                           color: Color.fromARGB(
                            //                               255, 255, 255, 255),
                            //                           fontSize: 22,
                            //                           fontWeight:
                            //                               FontWeight.w600),
                            //                     ),
                            //                   ],
                            //                 ),
                            //           tripStarted
                            //               ? Center(
                            //                   child: Text(
                            //                     "Tap to end trip",
                            //                     style: GoogleFonts.quicksand(
                            //                         color: Color(0xFFFF0000),
                            //                         fontSize: 22,
                            //                         fontWeight:
                            //                             FontWeight.w600),
                            //                   ),
                            //                 )
                            //               : Container()
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),

                            // TextField(
                            //   decoration: InputDecoration(
                            //       labelText: 'Duration (in mins)'),
                            //   keyboardType: TextInputType.number,
                            //   onChanged: (value) {
                            //     setState(() {
                            //       duration = value;
                            //     });
                            //   },
                            // ),
                            // TextField(
                            //   decoration: InputDecoration(
                            //       labelText: 'Distance (in km)'),
                            //   keyboardType: TextInputType.number,
                            //   onChanged: (value) {
                            //     setState(() {
                            //       distance = double.tryParse(value) ?? 0;
                            //     });
                            //   },
                            // ),
                            // TextField(
                            //   decoration: InputDecoration(labelText: 'Fees'),
                            //   keyboardType: TextInputType.number,
                            //   onChanged: (value) {
                            //     setState(() {
                            //       fees = double.tryParse(value) ?? 0;
                            //     });
                            //   },
                            // ),
                            // TextField(
                            //   decoration: InputDecoration(
                            //       labelText: 'Waiting Time (in mins)'),
                            //   keyboardType: TextInputType.number,
                            //   onChanged: (value) {
                            //     setState(() {
                            //       waitTime = int.tryParse(value) ?? 0;
                            //     });
                            //   },
                            // ),
                            // SizedBox(height: 16),
                            // ElevatedButton(
                            //   onPressed: () {
                            //     if (selectedCity != null &&
                            //         duration.isNotEmpty) {
                            //       provider.createTrip(
                            //         duration: duration,
                            //         distance: distance,
                            //         city: selectedCity!,
                            //         fees: fees,
                            //         waitTime: waitTime,
                            //       );
                            //     } else {
                            //       // Show error message if required fields are empty
                            //     }
                            //   },
                            //   child: Text('Create Trip'),
                            // ),
                            SizedBox(
                              height: 30,
                            ),

                            if (provider.errorMessage != null)
                              Center(
                                child: Text(
                                  provider.errorMessage!,
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            if (provider.successMessage != null)
                              Center(
                                child: Text(
                                  provider.successMessage!,
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            SizedBox(
                              height: 100,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
