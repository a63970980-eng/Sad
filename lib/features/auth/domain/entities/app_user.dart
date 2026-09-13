import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.phoneNumber,
    this.fullName,
    this.nationalNumber,
    this.email,
    this.photoUrl,
    this.createdAt,
    this.role = 'citizen',
  });

  final String uid;
  final String phoneNumber;
  final String? fullName;
  final String? nationalNumber;
  final String? email;
  final String? photoUrl;
  final DateTime? createdAt;
  /// Server-controlled role. Never accept role changes from citizen profile updates.
  final String role;

  String get displayName =>
      (fullName != null && fullName!.trim().isNotEmpty) ? fullName! : phoneNumber;

  bool get isGovernmentUser => const {
        'system_admin',
        'entity_manager',
        'supervisor',
        'field_worker',
        'employee',
      }.contains(role);

  bool get canAccessAdminDashboard => const {
        'system_admin',
        'entity_manager',
        'supervisor',
      }.contains(role);

  String get initials {
    final n = fullName?.trim();
    if (n == null || n.isEmpty) return '👤';
    final parts = n.split(RegExp(r'\s+'));
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    if (parts.length == 1) return first.isEmpty ? '👤' : first;
    final second = parts[1].isNotEmpty ? parts[1][0] : '';
    return '$first$second'.toUpperCase();
  }

  AppUser copyWith({
    String? fullName,
    String? nationalNumber,
    String? email,
    String? photoUrl,
  }) {
    return AppUser(
      uid: uid,
      phoneNumber: phoneNumber,
      fullName: fullName ?? this.fullName,
      nationalNumber: nationalNumber ?? this.nationalNumber,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      role: role,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'phoneNumber': phoneNumber,
        'fullName': fullName,
        'nationalNumber': nationalNumber,
        'email': email,
        'photoUrl': photoUrl,
        'createdAt': createdAt?.toIso8601String(),
        'role': role,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        uid: map['uid'] as String,
        phoneNumber: map['phoneNumber'] as String? ?? '',
        fullName: map['fullName'] as String?,
        nationalNumber: map['nationalNumber'] as String?,
        email: map['email'] as String?,
        photoUrl: map['photoUrl'] as String?,
        createdAt: map['createdAt'] != null
            ? DateTime.tryParse(map['createdAt'].toString())
            : null,
        role: map['role'] as String? ?? 'citizen',
      );

  @override
  List<Object?> get props => [uid, phoneNumber, fullName, nationalNumber, role];
}
