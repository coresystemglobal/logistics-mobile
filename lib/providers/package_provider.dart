import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/package_service.dart';
import '../models/package_model.dart';

// ...existing code...
import '../services/package_service.dart';
import '../models/package_model.dart';
import 'package:traka_mobile/services/real_time_service.dart'; // Import the real-time service

// Provider for user's packages
final myPackagesProvider = FutureProvider.autoDispose<List<PackageModel>>((ref) async {
  return PackageService().getMyPackages();
});

/// AsyncNotifierProvider that manages the WebSocket connection for live tracking.
/// It handles connecting, joining the correct room, and exposing the structured
/// location updates stream.
final trackingNotifierProvider = AsyncNotifierProvider<TrackingNotifier, AsyncValue<PackageModel?>>(() {
  return TrackingNotifier();
});

class TrackingNotifier extends AsyncNotifier<PackageModel?> {
  @override
  Future<PackageModel?> build() async {
    // Initialize the state to null/loading
    return null;
  }

  Future<void> initializeTracking(String packageId) async {
    // 1. Manage Connection and Room Joining
    await RealTimeService.instance.connect();
    await RealTimeService.instance.joinTracking(packageId);

    // 2. Stream Subscription Logic
    // We use a stream controller to capture and filter the relevant data
    // and then set it as the state of this provider.
    _streamSubscription = RealTimeService.instance.events.stream.listen((data) {
      if (data['event'] == 'location_update' && data['packageId'] == packageId) {
        // Map the structured location event data to a PackageModel
        final packageModel = PackageModel(
          trackingNumber: packageId,
          currentLocation: MapCoordinate(
              latitude: data['latitude'],
              longitude: data['longitude'] as double),
          status: data['status'] as String? ?? 'IN_TRANSIT',
          lastUpdated: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
          isLive: true,
        );
        // Update the provider state with the new location data
        state = AsyncValue.data(packageModel);
      }
    });
  }

  Future<void> disposeTracking() async {
    // Clean up resources when the provider is no longer needed
    await RealTimeService.instance.leaveTracking('unknown'); // Use a placeholder ID
    _streamSubscription?.cancel();
    // Note: We do not call RealTimeService.instance.disconnect() here, 
    // as it might be needed for other parts of the app (like chat).
  }

  // Manually add a stream subscription field/method to handle cancellation
  StreamSubscription<Map<String, dynamic>>? _streamSubscription;

  // Custom dispose method to ensure cleanup
  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}

// Provider for unread notifications count
final unreadCountProvider = StateProvider<int>((ref) => 0);

// Provider for current active delivery (for riders)
final activeDeliveryProvider = StateProvider<PackageModel?>((ref) => null);
