import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save video metadata to Firestore
  Future<void> saveVideoMetadata({
    required String videoUrl,
    required String caption,
    required String userId,
  }) async {
    try {
      await _firestore.collection('videos').add({
        'videoUrl': videoUrl,
        'caption': caption,
        'userId': userId,
        'userEmail': _auth.currentUser?.email,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'views': 0,
      });
    } catch (e) {
      throw Exception('Failed to save video metadata: $e');
    }
  }

  /// Get all videos from Firestore
  Stream<QuerySnapshot> getVideos() {
    return _firestore
        .collection('videos')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get videos by user ID
  Stream<QuerySnapshot> getUserVideos(String userId) {
    return _firestore
        .collection('videos')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Delete video from Firestore
  Future<void> deleteVideo(String videoId) async {
    try {
      await _firestore.collection('videos').doc(videoId).delete();
    } catch (e) {
      throw Exception('Failed to delete video: $e');
    }
  }

  /// Update video likes
  Future<void> updateVideoLikes(String videoId, int likes) async {
    try {
      await _firestore.collection('videos').doc(videoId).update({
        'likes': likes,
      });
    } catch (e) {
      throw Exception('Failed to update video likes: $e');
    }
  }
}
