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
    // Navigate to parking history after successful park in/out
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
      appBar: AppBar(
        title: Text(isParkIn ? 'Park in' : 'Park out'),
        backgroundColor: isParkIn ? Colors.green : Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          // Navigate to Parking History screen
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/parkingHistory');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _buildVehicleButton('Car',
                    isParkIn ? Colors.amber : Color.fromARGB(255, 61, 61, 61)),
                _buildVehicleButton('Motorcycle',
                    isParkIn ? Color.fromARGB(255, 61, 61, 61) : Colors.amber),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleParkInOut,
        backgroundColor: isParkIn ? Colors.red : Colors.green,
        child: Icon(isParkIn ? Icons.exit_to_app : Icons.login),
      ),
    );
  }

  Widget _buildVehicleButton(String vehicleType, Color color) {
    return GestureDetector(
      onTap: () => _selectVehicle(vehicleType),
      child: Container(
        margin: const EdgeInsets.all(8),
        color: color,
        child: Center(
          child: Text(
            vehicleType,
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
