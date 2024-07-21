import 'package:postgres/postgres.dart';
import 'database.dart';

class DatabaseService {
  final Database _database;

  DatabaseService(this._database);

  Future<PostgreSQLConnection> getConnection() async {
    return await _database.getConnection();
  }

  Future<bool> isEmailUnique(String email) async {
    final connection = await getConnection();
    final List<List<dynamic>> results = await connection.query(
      'SELECT 1 FROM users WHERE email = @email',
      substitutionValues: {'email': email},
    );
    return results.isEmpty;
  }

  Future<void> createUser(String email, String username, String password) async {
    final connection = await getConnection();
    await connection.query(
      'INSERT INTO users (email, username, password) VALUES (@email, @username, @password)',
      substitutionValues: {
        'email': email,
        'username': username,
        'password': password,
      },
    );
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final connection = await getConnection();
    final results = await connection.query(
      'SELECT * FROM users WHERE email = @email AND password = @password',
      substitutionValues: {'email': email, 'password': password},
    );
    if (results.isNotEmpty) {
      return results.first.toColumnMap();
    }
    return null;
  }
}