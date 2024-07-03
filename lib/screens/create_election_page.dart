import 'package:flutter/material.dart';
import '../helpers/database.dart';
import 'dashboard_page.dart';

class CreateElectionPage extends StatefulWidget {
  final String name;
  final String email;

  CreateElectionPage({required this.name, required this.email});

  @override
  _CreateElectionPageState createState() => _CreateElectionPageState();
}

class _CreateElectionPageState extends State<CreateElectionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final List<TextEditingController> _candidateControllers = [];
  final List<TextEditingController> _voterControllers = [];

  @override
  void dispose() {
    _nameController.dispose();
    for (var controller in _candidateControllers) {
      controller.dispose();
    }
    for (var controller in _voterControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCandidateField() {
    setState(() {
      _candidateControllers.add(TextEditingController());
    });
  }

  void _removeCandidateField(int index) {
    setState(() {
      _candidateControllers.removeAt(index).dispose();
    });
  }

  void _addVoterField() {
    setState(() {
      _voterControllers.add(TextEditingController());
    });
  }

  void _removeVoterField(int index) {
    setState(() {
      _voterControllers.removeAt(index).dispose();
    });
  }

  Future<void> _createElection() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final candidates = _candidateControllers.map((c) => c.text).toList();
      final voters = _voterControllers.map((c) => c.text).toList();

      try {
        final connection = await Database().getConnection();

        // Verify voters
        List<String> nonExistentVoters = [];
        for (var email in voters) {
          final userResult = await connection.query(
            'SELECT email FROM users WHERE email = @email',
            substitutionValues: {'email': email},
          );
          if (userResult.isEmpty) {
            nonExistentVoters.add(email);
          }
        }

        if (nonExistentVoters.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'The following users do not exist: ${nonExistentVoters.join(', ')}'),
            ),
          );
          return;
        }

        // Create election
        final electionResult = await connection.query(
          'INSERT INTO elections (name, creator_email) VALUES (@name, @creator_email) RETURNING id',
          substitutionValues: {
            'name': name,
            'creator_email': widget.email,
          },
        );

        if (electionResult.isEmpty || electionResult.first.isEmpty) {
          throw Exception('Failed to create election or retrieve ID');
        }

        final Map<String, dynamic> row = electionResult.first.toColumnMap();
        final idValue = row['id'];
        final electionId = idValue is int ? idValue : int.parse(idValue.toString());

        // Insert candidates
        for (var candidate in candidates) {
          await connection.query(
            'INSERT INTO candidates (name, election_id) VALUES (@name, @election_id)',
            substitutionValues: {
              'name': candidate,
              'election_id': electionId,
            },
          );
        }

        // Assign voters
        for (var email in voters) {
          await connection.query(
            'INSERT INTO assigned_elections (user_email, election_id) VALUES (@user_email, @election_id)',
            substitutionValues: {
              'user_email': email,
              'election_id': electionId,
            },
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Election created successfully')),
        );

        // Navigate back to the dashboard, passing the name and email
        Navigator.pushReplacementNamed(
          context,
          '/dashboard',
          arguments: {'name': widget.name, 'email': widget.email},
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating election: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Election'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name of Election'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the name of the election';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                Text('Candidates of Election'),
                ..._candidateControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  TextEditingController controller = entry.value;
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(labelText: 'Candidate'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the candidate\'s name';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () => _removeCandidateField(index),
                      ),
                    ],
                  );
                }).toList(),
                TextButton(
                  onPressed: _addCandidateField,
                  child: Text('Add Candidate'),
                ),
                SizedBox(height: 10),
                Text('Voters (Emails)'),
                ..._voterControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  TextEditingController controller = entry.value;
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          decoration: InputDecoration(labelText: 'Voter Email'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the voter\'s email';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: () => _removeVoterField(index),
                      ),
                    ],
                  );
                }).toList(),
                TextButton(
                  onPressed: _addVoterField,
                  child: Text('Add Voter'),
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
      ),
    );
  }
}
