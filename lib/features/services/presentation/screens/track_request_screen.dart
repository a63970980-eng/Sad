import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_lookup.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../reports/domain/entities/report.dart';
import '../../data/services_catalog.dart';

class TrackRequestScreen extends StatefulWidget {
  const TrackRequestScreen(
      {super.key, required this.serviceId, required this.actionId});
  final String serviceId;
  final String actionId;

  @override
  State<TrackRequestScreen> createState() => _TrackRequestScreenState();
}

class _TrackRequestScreenState extends State<TrackRequestScreen> {
  final _ref = TextEditingController();
  bool _loading = false;
  _TrackResult? _result;

  @override
  void dispose() {
    _ref.dispose();
    super.dispose();
  }

  Future<void> _track() async {
    if (_ref.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    final now = DateTime.now();
    setState(() {
      _loading = false;
      _result = _TrackResult(
        reference: _ref.text.trim().toUpperCase(),
        status: ReportStatus.inProgress,
        timeline: [
          TimelineEntry(status: ReportStatus.submitted, date: now.subtract(const Duration(days: 4))),
          TimelineEntry(status: ReportStatus.reviewing, date: now.subtract(const Duration(days: 3))),
          TimelineEntry(status: ReportStatus.inProgress, date: now.subtract(const Duration(days: 1))),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final service = ServicesCatalog.byId(widget.serviceId);
    final action =
        service?.actions.where((a) => a.id == widget.actionId).firstOrNull;
    final title = action != null ? tr(l, action.titleKey) : l.track;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(l.actTrackId,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ref,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'REQ-XXXXXX',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
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
                              valueColor: AlwaysStoppedAnimation(Colors.white)))
                      : Text(l.track),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_result != null) _ResultCard(result: _result!),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});
  final _TrackResult result;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(result.reference,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              ),
              StatusPill(
                label: tr(l, result.status.labelKey),
                color: result.status.color,
              ),
            ],
          ),
          const Divider(height: 28),
          Text(l.reportTimeline,
              style: t.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (int i = 0; i < result.timeline.length; i++)
            _TimelineRow(
              entry: result.timeline[i],
              isLast: i == result.timeline.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.isLast});
  final TimelineEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
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
                  color: entry.status.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: entry.status.color.withValues(alpha: 0.3), width: 4),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.lightBorder,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tr(l, entry.status.labelKey),
                    style: t.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  '${entry.date.year}/${entry.date.month}/${entry.date.day}',
                  style: t.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackResult {
  _TrackResult(
      {required this.reference, required this.status, required this.timeline});
  final String reference;
  final ReportStatus status;
  final List<TimelineEntry> timeline;
}
