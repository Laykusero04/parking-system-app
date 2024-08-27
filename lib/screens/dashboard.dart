import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/drawer.dart';
import '../components/floatingButton.dart';
import 'parkInOut.dart';

class Dashboard extends StatefulWidget {
  final bool isAdmin;
  const Dashboard({super.key, required this.isAdmin});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {
  int parkCount = 0;
  int userCount = 0;
  int maxCar = 10;
  int maxMotorcycle = 30;
  int currentParkedCars = 0;
  int currentParkedMotorcycles = 0;
  int _currentIndex = 0; // For BottomNavigationBar
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addObserver(this);
    fetchData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    final firestore = FirebaseFirestore.instance;
    final parkSnapshot = await firestore.collection('parks').get();
    final userSnapshot = await firestore.collection('users').get();
    final carSnapshot = await firestore
        .collection('plate_numbers')
        .where('vehicle_type', isEqualTo: 'Car')
        .where('time_out', isNull: true)
        .get();
    final motorcycleSnapshot = await firestore
        .collection('plate_numbers')
        .where('vehicle_type', isEqualTo: 'Motorcycle')
        .where('time_out', isNull: true)
        .get();
    final settingsSnapshot =
        await firestore.collection('settings').doc('parking_slots').get();

    setState(() {
      parkCount = parkSnapshot.docs.length;
      userCount = userSnapshot.docs.length;
      currentParkedCars = carSnapshot.docs.length;
      currentParkedMotorcycles = motorcycleSnapshot.docs.length;
      maxCar = settingsSnapshot.data()?['max_cars'] ?? 10;
      maxMotorcycle = settingsSnapshot.data()?['max_motorcycles'] ?? 30;
    });
  }

  Future<void> _refreshData() async {
    await fetchData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Parkinout(
          isParkIn: index == 0,
          isAdmin: widget.isAdmin,
        ),
      ),
    ).then((_) =>
        fetchData()); // Refresh data when returning from Parkinout screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Management'),
        backgroundColor: Colors.amber,
      ),
      drawer: CustomDrawer(isAdmin: widget.isAdmin),
      body: Focus(
        focusNode: _focusNode,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.amber,
          backgroundColor: Colors.white,
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16.0),
            children: [
              if (widget.isAdmin) ...[
                _buildInfoCard('', 'Total Parks', parkCount.toString()),
                _buildInfoCard('', 'Total Users', userCount.toString()),
                _buildInfoCard(
                    'Cars', 'Max: $maxCar', 'Current: $currentParkedCars'),
                _buildInfoCard('Motorcycles', 'Max: $maxMotorcycle',
                    'Current: $currentParkedMotorcycles'),
              ] else ...[
                _buildInfoCard(
                    'Cars', 'Max: $maxCar', 'Current: $currentParkedCars'),
                _buildInfoCard('Motorcycles', 'Max: $maxMotorcycle',
                    'Current: $currentParkedMotorcycles'),
              ],
            ],
          ),
        ),
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            fetchData();
          }
        },
      ),
      floatingActionButton: widget.isAdmin ? const Floatingbutton() : null,
      bottomNavigationBar: widget.isAdmin
          ? null
          : BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.login),
                  label: 'Park In',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.exit_to_app),
                  label: 'Park Out',
                ),
              ],
              currentIndex: _currentIndex,
              selectedItemColor: Colors.amber[800],
              onTap: _onItemTapped,
            ),
    );
  }

  Widget _buildInfoCard(String title, String maxValue, String currentValue) {
    return Card(
      color: Colors.grey[800],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currentValue,
            style: const TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              Text(
                maxValue,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
