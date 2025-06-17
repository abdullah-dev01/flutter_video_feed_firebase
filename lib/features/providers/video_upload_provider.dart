import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/storage_service.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VideoUploadProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();

  File? _selectedVideo;
  String _caption = '';
  double _uploadProgress = 0.0;
  bool _isUploading = false;
  String? _errorMessage;

  // Getters
  File? get selectedVideo => _selectedVideo;
  String get caption => _caption;
  double get uploadProgress => _uploadProgress;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  /// Pick video from gallery
  Future<void> pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10), // 10 minutes max
      );

      if (video != null) {
        _selectedVideo = File(video.path);
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to pick video: $e';
      notifyListeners();
    }
  }

  /// Pick video from camera
  Future<void> recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10), // 10 minutes max
      );

      if (video != null) {
        _selectedVideo = File(video.path);
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to record video: $e';
      notifyListeners();
    }
  }

  /// Update caption
  void updateCaption(String caption) {
    _caption = caption;
    notifyListeners();
  }

  /// Upload video with caption
  Future<bool> uploadVideo() async {
    if (_selectedVideo == null) {
      _errorMessage = 'Please select a video first';
      notifyListeners();
      return false;
    }

    if (_caption.trim().isEmpty) {
      _errorMessage = 'Please add a caption';
      notifyListeners();
      return false;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      _errorMessage = null;
      notifyListeners();

      // Upload video to Firebase Storage
      final String videoUrl = await _storageService.uploadVideo(
        _selectedVideo!,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );

      // Save metadata to Firestore
      await _firestoreService.saveVideoMetadata(
        videoUrl: videoUrl,
        caption: _caption.trim(),
        userId: user.uid,
      );

      // Reset state
      _selectedVideo = null;
      _caption = '';
      _uploadProgress = 0.0;
      _isUploading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Upload failed: $e';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear selected video
  void clearVideo() {
    _selectedVideo = null;
    _caption = '';
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
