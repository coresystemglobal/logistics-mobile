# Opright Mobile

The customer and business app for Opright Logistics. Users can book deliveries, track packages in real-time, and manage their wallet.

## Stack

- Flutter (Dart)
- Riverpod (state management)
- GoRouter (navigation)
- Dio (HTTP)
- Socket.IO (real-time updates)

## Getting Started

1. Clone the repo and navigate to this directory
2. Copy `.env.example` to `.env` and fill in the values
3. Run `flutter pub get`
4. Run `flutter run`

## Environment

| Variable | Description |
|----------|-------------|
| `API_BASE_URL` | Base URL for the Opright API |
| `WS_URL` | WebSocket URL for real-time events |
