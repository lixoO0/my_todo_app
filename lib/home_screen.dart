import 'package:flutter/material.dart';
import 'package:my_todo_app/login_screen.dart';
import 'package:my_todo_app/model/todo_model.dart';
import 'package:my_todo_app/services/auth_services.dart';
import 'package:my_todo_app/services/database_services.dart';
import 'package:my_todo_app/widgets/complited_widget.dart';
import 'package:my_todo_app/widgets/pending_widgets.dart';
import 'package:provider/provider.dart';
import 'package:my_todo_app/providers/theme_provider.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _buttonIndex = 0;

  final _widgets = [
    PendingWidget(),
    ComplitedWidget(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: textColor,
        title: const Text("ToDo"),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFilterButton("Pending", 0, isDark),
                _buildFilterButton("Completed", 1, isDark),
              ],
            ),
            const SizedBox(height: 30),
            _widgets[_buttonIndex],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () {
          _showTaskDialog(context);
        },
      ),
    );
  }

  Widget _buildFilterButton(String label, int index, bool isDark) {
    bool isSelected = _buttonIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          _buttonIndex = index;
        });
      },
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width / 3,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.indigo
              : (isDark ? Colors.grey[800] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isSelected ? 20 : 18,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  void _showTaskDialog(BuildContext context, {Todo? todo}) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();
    final DatabaseServices _databaseService = DatabaseServices();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          title: Text(
            todo == null ? "Add task" : "Edit task",
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (todo == null) {
                  await _databaseService.addTodoTask(
                    _titleController.text,
                    _descriptionController.text,
                  );
                } else {
                  await _databaseService.updateTodo(
                    todo.id,
                    _titleController.text,
                    _descriptionController.text,
                  );
                }
                Navigator.pop(context);
              },
              child: Text(todo == null ? "Add" : "Edit"),
            ),
          ],
        );
      },
    );
  }
}
