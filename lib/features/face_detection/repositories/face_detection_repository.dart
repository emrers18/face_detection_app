import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../logic/camera_logic.dart';
import '../logic/ml_kit_logic.dart';
import '../models/face_emotion_model.dart';
import 'dart:typed_data';

class FaceDetectionRepository {
  final CameraLogic cameraLogic;
  final MlKitLogic mlkitlogic;
  bool _isProcessing = false;
  bool _loggedUnsupportedFormat = false;
  bool _loggedUnsupportedRotation = false;

  FaceDetectionRepository({
    required this.cameraLogic, 
    required this.mlkitlogic
  });

  Future<void> startDetection(Function(FaceEmotionModel?) onResult) async {
    await cameraLogic.initializeCamera();

    cameraLogic.startImageStream((CameraImage image) async {
      if (_isProcessing) return;
      _isProcessing = true;
      try {
        // CameraImage -> InputImage
        final inputImage = _convertCameraImageToInputImage(image);
        if (inputImage != null) {
          final result = await mlkitlogic.processImage(inputImage);
          onResult(result);
        } else {
          // Keep UI alive even when this frame cannot be converted.
          onResult(null);
        }
      } catch (e) {
        debugPrint('Error processing image: $e');
        onResult(null);
      } finally {
        _isProcessing = false;
      }
    });
  }

  void stopDetection(){
    cameraLogic.stopImageStream();
  }

  void dispose(){
    cameraLogic.dispose();
    mlkitlogic.dispose();
  }

  InputImage? _convertCameraImageToInputImage(CameraImage image) {
    final controller = cameraLogic.controller;
    if (controller == null || image.planes.isEmpty) return null;

    final sensorOrientation = controller.description.sensorOrientation;
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    if (rotation == null) {
      if (!_loggedUnsupportedRotation) {
        debugPrint('Unsupported sensor orientation: $sensorOrientation');
        _loggedUnsupportedRotation = true;
      }
      return null;
    }

    final rawFormat = image.format.raw;
    final format = InputImageFormatValue.fromRawValue(rawFormat);
    if (format == null) {
      if (!_loggedUnsupportedFormat) {
        debugPrint(
          'Unsupported camera format: $rawFormat | planes=${image.planes.length}',
        );
        _loggedUnsupportedFormat = true;
      }
      return null;
    }

    final allBytes = BytesBuilder(copy: false);
    for (final plane in image.planes) {
      allBytes.add(plane.bytes);
    }

    return InputImage.fromBytes(
      bytes: allBytes.toBytes(),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }
}