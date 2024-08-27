import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Floatingbutton extends StatefulWidget {
  const Floatingbutton({Key? key}) : super(key: key);

  @override
  _FloatingbuttonState createState() => _FloatingbuttonState();
}

class _FloatingbuttonState extends State<Floatingbutton> {
  int _carSlots = 10;
  int _motorcycleSlots = 30;

  @override
  void initState() {
    super.initState();
    _fetchCurrentMaxSlots();
  }

  Future<void> _fetchCurrentMaxSlots() async {
    final firestore = FirebaseFirestore.instance;
    final settingsDoc =
        await firestore.collection('settings').doc('parking_slots').get();
    if (settingsDoc.exists) {
      setState(() {
        _carSlots = settingsDoc.data()?['max_cars'] ?? 10;
        _motorcycleSlots = settingsDoc.data()?['max_motorcycles'] ?? 30;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        _showAddVehicleDialog(context);
      },
      backgroundColor: Colors.amber,
      child: const Icon(Icons.settings),
    );
  }

  void _showAddVehicleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adjust Maximum Parking Slots'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSlotAdjuster('Cars', _carSlots, (value) {
                    setState(() => _carSlots = value);
                  }),
                  const SizedBox(height: 16),
                  _buildSlotAdjuster('Motorcycles', _motorcycleSlots, (value) {
                    setState(() => _motorcycleSlots = value);
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _updateMaxSlots();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSlotAdjuster(String title, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: () => onChanged(value - 1 > 0 ? value - 1 : 0),
            ),
            Text(value.toString()),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _updateMaxSlots() async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('settings').doc('parking_slots').set({
      'max_cars': _carSlots,
      'max_motorcycles': _motorcycleSlots,
    }, SetOptions(merge: true));
  }
}
