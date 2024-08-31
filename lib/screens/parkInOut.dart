import 'package:flutter/material.dart';

class Parkinout extends StatefulWidget {
  final bool isParkIn;
  final bool isAdmin;
  const Parkinout({super.key, required this.isParkIn, required this.isAdmin});

  @override
  State<Parkinout> createState() => _ParkinoutState();
}

class _ParkinoutState extends State<Parkinout> {
  late bool isParkIn;

  @override
  void initState() {
    super.initState();
    isParkIn = widget.isParkIn;
  }

  void _toggleParkInOut() {
    setState(() {
      isParkIn = !isParkIn;
    });
  }

  void _selectVehicle(String vehicleType) async {
    Navigator.pushNamed(
      context,
      '/camera',
      arguments: {
        'vehicleType': vehicleType,
        'isParkIn': isParkIn,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isParkIn ? Colors.green[700]! : Colors.red[700]!,
              isParkIn ? Colors.green[300]! : Colors.red[300]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isParkIn ? 'Park In' : 'Park Out',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select your vehicle type',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildVehicleButton('Car', Icons.directions_car),
                      const SizedBox(height: 16),
                      _buildVehicleButton('Motorcycle', Icons.motorcycle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleParkInOut,
        backgroundColor: Colors.white,
        icon: Icon(
          isParkIn ? Icons.exit_to_app : Icons.login,
          color: isParkIn ? Colors.red : Colors.green,
        ),
        label: Text(
          isParkIn ? 'Switch to Park Out' : 'Switch to Park In',
          style: TextStyle(
            color: isParkIn ? Colors.red : Colors.green,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/parkingHistory'),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleButton(String vehicleType, IconData icon) {
    return GestureDetector(
      onTap: () => _selectVehicle(vehicleType),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(width: 16),
            Text(
              vehicleType,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
