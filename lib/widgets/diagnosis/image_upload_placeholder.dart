import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadPlaceholder extends StatefulWidget {
  final String label;
  final Function(List<File>) onImagesSelected;

  const ImageUploadPlaceholder({
    super.key,
    required this.label,
    required this.onImagesSelected,
  });

  @override
  State<ImageUploadPlaceholder> createState() => _ImageUploadPlaceholderState();
}

class _ImageUploadPlaceholderState extends State<ImageUploadPlaceholder> {
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: _selectedImages.isEmpty ? 180 : 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedImages.isEmpty
                  ? Colors.grey.shade300
                  : Colors.green.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
            color: _selectedImages.isEmpty
                ? Colors.grey.shade50
                : Colors.green.shade50,
          ),
          child: InkWell(
            onTap: () => _pickImage(context),
            borderRadius: BorderRadius.circular(16),
            child: _selectedImages.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.camera,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Camera • Gallery',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Multiple photos recommended',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      // Header with count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.check,
                              color: Colors.green.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedImages.length} photo${_selectedImages.length == 1 ? '' : 's'} selected',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => _pickImage(context),
                              icon: Icon(
                                LucideIcons.plus,
                                size: 16,
                                color: Theme.of(context).primaryColor,
                              ),
                              label: Text(
                                'Add More',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Images list
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(12),
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            final imageFile = _selectedImages[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: kIsWeb
                                        ? Image.network(
                                            imageFile.path,
                                            width: 140,
                                            height: 140,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    width: 140,
                                                    height: 140,
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.error,
                                                    ),
                                                  );
                                                },
                                          )
                                        : Image.file(
                                            imageFile,
                                            width: 140,
                                            height: 140,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade700,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        // Tips section when images are selected
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.info, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tip: Include photos of the front, back, and any damage for the best diagnosis.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImageSource? source = await showDialog<ImageSource>(
      // ignore: unnecessary_nullable_for_final_variable_declarations
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source for ${widget.label}'),
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

    if (!context.mounted) return; // Added check

    if (source != null) {
      try {
        final List<XFile> pickedFiles = await _picker.pickMultiImage(
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (pickedFiles.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(
              pickedFiles.map((xFile) => File(xFile.path)).toList(),
            );
          });
          widget.onImagesSelected(_selectedImages);
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

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    widget.onImagesSelected(_selectedImages);
  }
}
