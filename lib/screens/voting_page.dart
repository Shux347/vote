import 'package:flutter/material.dart';
import '../helpers/database.dart';

class VotingPage extends StatefulWidget {
  final int electionId;
  final String userEmail;  // Add userEmail parameter

  VotingPage({required this.electionId, required this.userEmail});

  @override
  _VotingPageState createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  List<Map<String, dynamic>> _candidates = [];
  int? _selectedCandidateId;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    try {
      final connection = await Database().getConnection();
      final results = await connection.query(
        'SELECT id, name FROM candidates WHERE election_id = @election_id',
        substitutionValues: {'election_id': widget.electionId},
      );

      setState(() {
        _candidates = results.map((row) => row.toColumnMap()).toList();
      });

      if (_candidates.isEmpty) {
        print('No candidates found for this election.');
      } else {
        print('Candidates: ${_candidates}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading candidates: $e')),
      );
      print('Error loading candidates: $e');
    }
  }

  Future<void> _submitVote() async {
    if (_selectedCandidateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a candidate')),
      );
      return;
    }

    try {
      final connection = await Database().getConnection();

      await connection.query(
        'INSERT INTO votes (election_id, candidate_id, user_email) VALUES (@election_id, @candidate_id, @user_email)',
        substitutionValues: {
          'election_id': widget.electionId,
          'candidate_id': _selectedCandidateId,
          'user_email': widget.userEmail,  // Use userEmail from widget
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vote submitted successfully')),
      );

      // Navigate back to the dashboard after voting
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting vote: $e')),
      );
      print('Error submitting vote: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vote in Election'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Select a candidate:', style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: _candidates.length,
                itemBuilder: (context, index) {
                  final candidate = _candidates[index];
                  return RadioListTile<int>(
                    title: Text(candidate['name']),
                    value: candidate['id'],
                    groupValue: _selectedCandidateId,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedCandidateId = value;
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _submitVote,
              child: Text('Submit Vote'),
            ),
          ],
        ),
      ),
    );
  }
}
