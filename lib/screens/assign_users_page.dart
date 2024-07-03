import 'package:flutter/material.dart';
import '../helpers/database.dart';

class AssignUsersPage extends StatefulWidget {
  @override
  _AssignUsersPageState createState() => _AssignUsersPageState();
}

class _AssignUsersPageState extends State<AssignUsersPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _electionIdController = TextEditingController();

  Future<void> _assignUser() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final electionId = int.tryParse(_electionIdController.text);

      if (electionId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid election ID')),
        );
        return;
      }

      try {
        final connection = await Database().getConnection();
        final userResult = await connection.query(
          'SELECT email FROM users WHERE email = @Email',
          substitutionValues: {'email': email},
        );

        if (userResult.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not found')),
          );
          return;
        }

        await connection.query(
          'INSERT INTO assigned_elections (user_email, election_id) VALUES (@user_email, @election_id)',
          substitutionValues: {
            'user_email': email,
            'election_id': electionId,
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User assigned to election successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Users to Election'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'User Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the user email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _electionIdController,
                decoration: InputDecoration(labelText: 'Election ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the election ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _assignUser,
                child: Text('Assign User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
