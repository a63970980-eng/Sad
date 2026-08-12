import '../entities/report.dart';

abstract class ReportRepository {
  Stream<List<Report>> watchUserReports(String userId);
  Future<List<Report>> fetchUserReports(String userId);
  Future<Report> submitReport(Report report);
  Future<Report?> getById(String id);
}
