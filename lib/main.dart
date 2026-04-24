import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/face_detection/cubit/face_detection_cubit.dart';
import 'features/face_detection/logic/camera_logic.dart';
import 'features/face_detection/logic/ml_kit_logic.dart';
import 'features/face_detection/repositories/face_detection_repository.dart';
import 'features/face_detection/views/face_detection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Logic katmanları
  final cameraLogic = CameraLogic();
  final mlKitLogic = MlKitLogic();

  // Repository
  final repository = FaceDetectionRepository(
    cameraLogic: cameraLogic,
    mlkitlogic: mlKitLogic,
  );

  runApp(
    MaterialApp(
      home: BlocProvider(
        create: (context) => FaceDetectionCubit(repository),
        child: const FaceDetectionPage(),
      ),
    ),
  );
}
