import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class ImageUploadPlaceholder extends StatelessWidget {
  final String label;

  const ImageUploadPlaceholder({super.key, required this.label});

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
        onTap: () {
          // TODO: Implement image picker functionality
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image picker for $label not implemented yet'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.camera, size: 32, color: Colors.grey.shade600),
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
}
