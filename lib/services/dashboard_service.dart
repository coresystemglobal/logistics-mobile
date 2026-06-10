import '../core/api/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final _api = ApiClient.instance;

  Future<RiderDashboardModel> getRiderDashboard() async {
    final response = await _api.get(ApiEndpoints.dashboardRider);
    return RiderDashboardModel.fromJson(response);
  }

  Future<BusinessDashboardModel> getManagerDashboard() async {
    final response = await _api.get(ApiEndpoints.dashboardManager);
    return BusinessDashboardModel.fromJson(response);
  }
}
