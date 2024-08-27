import 'package:flutter/material.dart';

class Ticket extends StatefulWidget {
  const Ticket({super.key});

  @override
  State<Ticket> createState() => _TicketState();
}

class _TicketState extends State<Ticket> {
  final _parkNoController = TextEditingController();

  Future<void> _printTicket() async {
    // Implement printing functionality
    print('Printing ticket...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket'),
        backgroundColor: Colors.amber,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey,
                  child: const Center(child: Text('LOGO')),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name of Company',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Location'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Center(
                child: Text('Parking Ticket',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            const SizedBox(height: 24),
            _buildTicketInfo('Date:', '08/17/2024'),
            _buildTicketInfo('Plate No:', '9589WF'),
            _buildTicketInfo('Time in:', '3:00 pm'),
            _buildTicketInfo('Type:', 'Motorcycle'),
            const SizedBox(height: 16),
            const Text(
                '[Your Company Name] recognizes this ticket holder as the legitimate owner. Comply with all site rules. Not responsible for any damage to vehicle no matter the circumstance.',
                style: TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Park No:'),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _parkNoController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _printTicket,
                  child: const Text('Print'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }
}
