import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_lookup.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/services_catalog.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen(
      {super.key, required this.serviceId, required this.actionId});
  final String serviceId;
  final String actionId;

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _national = TextEditingController();
  final _phone = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _national.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _submitting = false);
    final ref = 'REQ-${const Uuid().v4().substring(0, 6).toUpperCase()}';
    _showSuccess(ref);
  }

  void _showSuccess(String reference) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 52),
            ),
            const SizedBox(height: 20),
            Text(l.requestSubmitted,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(l.requestSubmittedDesc(reference),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.pushReplacement(
                    '/services/${widget.serviceId}/track/${widget.actionId}?ref=$reference',
                  );
                },
                icon: const Icon(Icons.travel_explore_outlined),
                label: Text(l.track),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                child: Text(l.ok),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final service = ServicesCatalog.byId(widget.serviceId);
    final action =
        service?.actions.where((a) => a.id == widget.actionId).firstOrNull;
    final title = action != null ? tr(l, action.titleKey) : l.servicesTitle;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            if (service != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: service.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: service.color.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(action?.icon ?? service.icon, color: service.color),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${tr(l, service.titleKey)} • $title',
                        style: t.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600, color: service.color),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            _Label(l.fullName),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(hintText: l.fullName),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
            ),
            const SizedBox(height: 16),
            _Label(l.nationalNumber),
            TextFormField(
              controller: _national,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(hintText: l.nationalNumber),
              validator: (v) =>
                  (v == null || v.trim().length < 6) ? l.fieldRequired : null,
            ),
            const SizedBox(height: 16),
            _Label(l.phoneNumber),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(hintText: l.phoneHint),
              validator: (v) =>
                  (v == null || v.trim().length < 9) ? l.fieldRequired : null,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : const Icon(Icons.send_rounded),
              label: Text(l.applyNow),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w700)),
      );
}
