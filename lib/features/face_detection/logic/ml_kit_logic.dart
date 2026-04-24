import 'package:face_detection_app/features/face_detection/models/face_emotion_model.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class MlKitLogic {
  late final FaceDetector _faceDetector;

  MlKitLogic(){
    final options = FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.fast, //hızlı tepki

    );

    _faceDetector = FaceDetector(options: options);
  }

  Future<FaceEmotionModel?> processImage(InputImage inputImage) async {

    // görüntüyü modele verme
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isNotEmpty){
      final face = faces.first;
      return FaceEmotionModel(smilingProbability: face.smilingProbability);
    }
    return null;
  }

  void dispose() {
    _faceDetector.close();
  }
  
}