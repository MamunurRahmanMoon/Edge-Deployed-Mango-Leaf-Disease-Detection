class ScanHistory {
  final int? id;
  final String imagePath;
  final String diseaseName;
  final double confidence;
  final DateTime timestamp;

  ScanHistory({
    this.id,
    required this.imagePath,
    required this.diseaseName,
    required this.confidence,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_path': imagePath,
      'disease_name': diseaseName,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScanHistory.fromMap(Map<String, dynamic> map) {
    return ScanHistory(
      id: map['id'],
      imagePath: map['image_path'],
      diseaseName: map['disease_name'],
      confidence: map['confidence'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
