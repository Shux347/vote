import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';

class VotingPage extends StatefulWidget {
  const VotingPage({super.key});

  @override
  VotingPageState createState() => VotingPageState();
}

class VotingPageState extends State<VotingPage> {
  late DbHelper dbHelper;
  List<Election> elections = [];
  Map<String, String> selectedCandidates = {};

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
    _fetchElections();
  }

  Future<void> _fetchElections() async {
    var fetchedElections = await dbHelper.getElections();
    setState(() {
      elections = fetchedElections;
    });
  }

  void _submitVote() async {
    for (var electionId in selectedCandidates.keys) {
      var candidateId = selectedCandidates[electionId]!;
      await dbHelper.recordVote(electionId, candidateId);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vote successfully recorded!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vote for Candidates')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: elections.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: elections.length,
                itemBuilder: (context, index) {
                  var election = elections[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            election.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: election.candidates.map((candidate) {
                              return RadioListTile<String>(
                                title: Text(candidate.name),
                                value: candidate.id,
                                groupValue: selectedCandidates[election.id],
                                onChanged: (value) {
                                  setState(() {
                                    selectedCandidates[election.id] = value!;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitVote,
        child: const Icon(Icons.check),
      ),
    );
  }
}
