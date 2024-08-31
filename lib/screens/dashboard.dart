import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../components/drawer.dart';
import '../components/floatingButton.dart';
import 'parkInOut.dart';

class Dashboard extends StatefulWidget {
  final bool isAdmin;
  const Dashboard({Key? key, required this.isAdmin}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int userCount = 0;
  int maxCar = 10;
  int maxMotorcycle = 30;
  int currentParkedCars = 0;
  int currentParkedMotorcycles = 0;
  int totalParkCount = 0;
  int _currentIndex = 0;
  late FocusNode _focusNode;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _refreshTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => fetchData());
    fetchData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    if (!mounted) return;

    final firestore = FirebaseFirestore.instance;
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

    final allParkingSnapshot = await firestore
        .collection('plate_numbers')
        .orderBy('date', descending: true)
        .limit(1000)
        .get();

    if (mounted) {
      setState(() {
        totalParkCount = allParkingSnapshot.docs.length;
        userCount = userSnapshot.docs.length;
        currentParkedCars = carSnapshot.docs.length;
        currentParkedMotorcycles = motorcycleSnapshot.docs.length;
        maxCar = settingsSnapshot.data()?['max_cars'] ?? 10;
        maxMotorcycle = settingsSnapshot.data()?['max_motorcycles'] ?? 30;
      });
    }
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
    ).then((_) => fetchData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7D4),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.amber,
      ),
      drawer: CustomDrawer(isAdmin: widget.isAdmin),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.amber,
        backgroundColor: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(14.0),
          children: [
            if (widget.isAdmin) ...[
              _buildSectionTitle('Overview'),
              _buildInfoRow('Total Parks', totalParkCount.toString(),
                  Icons.local_parking),
              _buildInfoRow('Total Users', userCount.toString(), Icons.people),
              const SizedBox(height: 24),
            ],
            _buildSectionTitle('Parking Status'),
            _buildParkingStatusCard(
                'Cars', maxCar, currentParkedCars, Icons.directions_car),
            const SizedBox(height: 16),
            _buildParkingStatusCard('Motorcycles', maxMotorcycle,
                currentParkedMotorcycles, Icons.motorcycle),
          ],
        ),
      ),
      floatingActionButton: widget.isAdmin ? const Floatingbutton() : null,
      bottomNavigationBar: widget.isAdmin
          ? null
          : BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.login),
                  activeIcon: Icon(Icons.login, size: 30),
                  label: 'Park In',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.exit_to_app),
                  activeIcon: Icon(Icons.exit_to_app, size: 30),
                  label: 'Park Out',
                ),
              ],
              currentIndex: _currentIndex,
              selectedItemColor: Colors.amber[800],
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.brown[800],
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 14.0,
              unselectedFontSize: 12.0,
              showUnselectedLabels: true,
              elevation: 8.0,
              onTap: _onItemTapped,
              iconSize: 26.0,
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4C3C3C),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber[700], size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.brown[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color(0xFF4C3C3C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingStatusCard(
      String title, int max, int current, IconData icon) {
    double occupancyRate = current / max;
    Color statusColor = occupancyRate < 0.7
        ? Colors.green
        : occupancyRate < 0.9
            ? Colors.orange
            : Colors.red;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.brown[500]!, Colors.brown[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: Colors.amber[700], size: 28),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(occupancyRate * 100).toStringAsFixed(0)}% Full',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: occupancyRate,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Current: $current / Max: $max',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
