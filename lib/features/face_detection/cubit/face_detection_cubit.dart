import 'package:face_detection_app/features/face_detection/cubit/face_detection_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/face_detection_repository.dart';

class FaceDetectionCubit extends Cubit<FaceDetectionState>{
  final FaceDetectionRepository _repository;

  FaceDetectionCubit(this._repository) : super(FaceDetectionInitial());

  Future<void> initDetection() async {
    emit(FaceDetectionLoading());
    try{
      //Repo üzerinden kamera ve ML başlat
      await _repository.startDetection((faceEmotion) {
        if(_repository.cameraLogic.controller != null){
          emit(FaceDetectionStreaming(
            cameraController: _repository.cameraLogic.controller!,
            faceEmotion: faceEmotion,
          ));
        }
      });
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