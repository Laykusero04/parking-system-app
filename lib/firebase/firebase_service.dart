import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  static Future<int> getParkCount() async {
    final snapshot = await FirebaseFirestore.instance.collection('parks').get();
    return snapshot.docs.length;
  }

  static Future<int> getUserCount() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.length;
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
