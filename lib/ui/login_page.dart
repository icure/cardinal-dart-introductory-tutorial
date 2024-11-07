import 'package:flutter/material.dart';
import 'menu_page.dart';
import '../cardinal/create_sdk.dart';
import 'dart:developer' as developer;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<bool> _performLogin(String username, String password) async {
    try {
      await createSdk(username, password);
      mainUsername = username;
      return true;
    } on Exception catch(e) {
      developer.log('Login failed: $e', name: 'LoginPage');
      return false;
    }
  }

  // Async login function that calls _performLogin
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      bool success = await _performLogin(_usernameController.text, _passwordController.text);
      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MenuPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}