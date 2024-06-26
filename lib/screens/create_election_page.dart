import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';

class CreateElectionPage extends StatefulWidget {
  const CreateElectionPage({super.key});

  @override
  CreateElectionPageState createState() => CreateElectionPageState();
}

class CreateElectionPageState extends State<CreateElectionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _electionNameController = TextEditingController();
  final List<TextEditingController> _candidateControllers = [];
  late DbHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
  }

  @override
  void dispose() {
    _electionNameController.dispose();
    for (var controller in _candidateControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCandidateField() {
    setState(() {
      _candidateControllers.add(TextEditingController());
    });
  }

  void _saveElection() async {
    if (_formKey.currentState?.validate() == true) {
      String electionId = DateTime.now().millisecondsSinceEpoch.toString();
      await dbHelper.db.then((db) {
        db.insert('Election', {'id': electionId, 'name': _electionNameController.text});
        for (var controller in _candidateControllers) {
          db.insert('Candidate', {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'name': controller.text,
            'electionId': electionId,
          });
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Election created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Election')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _electionNameController,
                decoration: InputDecoration(labelText: 'Election Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter election name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _candidateControllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        controller: _candidateControllers[index],
                        decoration: InputDecoration(labelText: 'Candidate ${index + 1}'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter candidate name';
                          }
                          return null;
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addCandidateField,
                child: const Text('Add Candidate'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveElection,
                child: const Text('Create Election'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
