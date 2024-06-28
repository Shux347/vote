import 'package:flutter/material.dart';
import '../helpers/database.dart';
class CreateElectionPage extends StatefulWidget {
  @override
  _CreateElectionPageState createState() => _CreateElectionPageState();
}

class _CreateElectionPageState extends State<CreateElectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _electionNameController = TextEditingController();
  final _assignedUsersController = TextEditingController();

  void _createElection() async {
    if (_formKey.currentState!.validate()) {
      var db = Database();
      var conn = await db.getConnection();

      await conn.query(
        'INSERT INTO elections (name) VALUES (@a)',
        substitutionValues: {
          'a': _electionNameController.text,
        },
      );

      // Get the election ID
      var result = await conn.query(
        'SELECT id FROM elections WHERE name = @a',
        substitutionValues: {
          'a': _electionNameController.text,
        },
      );
      var electionId = result.first[0];

      // Assign users to the election
      var emails = _assignedUsersController.text.split(',');
      for (var email in emails) {
        await conn.query(
          'INSERT INTO election_users (election_id, user_email) VALUES (@a, @b)',
          substitutionValues: {
            'a': electionId,
            'b': email.trim(),
          },
        );
      }

      // Navigate to the admin dashboard or election results
      Navigator.pushNamed(context, '/admin_dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Election')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _electionNameController,
                decoration: InputDecoration(labelText: 'Election Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an election name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _assignedUsersController,
                decoration: InputDecoration(labelText: 'Assign Users (comma-separated emails)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter emails of users to assign';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createElection,
                child: Text('Create Election'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
