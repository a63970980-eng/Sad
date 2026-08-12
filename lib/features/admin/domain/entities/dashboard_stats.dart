import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  const DashboardStats({
    required this.totalReports,
    required this.newReports,
    required this.inProgressReports,
    required this.resolvedReports,
    required this.rejectedReports,
    required this.totalUsers,
    required this.activeUsers,
    required this.totalServices,
    required this.totalRequests,
    required this.pendingRequests,
    required this.completedRequests,
  });

  final int totalReports;
  final int newReports;
  final int inProgressReports;
  final int resolvedReports;
  final int rejectedReports;
  final int totalUsers;
  final int activeUsers;
  final int totalServices;
  final int totalRequests;
  final int pendingRequests;
  final int completedRequests;

  double get reportResolutionRate =>
      totalReports == 0 ? 0 : (resolvedReports / totalReports) * 100;

  double get userEngagementRate =>
      totalUsers == 0 ? 0 : (activeUsers / totalUsers) * 100;

  @override
  List<Object?> get props => [
    totalReports,
    newReports,
    inProgressReports,
    resolvedReports,
    rejectedReports,
    totalUsers,
    activeUsers,
    totalServices,
    totalRequests,
    pendingRequests,
    completedRequests,
  ];
}

class RegionalReportStats extends Equatable {
  const RegionalReportStats({
    required this.region,
    required this.total,
    required this.resolved,
    required this.pending,
  });

  final String region;
  final int total;
  final int resolved;
  final int pending;

  double get completionPercentage =>
      total == 0 ? 0 : (resolved / total) * 100;

  @override
  List<Object?> get props => [region, total, resolved, pending];
}
