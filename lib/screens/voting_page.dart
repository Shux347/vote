// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data'; // Import this library
import 'dart:convert';
import '../helpers/database.dart';
import '../services/camera_service.dart';
import '../services/facial_recognition_service.dart';
import '../services/image_storage_service.dart';

class VotingPage extends StatefulWidget {
  final int electionId;
  final String userEmail;

  VotingPage({required this.electionId, required this.userEmail});

  @override
  _VotingPageState createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  List<Map<String, dynamic>> _candidates = [];
  int? _selectedCandidateId;
  final CameraService _cameraService = CameraService();
  final FacialRecognitionService _facialRecognitionService = FacialRecognitionService();
  final ImageStorageService _imageStorageService = ImageStorageService();

  @override
  void initState() {
    super.initState();
    _cameraService.initialize();
    _loadCandidates();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  Future<void> _loadCandidates() async {
    try {
      final connection = await Database().getConnection();
      final results = await connection.query(
        'SELECT id, name FROM candidates WHERE election_id = @election_id',
        substitutionValues: {'election_id': widget.electionId},
      );

      setState(() {
        _candidates = results.map((row) => row.toColumnMap()).toList();
      });

      if (_candidates.isEmpty) {
        print('No candidates found for this election.');
      } else {
        print('Candidates: ${_candidates}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading candidates: $e')),
      );
      print('Error loading candidates: $e');
    }
  }

  Future<void> _submitVote() async {
    if (_selectedCandidateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a candidate')),
      );
      return;
    }

    try {
      final imagePath = await _cameraService.takePicture();
      final capturedFaceId = await _facialRecognitionService.detectFaces(imagePath);

      if (capturedFaceId != null) {
        final storedImageBase64 = await _imageStorageService.getImage(1); // Retrieve with user ID
        final storedImageBytes = base64Decode(storedImageBase64);
        final storedImageFile = await _saveToFile(storedImageBytes);

        final storedFaceId = await _facialRecognitionService.detectFaces(storedImageFile.path);

        if (storedFaceId != null) {
          final isMatch = await _facialRecognitionService.compareFaces(capturedFaceId, storedFaceId);

          if (isMatch) {
            final connection = await Database().getConnection();
            await connection.query(
              'INSERT INTO votes (election_id, candidate_id, user_email) VALUES (@election_id, @candidate_id, @user_email)',
              substitutionValues: {
                'election_id': widget.electionId,
                'candidate_id': _selectedCandidateId,
                'user_email': widget.userEmail,
              },
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Vote submitted successfully')),
            );

            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Face verification failed')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stored face not detected')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No face detected, try again')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting vote: $e')),
      );
      print('Error submitting vote: $e');
    }
  }

  Future<File> _saveToFile(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_stored.jpg';
    final file = File(imagePath);
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote in Election'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Select a candidate:', style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: _candidates.length,
                itemBuilder: (context, index) {
                  final candidate = _candidates[index];
                  return RadioListTile<int>(
                    title: Text(candidate['name']),
                    value: candidate['id'],
                    groupValue: _selectedCandidateId,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedCandidateId = value;
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _submitVote,
              child: const Text('Submit Vote'),
            ),
          ],
        ),
      ),
    );
  }
}