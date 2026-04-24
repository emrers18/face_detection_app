import 'package:face_detection_app/features/face_detection/cubit/face_detection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/face_detection_repository.dart';

class FaceDetectionCubit extends Cubit<FaceDetectionState>{
  final FaceDetectionRepository _repository;

  FaceDetectionCubit(this._repository) : super(FaceDetectionInitial());

  Future<void> initDetection() async {
  emit(FaceDetectionLoading());
  try {
    await _repository.startDetection((faceEmotion) {
      final controller = _repository.cameraLogic.controller;
      if (controller != null) {
        emit(FaceDetectionStreaming(
          cameraController: controller,
          faceEmotion: faceEmotion,
        ));
      }
    });
    final controller = _repository.cameraLogic.controller;
    if (controller != null && controller.value.isInitialized) {
      emit(FaceDetectionStreaming(
        cameraController: controller,
        faceEmotion: null,
      ));
    }
  } catch (e) {
    emit(FaceDetectionError(message: "Başlatma hatası: ${e.toString()}"));
  }
}

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}