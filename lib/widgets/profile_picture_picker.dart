import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';  // Import for platform checks

class ProfilePicturePicker extends StatefulWidget {
  final Function(File) onPickImage;

  const ProfilePicturePicker({Key? key, required this.onPickImage}) : super(key: key);

  @override
  _ProfilePicturePickerState createState() => _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends State<ProfilePicturePicker> {
  File? _profileImage;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    // Choose from gallery or take a new photo
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      widget.onPickImage(_profileImage!);  // Pass the selected image to parent widget
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,  // When tapped, it allows the user to pick a new image
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        child: _profileImage == null
            ? ClipOval(
                child: Image.asset(
                  'assets/images/default_avatar.JPG',  // Default avatar from assets
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,  // Ensures image fits the circle
                ),
              )
            : ClipOval(
                child: Image.file(
                  _profileImage!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,  // Ensures image fits the circle
                ),
              ),
      ),
    );
  }
}
