import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '/providers/diagnosis_provider.dart';

class ImageUploadPlaceholder extends StatelessWidget {
  final String label;
  final File? selectedImage;
  final Uint8List? imageBytes; // For web compatibility
  final VoidCallback? onImageSelected;

  const ImageUploadPlaceholder({
    super.key,
    required this.label,
    this.selectedImage,
    this.imageBytes,
    this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: InkWell(
        onTap: () => _pickImage(context),
        borderRadius: BorderRadius.circular(12),
        child: (selectedImage != null || imageBytes != null)
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb && imageBytes != null
                        ? Image.memory(
                            imageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : selectedImage != null
                        ? Image.file(
                            selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        onPressed: () => _removeImage(context),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.camera,
                    size: 32,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to upload',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    // Show dialog to choose between camera and gallery
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source for $label'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      try {
        final XFile? pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          if (context.mounted) {
            final diagnosisProvider = Provider.of<DiagnosisProvider>(
              context,
              listen: false,
            );

            if (kIsWeb) {
              // For web, read as bytes
              final bytes = await pickedFile.readAsBytes();
              final File dummyFile = File(
                pickedFile.path,
              ); // Keep for compatibility
              diagnosisProvider.addImage(dummyFile, bytes);
            } else {
              // For mobile, use file directly
              final File imageFile = File(pickedFile.path);
              diagnosisProvider.addImage(imageFile);
            }

            if (onImageSelected != null) {
              onImageSelected!();
            }
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
        }
      }
    }
  }

  void _removeImage(BuildContext context) {
    final diagnosisProvider = Provider.of<DiagnosisProvider>(
      context,
      listen: false,
    );
    final images = diagnosisProvider.selectedImages;

    // Find the index of this image and remove it
    if (selectedImage != null) {
      final index = images.indexWhere((img) => img.path == selectedImage!.path);
      if (index != -1) {
        diagnosisProvider.removeImage(index);
      }
    }
  }
}
