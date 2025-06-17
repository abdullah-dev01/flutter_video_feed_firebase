// create auth textfield widget

// for this
// AuthTextField(
//               controller: _captionController,
//               hintText: 'Add a caption to your video...',
//               maxLines: 3,
//               enabled: !videoProvider.isUploading,
//               onChanged: videoProvider.updateCaption,
//             ),

import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final bool enabled;
  final Function(String) onChanged;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.maxLines,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
