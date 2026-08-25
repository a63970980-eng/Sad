import 'dart:io' show File;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../models/report_model.dart';

/// Reports backed by Cloud Firestore + Firebase Storage (photo uploads).
class FirebaseReportRepository implements ReportRepository {
  FirebaseReportRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('reports');

  @override
  Stream<List<Report>> watchUserReports(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ReportMapper.fromMap(d.data())).toList());
  }

  @override
  Future<List<Report>> fetchUserReports(String userId) async {
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => ReportMapper.fromMap(d.data())).toList();
  }

  @override
  Future<Report> submitReport(Report report) async {
    // Upload any local photo paths to Storage.
    final uploaded = <String>[];
    for (final path in report.photos) {
      if (path.startsWith('http')) {
        uploaded.add(path);
        continue;
      }
      final ref = _storage
          .ref('reports/${report.id}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      if (kIsWeb) {
        // On web, path could be a blob URL or network path, or putData/putBlob can be used if bytes
        // If it's a URL, add directly or putData.
        uploaded.add(path);
      } else {
        await ref.putFile(File(path));
        uploaded.add(await ref.getDownloadURL());
      }
    }

    final toSave = Report(
      id: report.id,
      title: report.title,
      description: report.description,
      category: report.category,
      status: report.status,
      createdAt: report.createdAt,
      photos: uploaded,
      timeline: report.timeline,
      latitude: report.latitude,
      longitude: report.longitude,
      address: report.address,
      userId: report.userId,
    );

    await _col.doc(report.id).set(ReportMapper.toMap(toSave));
    return toSave;
  }

  @override
  Future<Report?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return ReportMapper.fromMap(doc.data()!);
  }
}
