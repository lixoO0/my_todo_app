import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;

  @HiveField(4)
  bool completed;

  @HiveField(5)
  DateTime timeStamp;

  Todo({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.completed = false,
    DateTime? timeStamp,
  }) : timeStamp = timeStamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'description': description,
        'completed': completed,
        'createdAt': Timestamp.fromDate(timeStamp),
      };

  factory Todo.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawTimestamp = data['createdAt'];
    DateTime parsedDate;
    if (rawTimestamp is Timestamp) {
      parsedDate = rawTimestamp.toDate();
    } else if (rawTimestamp is DateTime) {
      parsedDate = rawTimestamp;
    } else {
      parsedDate = DateTime.now();
    }

    return Todo(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      completed: data['completed'] as bool,
      timeStamp: parsedDate,
    );
  }
}
