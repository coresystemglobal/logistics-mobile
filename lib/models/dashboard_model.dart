class BusinessDashboardModel {
  final int activeShipments;
  final int deliveredToday;
  final double totalSpend;
  final double pendingPayment;
  final List<DailyShipmentData> weeklyData;

  const BusinessDashboardModel({
    required this.activeShipments,
    required this.deliveredToday,
    required this.totalSpend,
    required this.pendingPayment,
    required this.weeklyData,
  });

  factory BusinessDashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['dashboard'] ?? json['data'] ?? json;
    final weekly = data['weekly_data'] ?? data['weeklyData'] ?? [];
    return BusinessDashboardModel(
      activeShipments:
          (data['active_shipments'] ?? data['activeShipments'] as num?)
                  ?.toInt() ??
              0,
      deliveredToday:
          (data['delivered_today'] ?? data['deliveredToday'] as num?)
                  ?.toInt() ??
              0,
      totalSpend:
          (data['total_spend'] ?? data['totalSpend'] as num?)?.toDouble() ??
              0.0,
      pendingPayment:
          (data['pending_payment'] ?? data['pendingPayment'] as num?)
                  ?.toDouble() ??
              0.0,
      weeklyData: (weekly as List)
          .map((e) => DailyShipmentData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class DailyShipmentData {
  final String day; // e.g. 'Mon'
  final int count;

  const DailyShipmentData({required this.day, required this.count});

  factory DailyShipmentData.fromJson(Map<String, dynamic> json) =>
      DailyShipmentData(
        day: json['day']?.toString() ?? '',
        count: (json['count'] as num?)?.toInt() ?? 0,
      );
}
