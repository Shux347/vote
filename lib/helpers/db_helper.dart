import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';

class DbHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "vote.db");
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE User(
        userName TEXT,
        userEmail TEXT PRIMARY KEY,
        userPassword TEXT,
        faceImagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Election(
        id TEXT PRIMARY KEY,
        name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Candidate(
        id TEXT PRIMARY KEY,
        name TEXT,
        electionId TEXT,
        FOREIGN KEY (electionId) REFERENCES Election (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE Vote(
        electionId TEXT,
        candidateId TEXT,
        FOREIGN KEY (electionId) REFERENCES Election (id),
        FOREIGN KEY (candidateId) REFERENCES Candidate (id)
      )
    ''');
  }

  Future<List<Election>> getElections() async {
    var dbClient = await db;
    var res = await dbClient.query("Election");

    List<Election> elections = [];
    for (var electionMap in res) {
      var electionId = electionMap['id'] as String;
      var candidatesRes = await dbClient
          .query("Candidate", where: "electionId = ?", whereArgs: [electionId]);
      List<Candidate> candidates = candidatesRes.map((candidateMap) {
        return Candidate(
          id: candidateMap['id'] as String,
          name: candidateMap['name'] as String,
        );
      }).toList();

      elections.add(Election(
        id: electionId,
        name: electionMap['name'] as String,
        candidates: candidates,
      ));
    }

    return elections;
  }

  Future<void> recordVote(String electionId, String candidateId) async {
    var dbClient = await db;
    await dbClient.insert("Vote", {
      'electionId': electionId,
      'candidateId': candidateId,
    });
  }

  Future<int> saveData(UserModel user) async {
    var dbClient = await db;
    return await dbClient.insert('User', user.toMap());
  }

  Future<UserModel?> getLoginUser(String email, String password) async {
    var dbClient = await db;
    var res = await dbClient.rawQuery(
        "SELECT * FROM User WHERE userEmail = ? AND userPassword = ?", [email, password]);

    if (res.isNotEmpty) {
      return UserModel(
        res.first['userName'] as String,
        res.first['userEmail'] as String,
        res.first['userPassword'] as String,
        faceImagePath: res.first['faceImagePath'] as String,
      );
    }

    return null;
  }
}

class Election {
  final String id;
  final String name;
  final List<Candidate> candidates;

  Election({required this.id, required this.name, required this.candidates});
}

class Candidate {
  final String id;
  final String name;

  Candidate({required this.id, required this.name});
}
