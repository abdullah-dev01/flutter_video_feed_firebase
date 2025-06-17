import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class VideoPost {
  final String id;
  final String videoUrl;
  final String caption;
  final String username;
  final String userAvatar;
  final int likes;
  final bool isLiked;
  final bool isSaved;
  final DateTime createdAt;

  VideoPost({
    required this.id,
    required this.videoUrl,
    required this.caption,
    required this.username,
    required this.userAvatar,
    required this.likes,
    this.isLiked = false,
    this.isSaved = false,
    required this.createdAt,
  });

  factory VideoPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VideoPost(
      id: doc.id,
      videoUrl: data['videoUrl'] ?? '',
      caption: data['caption'] ?? '',
      username: data['userEmail']?.toString().split('@')[0] ?? 'User',
      userAvatar: 'https://via.placeholder.com/50',
      likes: data['likes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

class VideoProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<VideoPost> _videos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<VideoPost> get videos => _videos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all videos from Firestore
  Future<void> fetchVideos() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _firestoreService.getVideos().listen((snapshot) {
        _videos = snapshot.docs
            .map((doc) => VideoPost.fromFirestore(doc))
            .toList();
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Failed to fetch videos: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle like for a video
  Future<void> toggleLike(String videoId) async {
    try {
      final videoIndex = _videos.indexWhere((video) => video.id == videoId);
      if (videoIndex != -1) {
        final video = _videos[videoIndex];
        final newLikes = video.isLiked ? video.likes - 1 : video.likes + 1;

        // Update local state
        _videos[videoIndex] = VideoPost(
          id: video.id,
          videoUrl: video.videoUrl,
          caption: video.caption,
          username: video.username,
          userAvatar: video.userAvatar,
          likes: newLikes,
          isLiked: !video.isLiked,
          isSaved: video.isSaved,
          createdAt: video.createdAt,
        );

        // Update Firestore
        await _firestoreService.updateVideoLikes(videoId, newLikes);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update like: $e';
      notifyListeners();
    }
  }

  /// Toggle save for a video
  void toggleSave(String videoId) {
    final videoIndex = _videos.indexWhere((video) => video.id == videoId);
    if (videoIndex != -1) {
      final video = _videos[videoIndex];
      _videos[videoIndex] = VideoPost(
        id: video.id,
        videoUrl: video.videoUrl,
        caption: video.caption,
        username: video.username,
        userAvatar: video.userAvatar,
        likes: video.likes,
        isLiked: video.isLiked,
        isSaved: !video.isSaved,
        createdAt: video.createdAt,
      );
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
