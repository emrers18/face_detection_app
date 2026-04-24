import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../logic/camera_logic.dart';
import '../logic/ml_kit_logic.dart';
import '../models/face_emotion_model.dart';

class FaceDetectionRepository {
  final CameraLogic cameraLogic;
  final MlKitLogic mlkitlogic;
  bool _isProcessing = false;

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
        //CameraImage -> InputImage
        final inputImage = _convertCameraImageToInputImage(image);
        if (inputImage != null) {
          final result = await mlkitlogic.processImage(inputImage);
          onResult(result);
        }
      } catch (e) {
        debugPrint('Error processing image: $e');
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

  InputImage? _convertCameraImageToInputImage(CameraImage image){
    final camera = cameraLogic.controller!.description;
    final sensorOrientation = camera.sensorOrientation;

    final InputImageRotation? rotation = InputImageRotation.values.byName(sensorOrientation.toString());
    if (rotation == null) return null;

    final format = InputImageFormat.values.byName(image.format.raw.toString());
    if (format == null || (format != InputImageFormat.nv21 && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.isEmpty) return null;

    return InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }
}