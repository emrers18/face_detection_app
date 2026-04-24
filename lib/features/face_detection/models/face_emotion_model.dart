class FaceEmotionModel{
  final double? smilingProbability;

  FaceEmotionModel({this.smilingProbability});

  //Eğer smilingProbability 0.7'den büyükse gülüyor kabul edilir.
  bool get isHappy => (smilingProbability ?? 0.0) > 0.7;

}