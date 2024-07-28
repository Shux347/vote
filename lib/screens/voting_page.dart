// ignore_for_file: unnecessary_brace_in_string_interps, use_build_context_synchronously, prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../helpers/database.dart';

class VotingPage extends StatefulWidget {
  final int electionId;
  final String userEmail;

  VotingPage({required this.electionId, required this.userEmail});

  @override
  _VotingPageState createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  final LocalAuthentication auth = LocalAuthentication();
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

    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to vote',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } on Exception catch (e) {
      print(e);
    }

    if (!authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fingerprint authentication failed')),
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
          'user_email': widget.userEmail,
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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Select a candidate:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _candidates.length,
                itemBuilder: (context, index) {
                  final candidate = _candidates[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: RadioListTile<int>(
                      title: Text(candidate['name']),
                      value: candidate['id'],
                      groupValue: _selectedCandidateId,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedCandidateId = value;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitVote,
                child: Text('Submit Vote'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}