import 'package:flutter/material.dart';
import '../helpers/database.dart';
import '../helpers/validator.dart';
import 'login.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Validator validator = Validator(Database());
  bool _isEmailUnique = true;
  String? _emailError;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkEmailUnique(String email) async {
    _isEmailUnique = await validator.isEmailUnique(email);
    if (!_isEmailUnique) {
      setState(() {
        _emailError = 'Email already exists';
      });
    } else {
      setState(() {
        _emailError = null;
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      await _checkEmailUnique(_emailController.text);
      if (_emailError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_emailError!)),
        );
        return;
      }

      final username = _usernameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;

      try {
        final connection = await Database().getConnection();
        await connection.query(
          'INSERT INTO users (email, username, password) VALUES (@email, @username, @password)',
          substitutionValues: {
            'email': email,
            'username': username,
            'password': password,
          },
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
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
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _emailError,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!validator.isValidEmailFormat(value)) {
                    return 'Enter a valid email';
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
                  } else if (!validator.isValidPassword(value)) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}