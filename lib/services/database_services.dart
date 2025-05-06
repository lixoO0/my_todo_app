import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseServices {
  final CollectionReference todoCollection = FirebaseFirestore.instance
      .collection('todos');

  User? user = FirebaseAuth.instance.currentUser;

  //add todo task
  Future<DocumentReference> addTodoTask(
    String title,
    String description,
  ) async {
    return await todoCollection.add({
      'userId': user!.uid,
      'title': title,
      'description': description,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
