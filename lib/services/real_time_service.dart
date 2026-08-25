import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/api/token_storage.dart';

class RealTimeService {
  static final RealTimeService instance = RealTimeService._();
  RealTimeService._();

  io.Socket? _socket;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get events => _controller.stream;

  bool get isConnected => _socket?.connected ?? false;

  Future<void> connect() async {
    if (_socket?.connected == true) return;

    final token = await TokenStorage.getAccessToken();
    if (token == null) return;

    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000/api';
    // Strip /api suffix to get the socket server root
    final socketUrl = baseUrl.replaceAll(RegExp(r'/api$'), '');

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {});
    _socket!.onDisconnect((_) {});

    _socket!.onAny((event, data) {
      final dataMap = data is Map ? data : {'data': data};
      
      // 1. Handle Live Location Update Event
      if (event == 'rider-location-update' && dataMap['data'] != null) {
        final locationData = dataMap['data'] as Map<String, dynamic>?;
        if (locationData != null) {
          _controller.add({
            'event': 'location_update',
            'packageId': dataMap['packageId'] ?? 'unknown',
            'latitude': locationData['latitude'],
            'longitude': locationData['longitude'],
            'timestamp': locationData['timestamp'],
            'status': locationData['package_status'],
          });
          return;
        }
      }

      // 2. Handle general events
      if (dataMap['data'] != null) {
        _controller.add({'event': event, 'data': dataMap['data']});
      } else {
        _controller.add({'event': event, ...dataMap});
      }
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void joinPackage(String packageId) {
    _socket?.emit('join-package', packageId);
  }

  void leavePackage(String packageId) {
    _socket?.emit('leave-package', packageId);
  }

  void joinTracking(String packageId) {
    _socket?.emit('join-tracking', packageId);
  }

  void leaveTracking(String packageId) {
    _socket?.emit('leave-tracking', packageId);
  }

  void sendMessage({required String packageId, required String content}) {
    _socket?.emit('send-message', {
      'packageId': packageId,
      'content': content,
    });
  }

  void on(String event, void Function(dynamic data) handler) {
    _socket?.on(event, handler);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void dispose() {
    _socket?.dispose();
    _controller.close();
  }
}
