import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:postgres/postgres.dart';

class Database {
  static final Database _instance = Database._internal();
  late PostgreSQLConnection _connection;
  bool _isInitialized = false;

  factory Database() {
    return _instance;
  }

  Database._internal();

  Future<void> _initializeConnection() async {
    final dbUrl = dotenv.env['DATABASE_URL'];
    if (dbUrl == null) {
      throw Exception('DATABASE_URL environment variable not set');
    }

    print('DATABASE_URL: $dbUrl');

    final uri = Uri.parse(dbUrl);
    final username = uri.userInfo.split(':')[0];
    final password = uri.userInfo.split(':')[1];
    final host = uri.host;
    final port = uri.port;
    final databaseName = uri.pathSegments.first;

    print('Initializing connection to $host:$port/$databaseName with user $username');

    _connection = PostgreSQLConnection(
      host,
      port,
      databaseName,
      username: username,
      password: password,
      useSSL: true,
    );

    await _connection.open();
    _isInitialized = true;
    print('Database connection opened successfully');
  }

  Future<PostgreSQLConnection> getConnection() async {
    if (!_isInitialized) {
      print('Connection is not initialized, initializing...');
      await _initializeConnection();
    }
    return _connection;
  }
}
