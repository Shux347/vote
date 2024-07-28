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

  Future<void> createElection(String electionName, String creatorEmail) async {
    final connection = await getConnection();
    await connection.query(
      'INSERT INTO elections (name, creator_email) VALUES (@name, @creator_email)',
      substitutionValues: {'name': electionName, 'creator_email': creatorEmail},
    );
  }

  Future<void> deleteElection(int electionId) async {
    final connection = await getConnection();

    // Start a transaction
    await connection.transaction((ctx) async {
      // Delete votes associated with the election
      await ctx.query(
        'DELETE FROM votes WHERE election_id = @election_id',
        substitutionValues: {'election_id': electionId},
      );

      // Delete candidates associated with the election
      await ctx.query(
        'DELETE FROM candidates WHERE election_id = @election_id',
        substitutionValues: {'election_id': electionId},
      );

      // Delete assigned elections entries associated with the election
      await ctx.query(
        'DELETE FROM assigned_elections WHERE election_id = @election_id',
        substitutionValues: {'election_id': electionId},
      );

      // Delete the election
      await ctx.query(
        'DELETE FROM elections WHERE id = @id',
        substitutionValues: {'id': electionId},
      );
    });
  }
}