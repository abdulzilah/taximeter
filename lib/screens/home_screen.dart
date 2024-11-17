import 'package:flutter/material.dart';
import 'package:taximeter_project/screens/createTrip_screen.dart';
import 'package:taximeter_project/utils/colors.dart';
import '../providers/auth_provider.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  // List of pages that will be switched using IndexedStack
  final List<Widget> _pages = [
    CreateTripScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  // Method to change the index when a tab is selected
  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: 75,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: coloringThemes.primary,
                border:
                    Border.all(width: 2, color: coloringThemes.Mainbackground)),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                    child: Icon(
                      Icons.home,
                      size: 28,
                      color: coloringThemes.Mainbackground,
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: coloringThemes.containers,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                    child: Icon(
                      Icons.history,
                      size: 28,
                      color: coloringThemes.Mainbackground,
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: coloringThemes.containers,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _currentIndex = 2;
                      });
                    },
                    child: Icon(
                      Icons.settings,
                      size: 28,
                      color: coloringThemes.Mainbackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )

        // BottomNavigationBar(
        //   currentIndex: _currentIndex,
        //   onTap: _onTabSelected,
        //   items: [
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.directions_car),
        //       label: 'Trips',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.history),
        //       label: 'History',
        //     ),
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.settings),
        //       label: 'Settings',
        //     ),
        //   ],
        // ),

        );
  }
}
