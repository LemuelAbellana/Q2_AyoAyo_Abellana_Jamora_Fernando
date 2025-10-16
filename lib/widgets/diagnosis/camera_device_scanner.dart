import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ayoayo/services/camera_device_recognition_service.dart';

class CameraDeviceScanner extends StatefulWidget {
  final Function(DeviceRecognitionResult) onDeviceRecognized;
  final Function(String) onError;

  const CameraDeviceScanner({
    super.key,
    required this.onDeviceRecognized,
    required this.onError,
  });

  @override
  State<CameraDeviceScanner> createState() => _CameraDeviceScannerState();
}

class _CameraDeviceScannerState extends State<CameraDeviceScanner>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final CameraDeviceRecognitionService _recognitionService =
      CameraDeviceRecognitionService();

  final List<File> _capturedImages = [];
  bool _isAnalyzing = false;
  DeviceRecognitionResult? _recognitionResult;
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            if (_recognitionResult == null) ...[
              _buildScanningArea(),
              const SizedBox(height: 20),
              _buildActionButtons(),
              if (_capturedImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildImagePreview(),
              ],
            ] else ...[
              _buildRecognitionResult(),
              const SizedBox(height: 20),
              _buildResultActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            LucideIcons.scanLine,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Device Scanner',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Use your camera to identify device model and manufacturer',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanningArea() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isAnalyzing ? _pulseAnimation.value : 1.0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(
                color: _isAnalyzing
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300,
                width: _isAnalyzing ? 3 : 2,
              ),
              borderRadius: BorderRadius.circular(16),
              color: _isAnalyzing
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
                  : Colors.grey.shade50,
            ),
            child: _isAnalyzing
                ? _buildAnalyzingView()
                : _buildScanPrompt(),
          ),
        );
      },
    );
  }

  Widget _buildScanPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          LucideIcons.smartphone,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 12),
        Text(
          'Position device in camera view',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Multiple angles recommended',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
        const SizedBox(height: 16),
        Text(
          'Analyzing device...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'AI is identifying model and manufacturer',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : () => _captureImage(ImageSource.camera),
            icon: const Icon(LucideIcons.camera),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isAnalyzing ? null : () => _captureImage(ImageSource.gallery),
            icon: const Icon(LucideIcons.image),
            label: const Text('Gallery'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (_capturedImages.isNotEmpty) ...[
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _isAnalyzing ? null : _analyzeImages,
            icon: const Icon(LucideIcons.scanLine),
            label: const Text('Analyze'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              LucideIcons.image,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              '${_capturedImages.length} photo${_capturedImages.length == 1 ? '' : 's'} captured',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _clearImages,
              icon: const Icon(LucideIcons.trash2, size: 14),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red[600],
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _capturedImages.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: kIsWeb
                      ? Image.network(
                          _capturedImages[index].path,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          _capturedImages[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecognitionResult() {
    final result = _recognitionResult!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  LucideIcons.check,
                  color: Colors.green.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Identified',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(result.confidence * 100).toStringAsFixed(1)}% confidence',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildResultRow('Model', result.deviceModel),
          _buildResultRow('Manufacturer', result.manufacturer),
          if (result.yearOfRelease != null)
            _buildResultRow('Year', result.yearOfRelease.toString()),
          _buildResultRow('OS', result.operatingSystem),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(LucideIcons.rotateCcw),
            label: const Text('Scan Again'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => widget.onDeviceRecognized(_recognitionResult!),
            icon: const Icon(LucideIcons.check),
            label: const Text('Use Result'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _captureImage(ImageSource source) async {
    try {

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImages.add(File(image.path));
        });
      }
    } catch (e) {
      widget.onError('Failed to capture image: $e');
    }
  }

  Future<void> _analyzeImages() async {
    if (_capturedImages.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _recognitionResult = null;
    });

    _animationController.repeat(reverse: true);

    try {
      final result = _capturedImages.length == 1
          ? await _recognitionService.recognizeDeviceFromImage(_capturedImages.first)
          : await _recognitionService.recognizeDeviceFromImages(_capturedImages);

      setState(() {
        _recognitionResult = result;
      });
    } catch (e) {
      widget.onError('Failed to analyze device: $e');
    } finally {
      setState(() => _isAnalyzing = false);
      _animationController.stop();
      _animationController.reset();
    }
  }

  void _clearImages() {
    setState(() {
      _capturedImages.clear();
    });
  }

  void _reset() {
    setState(() {
      _capturedImages.clear();
      _recognitionResult = null;
      _isAnalyzing = false;
    });
  }
}