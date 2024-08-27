import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../components/drawer.dart';

class Parkinghistory extends StatefulWidget {
  final bool isAdmin;
  const Parkinghistory({Key? key, required this.isAdmin}) : super(key: key);

  @override
  State<Parkinghistory> createState() => _ParkinghistoryState();
}

class _ParkinghistoryState extends State<Parkinghistory> {
  String _selectedFilter = 'All';
  List<String> filterOptions = [
    'All',
    'Today',
    'This Month',
    'Still Parking',
    'Finished Parking'
  ];

  String formatDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM d, yyyy h:mm a').format(dateTime);
  }

  Stream<QuerySnapshot> _getQuery() {
    return FirebaseFirestore.instance
        .collection('plate_numbers')
        .orderBy('date', descending: true)
        .snapshots();
  }

  List<DocumentSnapshot> _filterDocuments(List<DocumentSnapshot> documents) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final startOfMonth = DateTime(now.year, now.month, 1);

    return documents.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp).toDate();
      final isStillParking = data['time_out'] == null;

      switch (_selectedFilter) {
        case 'Today':
          return date
                  .isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
              date.isBefore(startOfDay.add(const Duration(days: 1)));
        case 'This Month':
          return date
                  .isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
              date.isBefore(DateTime(now.year, now.month + 1, 1));
        case 'Still Parking':
          return isStillParking;
        case 'Finished Parking':
          return !isStillParking;
        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  Future<void> _confirmDelete(
      BuildContext context, DocumentReference documentRef) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete History'),
          content: const Text('Are you sure you want to delete this history?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                documentRef.delete();
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking History'),
        backgroundColor: Colors.amber,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: _selectedFilter,
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFilter = newValue!;
                });
              },
              items:
                  filterOptions.map<DropdownMenuItem<String>>((String value) {
                if (value == 'Still Parking') {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Column(
                      children: [
                        const Divider(color: Colors.grey),
                        Text(value),
                      ],
                    ),
                  );
                }
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(isAdmin: widget.isAdmin),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: _getQuery(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No data available'));
            }

            final filteredDocs = _filterDocuments(snapshot.data!.docs);

            if (filteredDocs.isEmpty) {
              return const Center(child: Text('No matching records found'));
            }

            return ListView(
              children: filteredDocs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                bool isStillParking = data['time_out'] == null;

                Color cardColor =
                    isStillParking ? Colors.green[800]! : Colors.grey[800]!;

                return Card(
                  color: cardColor,
                  child: ListTile(
                    title: Text(
                      'Plate Number: ${data['plate_number'] ?? 'Unknown'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Type of Vehicle: ${data['vehicle_type'] ?? 'Unknown'}\n'
                      'Time in: ${data['time_in'] != null ? formatDateTime(data['time_in']) : 'Unknown'}\n'
                      'Time out: ${data['time_out'] != null ? formatDateTime(data['time_out']) : 'Not out yet'}\n'
                      'Date: ${data['date'] != null ? (data['date']) : 'Unknown'}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: widget.isAdmin
                        ? IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              _confirmDelete(context, document.reference);
                            },
                          )
                        : null,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
