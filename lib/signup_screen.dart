import 'package:flutter/material.dart';
import 'package:my_todo_app/services/auth_services.dart';

class SignupScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1d2630),
      appBar: AppBar(
        title: Text("Create Account"),
        backgroundColor: Color(0xff1d2630),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(height:50),
              TextField(
                controller:_emailController,
                style:TextStyle(color: Colors.white),
                decoration:InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white60),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.white60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}