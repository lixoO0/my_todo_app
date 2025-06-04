import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_todo_app/model/todo_model.dart';

class DatabaseServices {
  final CollectionReference todoCollection =
      FirebaseFirestore.instance.collection('todos');

  final Box<Todo> todoBox = Hive.box<Todo>('todos_box');

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  Future<void> addTodoTask(String title, String description) async {
    // 1.1) Створюємо обʼєкт todo
    final newTodo = Todo(
      id: '',
      userId: _userId,
      title: title,
      description: description,
      completed: false,
      timeStamp: DateTime.now(),
    );

    // Пишемо у Firestore — створюємо новий документ
    final docRef = await todoCollection.add({
      'userId': newTodo.userId,
      'title': newTodo.title,
      'description': newTodo.description,
      'completed': newTodo.completed,
      'createdAt': Timestamp.fromDate(newTodo.timeStamp),
    });

    newTodo.id = docRef.id;

    // Додаємо у Hive
    await todoBox.add(newTodo);
  }

  Future<void> updateTodo(String id, String title, String description) async {
    await todoCollection.doc(id).update({
      'title': title,
      'description': description,
    });

    final todo = todoBox.values.firstWhere((t) => t.id == id && t.userId == _userId);
    todo.title = title;
    todo.description = description;
    await todo.save();
  }

  Future<void> updateTodoStatus(String id, bool completed) async {
    await todoCollection.doc(id).update({
      'completed': completed,
    });

    final todo = todoBox.values.firstWhere((t) => t.id == id && t.userId == _userId);
    todo.completed = completed;
    await todo.save();
  }

  Future<void> deleteTodo(String id) async {
    await todoCollection.doc(id).delete();

    final todo = todoBox.values.firstWhere((t) => t.id == id && t.userId == _userId);
    await todo.delete();
  }

  Stream<List<Todo>> get todos {
    return todoCollection
        .where('userId', isEqualTo: _userId)
        .where('completed', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_todoListFromSnapshot);
  }

  Stream<List<Todo>> get completedTodos {
    return todoCollection
        .where('userId', isEqualTo: _userId)
        .where('completed', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_todoListFromSnapshot);
  }

  List<Todo> _todoListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Todo.fromSnapshot(doc);
    }).toList();
  }

  List<Todo> get pendingTodosLocal {
    return todoBox.values
        .where((t) => t.userId == _userId && t.completed == false)
        .toList();
  }

  List<Todo> get completedTodosLocal {
    return todoBox.values
        .where((t) => t.userId == _userId && t.completed == true)
        .toList();
  }
}
