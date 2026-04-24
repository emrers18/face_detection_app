import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/face_detection_cubit.dart';
import '../cubit/face_detection_state.dart';

class FaceDetectionPage extends StatelessWidget {
  const FaceDetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Duygu Analizi (ML Kit)")),
      body: BlocBuilder<FaceDetectionCubit, FaceDetectionState>(
        builder: (context, state) {
          if (state is FaceDetectionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FaceDetectionStreaming) {
            return Stack(
              children: [
                // 1. Kamera Önizlemesi
                SizedBox.expand(
                  child: CameraPreview(state.cameraController),
                ),
                // 2. Duygu Göstergesi (Overlay)
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: _EmotionIndicator(faceEmotion: state.faceEmotion),
                ),
              ],
            );
          } else if (state is FaceDetectionError) {
            return Center(child: Text(state.message));
          }
          return Center(
            child: ElevatedButton(
              onPressed: () => context.read<FaceDetectionCubit>().initDetection(),
              child: const Text("Kamerayı Başlat"),
            ),
          );
        },
      ),
    );
  }
}

class _EmotionIndicator extends StatelessWidget {
  final dynamic faceEmotion; // FaceEmotionModel

  const _EmotionIndicator({this.faceEmotion});

  @override
  Widget build(BuildContext context) {
    if (faceEmotion == null) {
      return const Center(
        child: Chip(label: Text("Yüz aranıyor...")),
      );
    }

    final bool isHappy = faceEmotion.isHappy;
    final double percent = (faceEmotion.smilingProbability ?? 0) * 100;

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: isHappy ? Colors.green : Colors.orange,
          child: Icon(
            isHappy ? Icons.sentiment_very_satisfied : Icons.sentiment_neutral,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isHappy ? "MUTLU (%${percent.toStringAsFixed(0)})" : "NÖTR / ÜZGÜN",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}