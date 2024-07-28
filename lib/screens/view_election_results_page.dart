// ignore_for_file: unnecessary_brace_in_string_interps, use_build_context_synchronously, prefer_const_constructors, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
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
  int _totalVoters = 0;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      final connection = await Database().getConnection();

      // Fetch total number of voters
      final totalVotersResult = await connection.query(
        'SELECT COUNT(*) as total_voters FROM assigned_elections WHERE election_id = @election_id',
        substitutionValues: {'election_id': widget.electionId},
      );
      _totalVoters = totalVotersResult.first[0];

      // Fetch election results
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

  List<charts.Series<Map<String, dynamic>, String>> _createChartData() {
    final List<Map<String, dynamic>> data = List.from(_results);
    final int totalVotes = _results.fold(0, (sum, item) => sum + (item['vote_count'] as int));
    final int notVotedCount = _totalVoters - totalVotes;

    data.add({'name': 'Not Voted', 'vote_count': notVotedCount});

    return [
      charts.Series<Map<String, dynamic>, String>(
        id: 'Votes',
        domainFn: (Map<String, dynamic> item, _) => item['name'],
        measureFn: (Map<String, dynamic> item, _) => item['vote_count'] as int,
        data: data,
        labelAccessorFn: (Map<String, dynamic> item, _) => '${item['vote_count']}',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for ${widget.electionName}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _results.isEmpty
            ? Center(child: Text('No results available'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Results:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Total Voters: $_totalVoters',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: charts.BarChart(
                      _createChartData(),
                      vertical: false,
                      barRendererDecorator: charts.BarLabelDecorator<String>(),
                      domainAxis: charts.OrdinalAxisSpec(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _closeElection,
                      child: Text('Close Election'),
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