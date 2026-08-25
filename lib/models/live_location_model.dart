import 'package:flutter/material.dart';

class LiveLocationModel {
  final String packageId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String status;

  const LiveLocationModel({
    required this.packageId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.status,
  });

  // Helper method to create the model from a raw map (used by the service layer)
  factory LiveLocationModel.fromMap(Map<String, dynamic> map) {
    return LiveLocationModel(
      packageId: map['packageId'] ?? 'unknown',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch),
      status: map['status'] ?? 'UNKNOWN',
    );
  }
}
