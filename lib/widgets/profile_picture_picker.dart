import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
      child: Material(
        color: Colors.transparent,  // Transparent background
        elevation: 5,  // Subtle shadow effect
        shape: CircleBorder(),
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[300],  // Default background color
          child: _profileImage == null
              ? Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 30,
                )
              : ClipOval(
                  child: Image.file(
                    _profileImage!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }
}
