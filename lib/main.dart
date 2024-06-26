import 'package:flutter/material.dart';
import 'screens/create_election_page.dart';
import 'screens/login.dart';
import 'screens/registration_page.dart';
import 'screens/voting_page.dart';
import 'screens/login_success_screen.dart';  

void main() => runApp(const SecureVoteApp());

class SecureVoteApp extends StatelessWidget {
  const SecureVoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Vote',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/createElection': (context) => const CreateElectionPage(),
        '/voting': (context) => const VotingPage(),
        '/home': (context) => const LoginSuccessScreen(name: ''), 
      },
    );
  }
}
