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
      backgroundColor: const Color(0xFFFFF7D4),
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

            return ListView.builder(
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    filteredDocs[index].data() as Map<String, dynamic>;
                bool isStillParking = data['time_out'] == null;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isStillParking
                              ? [Colors.amber[400]!, Colors.amber[900]!]
                              : [Colors.brown[600]!, Colors.brown[900]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  data['plate_number'] ?? 'Unknown',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    data['vehicle_type'] ?? 'Unknown',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(Icons.login, 'Time in',
                                formatDateTime(data['time_in'])),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              Icons.logout,
                              'Time out',
                              data['time_out'] != null
                                  ? formatDateTime(data['time_out'])
                                  : 'Not out yet',
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isStillParking
                                      ? 'Currently Parking'
                                      : 'Parking Completed',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (widget.isAdmin)
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.white),
                                    onPressed: () {
                                      _confirmDelete(context,
                                          filteredDocs[index].reference);
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white, fontSize: 16),
              children: [
                TextSpan(
                    text: '$label: ',
                    style: TextStyle(color: Colors.white.withOpacity(0.7))),
                TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
