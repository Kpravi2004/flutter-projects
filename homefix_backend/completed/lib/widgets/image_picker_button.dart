import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:cross_file/cross_file.dart';
import '../utils/constants.dart'; // <-- changed to constants

class ImagePickerButton extends StatefulWidget {
  final Function(XFile?) onImagePicked;
  final XFile? initialImage;

  const ImagePickerButton({
    super.key,
    required this.onImagePicked,
    this.initialImage,
  });

  @override
  State<ImagePickerButton> createState() => _ImagePickerButtonState();
}

class _ImagePickerButtonState extends State<ImagePickerButton> {
  XFile? _pickedFile;
  Uint8List? _webImageBytes;

  @override
  void initState() {
    super.initState();
    _pickedFile = widget.initialImage;
    if (kIsWeb && _pickedFile != null) {
      _loadBytes();
    }
  }

  Future<void> _loadBytes() async {
    if (_pickedFile != null) {
      final bytes = await _pickedFile!.readAsBytes();
      setState(() {
        _webImageBytes = bytes;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedFile = picked;
        _webImageBytes = null;
      });
      if (kIsWeb) {
        _loadBytes();
      }
      widget.onImagePicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_pickedFile != null)
          kIsWeb
              ? (_webImageBytes != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              _webImageBytes!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          )
              : const SizedBox(
              width: 80,
              height: 80,
              child: Center(child: CircularProgressIndicator(),
              )))
              : ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_pickedFile!.path),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppConstants.lightElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppConstants.tealPrimary.withOpacity(0.3)),
            ),
            child: Icon(Icons.add_a_photo, color: AppConstants.tealPrimary, size: 40),
          ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.camera_alt, color: AppConstants.tealPrimary, size: 16),
          label: Text(
            'Choose Image',
            style: TextStyle(color: AppConstants.tealPrimary),
          ),
          style: TextButton.styleFrom(
            foregroundColor: AppConstants.tealPrimary,
          ),
        ),
      ],
    );
  }
}