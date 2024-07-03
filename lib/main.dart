import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login.dart';
import 'screens/registration_page.dart';
import 'screens/create_election_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/voting_page.dart';

Future<void> main() async {
  // Load .env file from assets folder
  await dotenv.load(fileName: "assets/.env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Vote',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => LoginPage());
        } else if (settings.name == '/register') {
          return MaterialPageRoute(builder: (context) => RegistrationPage());
        } else if (settings.name == '/create_election') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => CreateElectionPage(name: args['name']!, email: args['email']!),
          );
        } else if (settings.name == '/dashboard') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) => DashboardPage(name: args['name']!, email: args['email']!),
          );
        }
        return null;
      },
    );
  }
}
