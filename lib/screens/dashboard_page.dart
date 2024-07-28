// ignore_for_file: unnecessary_brace_in_string_interps, use_build_context_synchronously, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import '../helpers/database_service.dart';
import '../helpers/database.dart';
import 'create_election_page.dart';
import 'login.dart';
import 'voting_page.dart';
import 'view_election_results_page.dart';

class DashboardPage extends StatefulWidget {
  final String name;
  final String email;

  DashboardPage({required this.name, required this.email});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DatabaseService _databaseService;

  List<Map<String, dynamic>> _assignedElections = [];
  List<Map<String, dynamic>> _yourElections = [];

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService(Database());
    _loadAssignedElections();
    _loadYourElections();
  }

  Future<void> _loadAssignedElections() async {
    try {
      final connection = await _databaseService.getConnection();
      print('Fetching assigned elections for email: ${widget.email}');

      final results = await connection.query(
        'SELECT e.id, e.name FROM elections e '
        'JOIN assigned_elections ae ON e.id = ae.election_id '
        'LEFT JOIN votes v ON e.id = v.election_id AND v.user_email = @user_email '
        'WHERE ae.user_email = @user_email AND v.id IS NULL',
        substitutionValues: {'user_email': widget.email},
      );

      print('Fetched elections: ${results.length}');

      setState(() {
        _assignedElections = results.map((row) => row.toColumnMap()).toList();
      });

      if (_assignedElections.isEmpty) {
        print('No assigned elections found.');
      } else {
        print('Assigned elections: ${_assignedElections}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading elections: $e')),
      );
      print('Error loading elections: $e');
    }
  }

  Future<void> _loadYourElections() async {
    try {
      final connection = await _databaseService.getConnection();
      print('Fetching your elections for email: ${widget.email}');

      final results = await connection.query(
        'SELECT id, name FROM elections WHERE creator_email = @creator_email',
        substitutionValues: {'creator_email': widget.email},
      );

      print('Fetched your elections: ${results.length}');

      setState(() {
        _yourElections = results.map((row) => row.toColumnMap()).toList();
      });

      if (_yourElections.isEmpty) {
        print('No elections found.');
      } else {
        print('Your elections: ${_yourElections}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading your elections: $e')),
      );
      print('Error loading your elections: $e');
    }
  }

  Future<void> _closeElection(int electionId) async {
    try {
      await _databaseService.deleteElection(electionId);
      setState(() {
        _yourElections.removeWhere((election) => election['id'] == electionId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Election closed and removed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error closing election: $e')),
      );
    }
  }

  void _signOut() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome, ${widget.name}!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateElectionPage(name: widget.name, email: widget.email),
                    ),
                  );
                },
                child: Text('Create Election'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Your Assigned Elections:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _assignedElections.isEmpty
                  ? Center(child: Text('No assigned elections', style: TextStyle(fontSize: 16)))
                  : ListView.builder(
                      itemCount: _assignedElections.length,
                      itemBuilder: (context, index) {
                        final election = _assignedElections[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(election['name']),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VotingPage(
                                    electionId: election['id'],
                                    userEmail: widget.email,
                                  ),
                                ),
                              ).then((_) => _loadAssignedElections());
                            },
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            Text(
              'Your Elections:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _yourElections.isEmpty
                  ? Center(child: Text('No elections created', style: TextStyle(fontSize: 16)))
                  : ListView.builder(
                      itemCount: _yourElections.length,
                      itemBuilder: (context, index) {
                        final election = _yourElections[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(election['name']),
                            trailing: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => _closeElection(election['id']),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewElectionResultsPage(
                                    electionId: election['id'],
                                    electionName: election['name'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}