import '../../domain/entities/report.dart';

/// Serialization helpers between [Report] and Firestore maps.
class ReportMapper {
  static Map<String, dynamic> toMap(Report r) => {
        'id': r.id,
        'title': r.title,
        'description': r.description,
        'category': r.category.id,
        'status': r.status.id,
        'createdAt': r.createdAt.toIso8601String(),
        'photos': r.photos,
        'latitude': r.latitude,
        'longitude': r.longitude,
        'address': r.address,
        'userId': r.userId,
        'timeline': r.timeline
            .map((t) => {
                  'status': t.status.id,
                  'date': t.date.toIso8601String(),
                  'note': t.note,
                })
            .toList(),
      };

  static Report fromMap(Map<String, dynamic> map) {
    final tl = (map['timeline'] as List?) ?? const [];
    return Report(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: ReportCategoryX.fromId(map['category'] as String? ?? 'publicSafety'),
      status: ReportStatusX.fromId(map['status'] as String? ?? 'submitted'),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      photos: (map['photos'] as List?)?.cast<String>() ?? const [],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      address: map['address'] as String?,
      userId: map['userId'] as String?,
      timeline: tl
          .map((e) => TimelineEntry(
                status: ReportStatusX.fromId(e['status'] as String? ?? 'submitted'),
                date: DateTime.tryParse(e['date']?.toString() ?? '') ??
                    DateTime.now(),
                note: e['note'] as String?,
              ))
          .toList(),
    );
  }
}
