import 'package:flutter/material.dart';
import '../helpers/database.dart';

class ViewElectionResultsPage extends StatefulWidget {
  final int electionId;
  final String electionName;

  ViewElectionResultsPage({required this.electionId, required this.electionName});

  @override
  _ViewElectionResultsPageState createState() => _ViewElectionResultsPageState();
}

class _ViewElectionResultsPageState extends State<ViewElectionResultsPage> {
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      final connection = await Database().getConnection();
      final results = await connection.query(
        'SELECT c.name, COUNT(v.id) as vote_count '
        'FROM candidates c LEFT JOIN votes v ON c.id = v.candidate_id '
        'WHERE c.election_id = @election_id '
        'GROUP BY c.id '
        'ORDER BY vote_count DESC',
        substitutionValues: {'election_id': widget.electionId},
      );

      setState(() {
        _results = results.map((row) => row.toColumnMap()).toList();
      });

      if (_results.isEmpty) {
        print('No votes found for this election.');
      } else {
        print('Election results: ${_results}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading results: $e')),
      );
      print('Error loading results: $e');
    }
  }

  Future<void> _closeElection() async {
    try {
      final connection = await Database().getConnection();
      await connection.query(
        'UPDATE elections SET end_time = NOW() WHERE id = @election_id',
        substitutionValues: {'election_id': widget.electionId},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Election closed successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error closing election: $e')),
      );
      print('Error closing election: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for ${widget.electionName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _results.isEmpty
            ? Center(child: Text('No results available'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Results:', style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        return ListTile(
                          title: Text(result['name']),
                          trailing: Text(result['vote_count'].toString()),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _closeElection,
                    child: Text('Close Election'),
                  ),
                ],
              ),
      ),
    );
  }
}
