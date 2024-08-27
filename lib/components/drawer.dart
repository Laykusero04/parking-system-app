import 'package:flutter/material.dart';
import 'package:parking_appv1/firebase/firebase_service.dart';

class CustomDrawer extends StatelessWidget {
  final bool isAdmin;
  const CustomDrawer({Key? key, required this.isAdmin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.amber,
            ),
            child: Text('Menu'),
          ),
          ListTile(
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed('/dashboard', arguments: isAdmin);
            },
          ),
          ListTile(
            title: const Text('Parking History'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed('/parkingHistory', arguments: isAdmin);
            },
          ),
          if (isAdmin)
            ListTile(
              title: const Text('Manage User'),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed('/manageUser', arguments: isAdmin);
              },
            ),
          ListTile(
            title: const Text('Profile'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed('/profile', arguments: isAdmin);
            },
          ),
          ListTile(
            tileColor: Colors.orange[900],
            title: Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              await FirebaseService.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}
