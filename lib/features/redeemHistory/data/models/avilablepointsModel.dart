class CurrentPoints {
  final double currentPoints;

  CurrentPoints({required this.currentPoints});
  factory CurrentPoints.fromJson(Map<String, dynamic> json) {
    return CurrentPoints(
      currentPoints: json['currentpoints'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentpoints': currentPoints.toDouble(),
    };
  }
}
