import 'package:camera/camera.dart';

class CameraLogic {
  CameraController? controller;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );
    await controller!.initialize();
  }

  void startImageStream(Function(CameraImage) onImageAvailable){
    if(controller != null && !controller!.value.isStreamingImages){
      controller!.startImageStream(onImageAvailable);
    }
  }

  void stopImageStream(){
    if(controller != null && controller!.value.isStreamingImages){
      controller!.stopImageStream();
    }
  }
  void dispose(){
    stopImageStream();
    controller?.dispose();
  }
}