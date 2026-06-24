import 'package:flutter/foundation.dart';
import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/package_model.dart';

class PackageService {
  final _api = ApiClient.instance;

  String _normalisePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[\s\-()]'), '');
    if (digits.startsWith('+')) return digits;
    if (digits.startsWith('00')) return '+${digits.substring(2)}';
    // Nigerian local format: 0XXXXXXXXXX → +234XXXXXXXXXX
    if (digits.startsWith('0') && digits.length == 11) {
      return '+234${digits.substring(1)}';
    }
    // Already looks like an international number without +
    return '+$digits';
  }

  Future<PackageModel> createPackage({
    required String pickupAddress,
    required String deliveryAddress,
    required String recipientName,
    required String recipientPhone,
    String? recipientEmail,
    required String description,
    required String category,
    required String packageSize,
    required String deliverySpeed,
    double? packageWeight,
    String? deliveryNotes,
    bool isFragile = false,
    String paymentMethod = 'WALLET',
  }) async {
    final response = await _api.post(ApiEndpoints.packages, data: {
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'recipient_name': recipientName,
      'recipient_phone': _normalisePhone(recipientPhone),
      if (recipientEmail != null && recipientEmail.isNotEmpty)
        'recipient_email': recipientEmail,
      'description': description,
      'category': category,
      'package_size': packageSize,
      'delivery_speed': deliverySpeed,
      if (packageWeight != null) 'package_weight': packageWeight,
      if (deliveryNotes != null && deliveryNotes.isNotEmpty)
        'delivery_notes': deliveryNotes,
      'is_fragile': isFragile,
      'payment_method': paymentMethod == 'CASH' ? 'CASH' : 'DIGITAL',
    });
    final packageData = response['package'] ?? response['data'] ?? response;
    return PackageModel.fromJson(packageData as Map<String, dynamic>);
  }

  Future<PackageModel> trackPackage(String trackingNumber) async {
    final response = await _api.get(ApiEndpoints.trackPackage(trackingNumber));
    final packageData = response['package'] ?? response['data'] ?? response;
    return PackageModel.fromJson(packageData as Map<String, dynamic>);
  }

  Future<List<PackageModel>> getMyPackages({int limit = 50}) async {
    try {
      final response = await _api.get(ApiEndpoints.packages);
      final list = response['packages'] ?? response['data'] ?? (response is List ? response : []);
      return (list as List)
          .map((e) => PackageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> cancelPackage(
    String packageId,
    String cancellationReason,
    bool riderHasPackage, {
    String? cancellationNote,
  }) async {
    await _api.post(ApiEndpoints.cancelPackage(packageId), data: {
      'cancellation_reason': cancellationReason,
      'rider_has_package': riderHasPackage,
      if (cancellationNote != null && cancellationNote.isNotEmpty)
        'cancellation_note': cancellationNote,
    });
  }

  Future<PackageModel> claimPackage(String trackingNumber) async {
    final response = await _api.post(ApiEndpoints.claimPackage(trackingNumber));
    final packageData = response['package'] ?? response['data'] ?? response;
    return PackageModel.fromJson(packageData as Map<String, dynamic>);
  }

  Future<PackageModel> getPackageById(String packageId) async {
    final response = await _api.get(ApiEndpoints.packageById(packageId));
    final packageData = response['package'] ?? response['data'] ?? response;
    return PackageModel.fromJson(packageData as Map<String, dynamic>);
  }
}
