import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:taximeter_project/providers/settings_provider.dart';
import 'package:taximeter_project/providers/auth_provider.dart';
import 'package:taximeter_project/providers/staff_provider.dart';
import 'package:taximeter_project/screens/transactions_screen.dart';
import 'package:taximeter_project/utils/colors.dart';
import 'package:taximeter_project/utils/custom_widgets.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<SettingsProvider, AuthProvider>(
        builder: (context, settingsProvider, authProvider, child) {
          if (settingsProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (settingsProvider.errorMessage != null) {
            return Center(child: Text(settingsProvider.errorMessage!));
          }

          return Stack(
            children: [
              CustomWidgets.buildMeshBackground(),
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 60,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Settings",
                            style: GoogleFonts.quicksand(
                                fontSize: 27,
                                color: Color(0xFF45474B),
                                fontWeight: FontWeight.bold),
                          ),
                          if (authProvider.isAdmin && authProvider.canEdit)
                            Row(
                              children: [
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
                                        Icons.monetization_on,
                                        color: coloringThemes.primary,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    TransactionPage()));
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
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
                                        Icons.people,
                                        color: coloringThemes.primary,
                                      ),
                                      onPressed: () {
                                        // Show the bottom sheet for staff
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (_) {
                                            return StaffBottomSheet();
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
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
                                        Icons.add,
                                        color: coloringThemes.primary,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AddSettingsDialog(
                                              onSave: (newData) async {
                                                await settingsProvider
                                                    .createSettings(
                                                        newData, context);
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
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
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 100,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: coloringThemes.containers),
                                      child: DropdownButton<String>(
                                        style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            color: coloringThemes.primary),
                                        value: settingsProvider
                                            .selectedSettings?['city'],
                                        onChanged: (newCity) {
                                          if (newCity != null) {
                                            settingsProvider
                                                .setSelectedCity(newCity);
                                          }
                                        },
                                        items: settingsProvider.settingsList
                                            .map<DropdownMenuItem<String>>(
                                          (Map<String, dynamic> setting) {
                                            return DropdownMenuItem<String>(
                                              value: setting['city'],
                                              child: Text(setting['city']),
                                            );
                                          },
                                        ).toList(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  if (authProvider.isAdmin &&
                                      authProvider.canEdit)
                                    Material(
                                      elevation: 5,
                                      borderRadius: BorderRadius.circular(100),
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            color: coloringThemes.primary),
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.edit,
                                            color:
                                                coloringThemes.Mainbackground,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                // Your existing code to edit the city
                                                return EditCityDialog(
                                                  settingsProvider:
                                                      settingsProvider,
                                                );
                                              },
                                            );
                                          },
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
                    SizedBox(height: 20),
                    if (settingsProvider.selectedSettings != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, bottom: 20),
                        child: Material(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: coloringThemes.primary),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Base Fare",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 16,
                                            color:
                                                coloringThemes.Mainbackground,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          Material(
                                            elevation: 10,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              height: 35,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: coloringThemes
                                                      .containers),
                                              child: Center(
                                                child: Text(
                                                  "${settingsProvider.selectedSettings!['baseFarePrice']}",
                                                  style: GoogleFonts.quicksand(
                                                      fontSize: 16,
                                                      color: coloringThemes
                                                          .primary,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "  / USD",
                                            style: GoogleFonts.quicksand(
                                                fontSize: 12,
                                                color: coloringThemes
                                                    .Mainbackground,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Base Distance",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 16,
                                            color:
                                                coloringThemes.Mainbackground,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          Material(
                                            elevation: 10,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              height: 35,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: coloringThemes
                                                      .containers),
                                              child: Center(
                                                child: Text(
                                                  "${settingsProvider.selectedSettings!['baseDistance']}",
                                                  style: GoogleFonts.quicksand(
                                                      fontSize: 16,
                                                      color: coloringThemes
                                                          .primary,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "  / KM  ",
                                            style: GoogleFonts.quicksand(
                                                fontSize: 12,
                                                color: coloringThemes
                                                    .Mainbackground,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Base Duration",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 16,
                                            color:
                                                coloringThemes.Mainbackground,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          Material(
                                            elevation: 10,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              height: 35,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: coloringThemes
                                                      .containers),
                                              child: Center(
                                                child: Text(
                                                  "${settingsProvider.selectedSettings!['baseDuration']}",
                                                  style: GoogleFonts.quicksand(
                                                      fontSize: 16,
                                                      color: coloringThemes
                                                          .primary,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "  / Min ",
                                            style: GoogleFonts.quicksand(
                                                fontSize: 12,
                                                color: coloringThemes
                                                    .Mainbackground,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Base Waiting Time",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 16,
                                            color:
                                                coloringThemes.Mainbackground,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          Material(
                                            elevation: 10,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              height: 35,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: coloringThemes
                                                      .containers),
                                              child: Center(
                                                child: Text(
                                                  "${settingsProvider.selectedSettings!['baseWait']}",
                                                  style: GoogleFonts.quicksand(
                                                      fontSize: 16,
                                                      color: coloringThemes
                                                          .primary,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "  / Min ",
                                            style: GoogleFonts.quicksand(
                                                fontSize: 12,
                                                color: coloringThemes
                                                    .Mainbackground,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20),
                        child: Material(
                          elevation: 10,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: coloringThemes.primary),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Extra KM Fare",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 16,
                                            color:
                                                coloringThemes.Mainbackground,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          Material(
                                            elevation: 10,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              height: 35,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: coloringThemes
                                                      .containers),
                                              child: Center(
                                                child: Text(
                                                  "${settingsProvider.selectedSettings!['pricePerKm']}",
                                                  style: GoogleFonts.quicksand(
                                                      fontSize: 16,
                                                      color: coloringThemes
                                                          .primary,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "  / USD",
                                            style: GoogleFonts.quicksand(
                                                fontSize: 12,
                                                color: coloringThemes
                                                    .Mainbackground,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Extra Min Fare",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 16,
                                            color:
                                                coloringThemes.Mainbackground,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          Material(
                                            elevation: 10,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              height: 35,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: coloringThemes
                                                      .containers),
                                              child: Center(
                                                child: Text(
                                                  "${settingsProvider.selectedSettings!['pricePerMin']}",
                                                  style: GoogleFonts.quicksand(
                                                      fontSize: 16,
                                                      color: coloringThemes
                                                          .primary,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "  / USD",
                                            style: GoogleFonts.quicksand(
                                                fontSize: 12,
                                                color: coloringThemes
                                                    .Mainbackground,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Currency",
                                        style: GoogleFonts.quicksand(
                                            fontSize: 16,
                                            color:
                                                coloringThemes.Mainbackground,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: [
                                          Material(
                                            elevation: 10,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              height: 35,
                                              width: 110,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: coloringThemes
                                                      .containers),
                                              child: Center(
                                                child: Text(
                                                  "${settingsProvider.selectedSettings!['currency']}",
                                                  style: GoogleFonts.quicksand(
                                                      fontSize: 16,
                                                      color: coloringThemes
                                                          .primary,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class StaffBottomSheet extends StatefulWidget {
  @override
  State<StaffBottomSheet> createState() => _StaffBottomSheetState();
}

class _StaffBottomSheetState extends State<StaffBottomSheet> {
  @override
  Widget build(BuildContext ctx) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Staff Members',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: coloringThemes.primary),
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: coloringThemes.Mainbackground,
                      ),
                      onPressed: () {
                        _showAddStaffDialog(ctx);
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Consumer<StaffProvider>(
              builder: (context, staffProvider, child) {
                if (staffProvider.isLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (staffProvider.staff.isEmpty) {
                  return Center(child: Text("No staff members found"));
                }

                // Wrap the ListView in a SingleChildScrollView to prevent overflow
                return SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap:
                        true, // Prevents ListView from taking more space than needed
                    physics:
                        NeverScrollableScrollPhysics(), // Disable scrolling on ListView to allow scrolling on the outer widget
                    itemCount: staffProvider.staff.length,
                    itemBuilder: (context, index) {
                      var staff = staffProvider.staff[index];

                      return Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: coloringThemes.primary),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "${staff['name']}",
                                          style: GoogleFonts.quicksand(
                                              fontSize: 18,
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Can Edit: ${staff['canEdit'] ? 'Yes' : 'No'}",
                                          style: GoogleFonts.quicksand(
                                              fontSize: 14,
                                              color: Color.fromARGB(
                                                  192, 255, 255, 255),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AddSettingsDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave; // Callback for saving data

  AddSettingsDialog({required this.onSave});

  @override
  _AddSettingsDialogState createState() => _AddSettingsDialogState();
}

class _AddSettingsDialogState extends State<AddSettingsDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the text fields
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController baseFarePriceController = TextEditingController();
  final TextEditingController baseDurationController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();
  final TextEditingController subscriptionFeesController =
      TextEditingController();
  final TextEditingController pricePerMinController = TextEditingController();
  final TextEditingController pricePerKmController = TextEditingController();
  final TextEditingController baseWaitController = TextEditingController();
  final TextEditingController distanceController = TextEditingController();

  @override
  void dispose() {
    countryController.dispose();
    cityController.dispose();
    baseFarePriceController.dispose();
    baseDurationController.dispose();
    currencyController.dispose();
    subscriptionFeesController.dispose();
    pricePerMinController.dispose();
    pricePerKmController.dispose();
    baseWaitController.dispose();
    super.dispose();
  }

  // Helper function to collect the data and submit it
  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Collect data
      Map<String, dynamic> newData = {
        'country': countryController.text,
        'city': cityController.text,
        'baseFarePrice': double.tryParse(baseFarePriceController.text) ?? 0,
        'baseDuration': double.tryParse(baseDurationController.text) ?? 0,
        'currency': currencyController.text,
        'subscriptionFees':
            double.tryParse(subscriptionFeesController.text) ?? 0,
        'pricePerMin': double.tryParse(pricePerMinController.text) ?? 0,
        'pricePerKm': double.tryParse(pricePerKmController.text) ?? 0,
        'baseWait': double.tryParse(baseWaitController.text) ?? 0,
        'baseDistance': double.tryParse(distanceController.text) ?? 0,
      };

      // Call the save callback and pass the new data
      widget.onSave(newData);

      // Close the dialog
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Setting'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: countryController,
                decoration: InputDecoration(labelText: 'Country'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a country' : null,
              ),
              TextFormField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a city' : null,
              ),
              TextFormField(
                controller: baseFarePriceController,
                decoration: InputDecoration(labelText: 'Base Fare Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter a base fare price'
                    : null,
              ),
              TextFormField(
                controller: baseDurationController,
                decoration: InputDecoration(labelText: 'Base Duration'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter a base duration'
                    : null,
              ),
              TextFormField(
                controller: distanceController,
                decoration: InputDecoration(labelText: 'Base Distance'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter a base distance'
                    : null,
              ),
              TextFormField(
                controller: currencyController,
                decoration: InputDecoration(labelText: 'Currency'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a currency' : null,
              ),
              TextFormField(
                controller: subscriptionFeesController,
                decoration: InputDecoration(labelText: 'Subscription Fees'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: pricePerMinController,
                decoration: InputDecoration(labelText: 'Price Per Minute'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter a price per minute'
                    : null,
              ),
              TextFormField(
                controller: pricePerKmController,
                decoration: InputDecoration(labelText: 'Price Per Kilometer'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter a price per kilometer'
                    : null,
              ),
              TextFormField(
                controller: baseWaitController,
                decoration: InputDecoration(labelText: 'Base Wait Time'),
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Please enter a base wait time'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text('Save'),
        ),
      ],
    );
  }
}

// Dialog for editing the settings
class EditCityDialog extends StatelessWidget {
  final SettingsProvider settingsProvider;

  EditCityDialog({required this.settingsProvider});

  @override
  Widget build(BuildContext context) {
    TextEditingController cityController = TextEditingController(
      text: settingsProvider.selectedSettings?['city'],
    );
    TextEditingController countryController = TextEditingController(
      text: settingsProvider.selectedSettings?['country'],
    );
    TextEditingController baseFarePriceController = TextEditingController(
      text: settingsProvider.selectedSettings?['baseFarePrice'].toString(),
    );
    TextEditingController baseDistanceController = TextEditingController(
      text: settingsProvider.selectedSettings?['baseDistance'].toString(),
    );
    TextEditingController baseDurationController = TextEditingController(
      text: settingsProvider.selectedSettings?['baseDuration'].toString(),
    );
    TextEditingController baseWaitController = TextEditingController(
      text: settingsProvider.selectedSettings?['baseWait'].toString(),
    );
    TextEditingController pricePerKmController = TextEditingController(
      text: settingsProvider.selectedSettings?['pricePerKm'].toString(),
    );
    TextEditingController pricePerMinController = TextEditingController(
      text: settingsProvider.selectedSettings?['pricePerMin'].toString(),
    );
    TextEditingController subscriptionFee = TextEditingController(
      text: settingsProvider.selectedSettings?['subscriptionFees'].toString(),
    );
    TextEditingController currencyController = TextEditingController(
      text: settingsProvider.selectedSettings?['currency'],
    );

    return AlertDialog(
      title: Text('Edit City Settings'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
            TextField(
              controller: countryController,
              decoration: InputDecoration(labelText: 'Country'),
            ),
            TextField(
              controller: baseFarePriceController,
              decoration: InputDecoration(labelText: 'Base Fare Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: baseDistanceController,
              decoration: InputDecoration(labelText: 'Base Distance'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: baseDurationController,
              decoration: InputDecoration(labelText: 'Base Duration (mins)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: subscriptionFee,
              decoration: InputDecoration(labelText: 'subscription Fee'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: baseWaitController,
              decoration: InputDecoration(labelText: 'Base Wait Time (mins)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: pricePerKmController,
              decoration: InputDecoration(labelText: 'Price per Km'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: pricePerMinController,
              decoration: InputDecoration(labelText: 'Price per Min'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: currencyController,
              decoration: InputDecoration(labelText: 'Currency'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (cityController.text.length > 3 &&
                countryController.text.length > 3 &&
                baseFarePriceController.text.isNotEmpty &&
                baseDurationController.text.isNotEmpty &&
                baseWaitController.text.isNotEmpty &&
                pricePerKmController.text.isNotEmpty &&
                pricePerMinController.text.isNotEmpty &&
                currencyController.text.isNotEmpty) {
              // Collect all the updated data
              Map<String, dynamic> updatedData = {
                'id': settingsProvider.selectedSettings?['id'],
                'city': cityController.text,
                'country': countryController.text,
                'baseFarePrice': double.tryParse(baseFarePriceController.text),
                'baseDuration': double.tryParse(baseDurationController.text),
                'baseWait': double.tryParse(baseWaitController.text),
                'pricePerKm': double.tryParse(pricePerKmController.text),
                'pricePerMin': double.tryParse(pricePerMinController.text),
                'currency': currencyController.text,
                "subscriptionFees": double.tryParse(subscriptionFee.text),
              };

              // Call the editSettings method with the updated data
              settingsProvider.editSettings(updatedData);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text('Please enter a valid data')),
              );
            }
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

// Method to show the dialog to add staff
void _showAddStaffDialog(BuildContext context) {
  final nameController = TextEditingController();
  bool canEdit = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add New Staff'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Staff ID - Only numeric input allowed
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Staff Phone Number'),
              keyboardType: TextInputType.phone, // Allow only numbers
              inputFormatters: [],
            ),
            // Role - Always set to "ADMIN", so we don't need an input field for it
            SizedBox(height: 10),

            SwitchListTile(
              title: Text('Can Edit'),
              value: canEdit,
              onChanged: (value) {
                canEdit = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Get staff ID from the input field
              String staffId = nameController.text.trim();

              if (staffId.isEmpty) {
                // Show an error message if Staff ID is empty
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid Staff ID')),
                );
                return;
              }

              // // Ensure the Staff ID is numeric
              // if (!RegExp(r'^[0-9]+$').hasMatch(staffId)) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(content: Text('Staff ID must be numeric')),
              //   );
              //   return;
              // }

              // Call the StaffProvider's updateUser method
              context.read<StaffProvider>().updateUser(
                    userId: staffId, // Use the Staff ID entered
                    role: 'ADMIN', // Always set to "ADMIN"
                    canEdit: canEdit,
                  );

              Navigator.pop(context); // Close the dialog
            },
            child: Text('Add Staff'),
          ),
        ],
      );
    },
  );
}
