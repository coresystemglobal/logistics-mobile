import 'package:flutter_test/flutter_test.dart';
import 'package:traka_mobile/models/user_model.dart';
import 'package:traka_mobile/models/package_model.dart';

void main() {
  group('UserModel', () {
    test('fromJson creates valid UserModel', () {
      final json = {
        'id': '123',
        'email': 'test@example.com',
        'role': 'USER',
        'type': 'USER',
        'first_name': 'John',
        'last_name': 'Doe',
        'phone': '+1234567890',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.role, 'USER');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
    });

    test('toJson creates valid JSON', () {
      const user = UserModel(
        id: '123',
        email: 'test@example.com',
        role: 'USER',
        type: 'USER',
        firstName: 'John',
        lastName: 'Doe',
        phone: '+1234567890',
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['email'], 'test@example.com');
      expect(json['first_name'], 'John');
    });
  });

  group('PackageModel', () {
    test('fromJson creates valid PackageModel', () {
      final json = {
        'id': 'pkg-123',
        'tracking_number': 'TRK123456',
        'sender_id': 'user-1',
        'status': 'PENDING',
        'pickup_address': '123 Main St',
        'delivery_address': '456 Oak Ave',
        'created_at': '2024-01-01T00:00:00Z',
      };

      final package = PackageModel.fromJson(json);

      expect(package.id, 'pkg-123');
      expect(package.trackingNumber, 'TRK123456');
      expect(package.status, 'PENDING');
    });
  });
}
