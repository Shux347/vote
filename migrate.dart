import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv package for environment variables

Future<void> main() async {
  // Load environment variables from the .env file in the assets directory
  await dotenv.load(fileName: 'assets/.env');

  // Retrieve the DATABASE_URL environment variable
  final databaseUrl = dotenv.env['DATABASE_URL'];
  if (databaseUrl == null) {
    throw Exception('DATABASE_URL environment variable not set');
  }

  // Parse the DATABASE_URL
  final uri = Uri.parse(databaseUrl);
  final connection = PostgreSQLConnection(
    uri.host,
    uri.port,
    uri.pathSegments[0],
    username: uri.userInfo.split(':')[0],
    password: uri.userInfo.split(':')[1],
    useSSL: true,
  );

  // Open the connection
  await connection.open();

  // SQL command to create the users table
  const createUsersTable = '''
  CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );
  ''';

  // Execute the SQL command
  await connection.execute(createUsersTable);

  // Close the connection
  await connection.close();

  print('Migration completed successfully.');
}
