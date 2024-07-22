import 'package:postgres/postgres.dart';
import 'database.dart';

class VotingService {
  final Database _database;

  VotingService(this._database);

  Future<List<Map<String, dynamic>>> getCandidates(int electionId) async {
    final connection = await _database.getConnection();
    final results = await connection.query(
      'SELECT id, name FROM candidates WHERE election_id = @election_id',
      substitutionValues: {'election_id': electionId},
    );
    return results.map((row) => row.toColumnMap()).toList();
  }

  Future<void> submitVote(int electionId, int candidateId, String userEmail) async {
    final connection = await _database.getConnection();
    await connection.query(
      'INSERT INTO votes (election_id, candidate_id, user_email) VALUES (@election_id, @candidate_id, @user_email)',
      substitutionValues: {
        'election_id': electionId,
        'candidate_id': candidateId,
        'user_email': userEmail,
      },
    );
  }
}