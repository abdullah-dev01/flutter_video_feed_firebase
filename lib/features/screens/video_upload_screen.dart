import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/video_upload_provider.dart';
import '../providers/video_provider.dart';
import '../widgets/auth_text_field.dart';
import '../../core/responsive_helper.dart';

class VideoUploadScreen extends StatefulWidget {
  const VideoUploadScreen({super.key});

  @override
  State<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  VideoPlayerController? _videoController;
  final TextEditingController _captionController = TextEditingController();
  bool _isPlaying = false;

  @override
  void dispose() {
    _videoController?.dispose();
    _captionController.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer(File videoFile) {
    _videoController?.dispose();
    _isPlaying = false;
    _videoController = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  void _togglePlayPause() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      setState(() {
        if (_videoController!.value.isPlaying) {
          _videoController!.pause();
          _isPlaying = false;
        } else {
          _videoController!.play();
          _isPlaying = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Upload Video',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ResponsiveHelper.getResponsiveContainer(
        context: context,
        child: Consumer<VideoUploadProvider>(
          builder: (context, videoProvider, child) {
            return ResponsiveHelper.getResponsiveLayout(
              context: context,
              mobile: _buildMobileLayout(videoProvider),
              tablet: _buildTabletLayout(videoProvider),
              desktop: _buildDesktopLayout(videoProvider),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout(VideoUploadProvider videoProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildVideoSelectionSection(videoProvider),
          const SizedBox(height: 24),
          if (videoProvider.selectedVideo != null) ...[
            _buildVideoPreviewSection(videoProvider),
            const SizedBox(height: 24),
          ],
          _buildCaptionSection(videoProvider),
          const SizedBox(height: 24),
          if (videoProvider.isUploading) ...[
            _buildUploadProgressSection(videoProvider),
            const SizedBox(height: 24),
          ],
          if (videoProvider.errorMessage != null) ...[
            _buildErrorSection(videoProvider),
            const SizedBox(height: 24),
          ],
          _buildUploadButton(videoProvider),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(VideoUploadProvider videoProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildVideoSelectionSection(videoProvider),
                const SizedBox(height: 24),
                _buildCaptionSection(videoProvider),
                const SizedBox(height: 24),
                if (videoProvider.isUploading) ...[
                  _buildUploadProgressSection(videoProvider),
                  const SizedBox(height: 24),
                ],
                if (videoProvider.errorMessage != null) ...[
                  _buildErrorSection(videoProvider),
                  const SizedBox(height: 24),
                ],
                _buildUploadButton(videoProvider),
              ],
            ),
          ),
        ),
        if (videoProvider.selectedVideo != null)
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildVideoPreviewSection(videoProvider),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopLayout(VideoUploadProvider videoProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildVideoSelectionSection(videoProvider),
                const SizedBox(height: 32),
                _buildCaptionSection(videoProvider),
                const SizedBox(height: 32),
                if (videoProvider.isUploading) ...[
                  _buildUploadProgressSection(videoProvider),
                  const SizedBox(height: 32),
                ],
                if (videoProvider.errorMessage != null) ...[
                  _buildErrorSection(videoProvider),
                  const SizedBox(height: 32),
                ],
                _buildUploadButton(videoProvider),
              ],
            ),
          ),
        ),
        if (videoProvider.selectedVideo != null)
          Expanded(
            flex: 1,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(32.0),
              child: _buildVideoPreviewSection(videoProvider),
            ),
          ),
      ],
    );
  }

  Widget _buildVideoSelectionSection(VideoUploadProvider videoProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Video',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: videoProvider.isUploading
                        ? null
                        : () async {
                            await videoProvider.pickVideo();
                            if (videoProvider.selectedVideo != null) {
                              _initializeVideoPlayer(
                                videoProvider.selectedVideo!,
                              );
                            }
                          },
                    icon: const Icon(Icons.video_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveHelper.isWeb(context) ? 16 : 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: videoProvider.isUploading
                        ? null
                        : () async {
                            await videoProvider.recordVideo();
                            if (videoProvider.selectedVideo != null) {
                              _initializeVideoPlayer(
                                videoProvider.selectedVideo!,
                              );
                            }
                          },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: ResponsiveHelper.isWeb(context) ? 16 : 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreviewSection(VideoUploadProvider videoProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Video Preview',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      18,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: videoProvider.isUploading
                      ? null
                      : () {
                          videoProvider.clearVideo();
                          _videoController?.dispose();
                          _videoController = null;
                          _isPlaying = false;
                          _captionController.clear();
                        },
                  icon: const Icon(Icons.close),
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_videoController != null &&
                _videoController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_videoController!),
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          size: ResponsiveHelper.getResponsiveIconSize(
                            context,
                            32,
                          ),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptionSection(VideoUploadProvider videoProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Video Caption',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              maxLines: ResponsiveHelper.isWeb(context) ? 4 : 3,
              decoration: InputDecoration(
                hintText: 'Enter a caption for your video...',
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: ResponsiveHelper.isWeb(context) ? 16 : 12,
                ),
              ),
              onChanged: (value) {
                videoProvider.updateCaption(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProgressSection(VideoUploadProvider videoProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Progress',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: videoProvider.uploadProgress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(videoProvider.uploadProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(VideoUploadProvider videoProvider) {
    return Card(
      elevation: 4,
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red,
                  size: ResponsiveHelper.getResponsiveIconSize(context, 24),
                ),
                const SizedBox(width: 8),
                Text(
                  'Upload Error',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      18,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              videoProvider.errorMessage!,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                color: Colors.red[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton(VideoUploadProvider videoProvider) {
    return ElevatedButton(
      onPressed:
          videoProvider.selectedVideo == null || videoProvider.isUploading
          ? null
          : () async {
              final success = await videoProvider.uploadVideo();
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Video uploaded successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                // Refresh the video list on the home screen
                Provider.of<VideoProvider>(
                  context,
                  listen: false,
                ).fetchVideos();
                Navigator.pop(context);
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveHelper.isWeb(context) ? 20 : 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: videoProvider.isUploading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Uploading...',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      16,
                    ),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          : Text(
              'Upload Video',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
