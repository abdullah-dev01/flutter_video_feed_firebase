import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Upload video to Firebase Storage
  /// Returns the download URL of the uploaded video
  Future<String> uploadVideo(
    File videoFile, {
    Function(double)? onProgress,
  }) async {
    try {
      // Generate unique filename
      final String fileName = 'videos/${_uuid.v4()}.mp4';
      final Reference storageRef = _storage.ref().child(fileName);

      // Create upload task
      final UploadTask uploadTask = storageRef.putFile(videoFile);

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }

  /// Delete video from Firebase Storage
  Future<void> deleteVideo(String videoUrl) async {
    try {
      final Reference storageRef = _storage.refFromURL(videoUrl);
      await storageRef.delete();
    } catch (e) {
      throw Exception('Failed to delete video: $e');
    }
  }
}
