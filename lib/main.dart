import 'package:flutter/material.dart';
import 'helpers/database.dart';
import 'screens/registration_page.dart';
import 'screens/login.dart';
import 'screens/create_election_page.dart';
import 'screens/voting_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var db = Database();
  await db.getConnection();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voting App',
      initialRoute: '/',
      routes: {
        '/': (context) => RegistrationPage(),
        '/login': (context) => LoginPage(),
        '/create_election': (context) => CreateElectionPage(),
        '/select_election': (context) => VotingPage(),
      },
    );
  }
}
