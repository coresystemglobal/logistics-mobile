import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/package_service.dart';
import '../models/package_model.dart';

// Provider for user's packages
final myPackagesProvider = FutureProvider.autoDispose<List<PackageModel>>((ref) async {
  return PackageService().getMyPackages();
});

// Family provider for detailed tracking
final trackingProvider = FutureProvider.family.autoDispose<PackageModel, String>((ref, trackingNumber) async {
  return PackageService().trackPackage(trackingNumber);
});

// Provider for unread notifications count
final unreadCountProvider = StateProvider<int>((ref) => 0);

// Provider for current active delivery (for riders)
final activeDeliveryProvider = StateProvider<PackageModel?>((ref) => null);
