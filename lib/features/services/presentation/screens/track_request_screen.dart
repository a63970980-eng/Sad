import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/services_catalog.dart';
import '../../data/repositories/supabase_service_repository.dart';

class TrackRequestScreen extends StatefulWidget {
  const TrackRequestScreen({
    super.key,
    required this.serviceId,
    required this.actionId,
    this.initialReference,
  });

  final String serviceId;
  final String actionId;
  final String? initialReference;

  @override
  State<TrackRequestScreen> createState() => _TrackRequestScreenState();
}

class _TrackRequestScreenState extends State<TrackRequestScreen> {
  late final TextEditingController _ref;
  final SupabaseServiceRepository _repository = SupabaseServiceRepository();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _request;
  List<Map<String, dynamic>> _timeline = const [];

  @override
  void initState() {
    super.initState();
    _ref = TextEditingController(text: widget.initialReference);
    if (widget.initialReference != null && widget.initialReference!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _track());
    }
  }

  @override
  void dispose() {
    _ref.dispose();
    super.dispose();
  }

  Future<void> _track() async {
    final reference = _ref.text.trim().toUpperCase();
    if (reference.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
      _request = null;
      _timeline = const [];
    });

    try {
      final request = await _repository.fetchRequestByReference(reference);
      if (!mounted) return;
      if (request == null) {
        setState(() {
          _loading = false;
          _error = 'لم يتم العثور على طلب بهذا الرقم ضمن طلبات حسابك.';
        });
        return;
      }

      final timeline = await _repository.fetchRequestTimeline(
        request['id'].toString(),
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _request = request;
        _timeline = timeline;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحميل حالة الطلب حالياً. تحقق من الاتصال وحاول مرة أخرى.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final service = ServicesCatalog.byId(widget.serviceId);
    final action = service?.actions.where((a) => a.id == widget.actionId).firstOrNull;
    final title = action?.titleKey == null ? l.track : _translateAction(l, action!.titleKey);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            'رقم الطلب',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ref,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'REQ-XXXXXXXXXX',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                  onSubmitted: (_) => _track(),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: _loading ? null : _track,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(l.track),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_error != null)
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.danger),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          if (_request != null) ...[
            _RequestHeader(request: _request!),
            const SizedBox(height: 16),
            _TimelineCard(
              request: _request!,
              timeline: _timeline,
            ),
          ],
        ],
      ),
    );
  }

  String _translateAction(AppLocalizations l, String key) {
    switch (key) {
      case 'actApplyId':
        return l.actApplyId;
      case 'actRenewId':
        return l.actRenewId;
      case 'actNewPassport':
        return l.actNewPassport;
      case 'actRenewPassport':
        return l.actRenewPassport;
      case 'actNewLicense':
        return l.actNewLicense;
      case 'actRenewLicense':
        return l.actRenewLicense;
      case 'actVehicleReg':
        return l.actVehicleReg;
      case 'actOwnershipTransfer':
        return l.actOwnershipTransfer;
      default:
        return l.track;
    }
  }
}

class _RequestHeader extends StatelessWidget {
  const _RequestHeader({required this.request});
  final Map<String, dynamic> request;

  @override
  Widget build(BuildContext context) {
    final status = request['status']?.toString() ?? 'submitted';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request['reference_no']?.toString() ?? '—',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.4,
                      ),
                ),
              ),
              StatusPill(label: _statusLabel(status), color: _statusColor(status)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'آخر تحديث: ${_formatDate(request['updated_at'] ?? request['created_at'])}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.request, required this.timeline});
  final Map<String, dynamic> request;
  final List<Map<String, dynamic>> timeline;

  @override
  Widget build(BuildContext context) {
    final entries = timeline.isEmpty
        ? [
            {
              'status': request['status']?.toString() ?? 'submitted',
              'created_at': request['created_at'],
              'note': null,
            }
          ]
        : timeline;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سجل الطلب',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 18),
          for (int i = 0; i < entries.length; i++)
            _TimelineRow(
              entry: entries[i],
              isLast: i == entries.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.isLast});
  final Map<String, dynamic> entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final status = entry['status']?.toString() ?? 'submitted';
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _statusColor(status),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _statusColor(status).withValues(alpha: 0.25),
                    width: 4,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.lightBorder),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _statusLabel(status),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatDate(entry['created_at']),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  if ((entry['note']?.toString() ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(entry['note'].toString()),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'submitted':
      return 'تم الاستلام';
    case 'reviewing':
      return 'قيد المراجعة';
    case 'assigned':
      return 'تمت الإحالة';
    case 'in_progress':
      return 'قيد التنفيذ';
    case 'approved':
      return 'تمت الموافقة';
    case 'completed':
      return 'مكتمل';
    case 'rejected':
      return 'مرفوض';
    case 'cancelled':
      return 'ملغى';
    default:
      return status;
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'completed':
    case 'approved':
      return AppColors.success;
    case 'rejected':
    case 'cancelled':
      return AppColors.danger;
    case 'in_progress':
    case 'assigned':
      return AppColors.info;
    case 'reviewing':
      return AppColors.warning;
    default:
      return AppColors.primary;
  }
}

String _formatDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return '—';
  return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
