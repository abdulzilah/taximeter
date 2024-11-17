import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:taximeter_project/providers/auth_provider.dart';
import 'package:taximeter_project/providers/history_provider.dart';
import 'package:taximeter_project/utils/colors.dart';
import 'package:taximeter_project/utils/custom_widgets.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'name'; // default search type
  final ScrollController _scrollController = ScrollController();
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Delay calling fetchTrips until after the first frame to avoid triggering notifications during build
    _authProvider.isAdmin
        ? WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<HistoryProvider>(context, listen: false).fetchTrips();
          })
        : WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<HistoryProvider>(context, listen: false)
                .fetchTripsRegularUser();
          });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        Provider.of<HistoryProvider>(context, listen: false).hasMoreData) {
      Provider.of<HistoryProvider>(context, listen: false).loadNextPage();
    }
  }

  void _showEditTripDialog(BuildContext context, Map<String, dynamic> trip) {
    final TextEditingController cityController =
        TextEditingController(text: trip['city']);
    final TextEditingController feesController =
        TextEditingController(text: trip['fees'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Trip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cityController,
                decoration: InputDecoration(labelText: 'City'),
              ),
              TextField(
                controller: feesController,
                decoration: InputDecoration(labelText: 'Fees'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final city = cityController.text;
                final fees = int.tryParse(feesController.text) ?? trip['fees'];

                final updater = TripUpdater();
                await updater.updateTrip(
                  tripId: trip['id'],
                  duration: trip['duration'],
                  distance: trip['distance'].toDouble(),
                  city: city,
                  fees: fees,
                  waitTime: trip['waitTime'],
                );

                Navigator.of(context).pop();
                Provider.of<HistoryProvider>(context, listen: false)
                    .resetHistory();

                _authProvider.isAdmin
                    ? Provider.of<HistoryProvider>(context, listen: false)
                        .fetchTrips()
                    : Provider.of<HistoryProvider>(context, listen: false)
                        .fetchTripsRegularUser();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HistoryProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          CustomWidgets.buildMeshBackground(),
          Column(
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
                      "History",
                      style: GoogleFonts.quicksand(
                          fontSize: 27,
                          color: Color(0xFF45474B),
                          fontWeight: FontWeight.bold),
                    ),
                    Material(
                      elevation: 5,
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: coloringThemes.Mainbackground),
                        child: IconButton(
                          icon: Icon(
                            Icons.refresh,
                            color: coloringThemes.primary,
                          ),
                          onPressed: () {
                            provider.resetHistory();
                            _authProvider.isAdmin
                                ? provider.fetchTrips()
                                : provider.fetchTripsRegularUser();
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: coloringThemes.primary),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0, right: 10),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              labelStyle: TextStyle(color: Colors.white),
                              hintText: 'Search...',
                              hintStyle: TextStyle(color: Colors.white),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.white,
                                ),
                                onPressed: () => _searchController.clear(),
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 40,
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Row(
                    children: [
                      Material(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(100),
                        child: InkWell(
                          onTap: () => setState(() {
                            _searchType = 'name';
                          }),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 400),
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    width: _searchType == "name" ? 3 : 0,
                                    color: coloringThemes.primary),
                                color: coloringThemes.containers),
                            child: Center(
                              child: Text(
                                "Name",
                                style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _searchType == "name"
                                        ? coloringThemes.primary
                                        : coloringThemes.primary
                                            .withOpacity(0.7)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Material(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(100),
                        child: InkWell(
                          onTap: () => setState(() {
                            _searchType = 'city';
                          }),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 400),
                            height: 40,
                            width: 80,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    width: _searchType == "city" ? 3 : 0,
                                    color: coloringThemes.primary),
                                color: coloringThemes.containers),
                            child: Center(
                              child: Text(
                                "City",
                                style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _searchType == "city"
                                        ? coloringThemes.primary
                                        : coloringThemes.primary
                                            .withOpacity(0.7)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Material(
                        elevation: 10,
                        borderRadius: BorderRadius.circular(100),
                        child: InkWell(
                          onTap: () => setState(() {
                            _searchType = 'plateNumber';
                          }),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 400),
                            height: 40,
                            width: 120,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    width: _searchType == "plateNumber" ? 3 : 0,
                                    color: coloringThemes.primary),
                                color: coloringThemes.containers),
                            child: Center(
                              child: Text(
                                "Plate Number",
                                style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _searchType == "plateNumber"
                                        ? coloringThemes.primary
                                        : coloringThemes.primary
                                            .withOpacity(0.7)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: provider.isLoading && provider.trips.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : provider.trips.isEmpty
                        ? Center(child: Text('No results found'))
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: provider.trips.length +
                                (provider.hasMoreData ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == provider.trips.length) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }

                              final trip = provider.trips[index];
                              if (_searchController.text.isNotEmpty &&
                                  !provider
                                      .searchTrips(
                                          _searchController.text, _searchType)
                                      .contains(trip)) {
                                return Container(); // Hide unmatched items
                              }

                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0,
                                        right: 20,
                                        bottom: 10,
                                        top: 20),
                                    child: Material(
                                      elevation: 10,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: coloringThemes.containers),
                                        margin: EdgeInsets.all(0.0),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "${trip['name']}",
                                                    style: GoogleFonts.poppins(
                                                        color: coloringThemes
                                                            .primary,
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "${trip['createdAt'].toString().substring(0, 10)}",
                                                    style:
                                                        GoogleFonts.quicksand(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Container(
                                                    height: 8,
                                                    width: 8,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: coloringThemes
                                                            .primary),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                    "${trip['duration']} mins",
                                                    style:
                                                        GoogleFonts.quicksand(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "${trip['plateNumber']}",
                                                    style:
                                                        GoogleFonts.quicksand(
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "${trip['city']}",
                                                          style: GoogleFonts
                                                              .quicksand(
                                                                  color: Colors
                                                                      .black87,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Container(
                                                          height: 8,
                                                          width: 8,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color:
                                                                  coloringThemes
                                                                      .primary),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          "${trip['distance'].toStringAsFixed(1)} m",
                                                          style: GoogleFonts
                                                              .quicksand(
                                                                  color: Colors
                                                                      .black87,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      "${trip['fees'].toStringAsFixed(1)} USD",
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color:
                                                                  coloringThemes
                                                                      .primary,
                                                              fontSize: 22,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
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
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 15.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Material(
                                          elevation: 10,
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Container(
                                            height:
                                                !_authProvider.canEdit ? 0 : 45,
                                            width:
                                                !_authProvider.canEdit ? 0 : 45,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                color: coloringThemes.primary),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.edit,
                                                size: _authProvider.canEdit
                                                    ? 16
                                                    : 16,
                                                color: Colors.white,
                                              ),
                                              onPressed: () =>
                                                  _authProvider.canEdit
                                                      ? _showEditTripDialog(
                                                          context, trip)
                                                      : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
