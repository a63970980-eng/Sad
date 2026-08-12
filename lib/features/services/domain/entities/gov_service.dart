import 'package:flutter/material.dart';

/// A single action within a government service (e.g. "Renew ID").
class ServiceAction {
  const ServiceAction({
    required this.id,
    required this.titleKey,
    required this.icon,
    this.kind = ServiceActionKind.form,
  });

  final String id;
  final String titleKey; // localization key
  final IconData icon;
  final ServiceActionKind kind;
}

enum ServiceActionKind { form, track }

/// A top-level government service category.
class GovService {
  const GovService({
    required this.id,
    required this.titleKey,
    required this.icon,
    required this.color,
    required this.actions,
  });

  final String id;
  final String titleKey;
  final IconData icon;
  final Color color;
  final List<ServiceAction> actions;
}
