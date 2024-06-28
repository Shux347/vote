import 'dart:io'; // Add this import
import 'package:postgres/postgres.dart';

class Database {
  static final Database _instance = Database._internal();
  late PostgreSQLConnection connection;

  factory Database() {
    return _instance;
  }

  Database._internal() {
    _initializeConnection();
  }

  Future<void> _initializeConnection() async {
    final uri = Uri.parse(Platform.environment['DATABASE_URL']!); // Ensure 'dart:io' is imported
    connection = PostgreSQLConnection(
      uri.host,
      uri.port,
      uri.pathSegments[1],
      username: uri.userInfo.split(':')[0],
      password: uri.userInfo.split(':')[1],
      useSSL: true,
    );
    await connection.open();
  }

  Future<PostgreSQLConnection> getConnection() async {
    if (connection.isClosed) {
      await connection.open();
    }
    return connection;
  }
}
