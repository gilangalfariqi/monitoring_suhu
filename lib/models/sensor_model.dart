class SensorModel {
  final double temperature;
  final double humidity;
  final String condition;
  final Map history;

  SensorModel({
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.history,
  });

  factory SensorModel.fromMap(Map data) {
    return SensorModel(
      temperature: (data['temperature'] ?? 0).toDouble(),
      humidity: (data['humidity'] ?? 0).toDouble(),
      condition: data['condition'] ?? '-',
      history: data['history'] ?? {},
    );
  }
}
