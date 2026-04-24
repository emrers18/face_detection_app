import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:face_detection_app/features/face_detection/models/face_emotion_model.dart';

abstract class FaceDetectionState extends Equatable{
  @override
  List<Object?> get props => [];
}

class FaceDetectionInitial extends FaceDetectionState{}

class FaceDetectionLoading extends FaceDetectionState{}

class FaceDetectionStreaming extends FaceDetectionState{

  final CameraController cameraController;
  final FaceEmotionModel? faceEmotion;

  FaceDetectionStreaming({required this.cameraController, this.faceEmotion});

  @override
  List<Object?> get props => [cameraController, faceEmotion?.smilingProbability];

}

class FaceDetectionError extends FaceDetectionState{
  final String message;

  FaceDetectionError({required this.message});

  @override
  List<Object?> get props => [message];
}
