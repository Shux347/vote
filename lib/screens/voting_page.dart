import 'package:flutter/material.dart';
import '../helpers/database.dart';
class VotingPage extends StatefulWidget {
  @override
  _VotingPageState createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  final _formKey = GlobalKey<FormState>();
  final _electionIdController = TextEditingController();

  // Retrieve face data for user
  Future<List<int>?> getFaceData(String userId) async {
    var db = Database();
    var conn = await db.getConnection();

    var result = await conn.query(
      'SELECT face_data FROM users WHERE id = @id',
      substitutionValues: {
        'id': userId,
      },
    );

    if (result.isNotEmpty) {
      return result.first[0] as List<int>;
    }
    return null;
  }

  bool compareFaces(List<int> storedFaceData, List<int> inputFaceData) {
    // Implement face comparison logic
    // This is a dummy implementation, replace with actual comparison logic
    return storedFaceData.length == inputFaceData.length && storedFaceData.every((element) => inputFaceData.contains(element));
  }

  void _vote(String userId, String electionId, List<int> inputFaceData) async {
    var storedFaceData = await getFaceData(userId);

    if (storedFaceData != null && compareFaces(storedFaceData, inputFaceData)) {
      var db = Database();
      var conn = await db.getConnection();
      await conn.query(
        'INSERT INTO votes (election_id, user_id) VALUES (@a, @b)',
        substitutionValues: {
          'a': electionId,
          'b': userId,
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vote cast successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Face verification failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Assume userId is passed to this page
    final String userId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(title: Text('Vote')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
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
              // Assume face data is captured and stored in inputFaceData
              // This should be replaced with actual face capture logic
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    List<int> inputFaceData = [1, 2, 3, 4, 5]; // Dummy data for illustration
                    _vote(userId, _electionIdController.text, inputFaceData);
                  }
                },
                child: Text('Vote'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
