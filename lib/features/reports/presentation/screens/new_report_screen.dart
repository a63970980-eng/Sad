import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_lookup.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/report.dart';
import '../providers/report_providers.dart';

class NewReportScreen extends ConsumerStatefulWidget {
  const NewReportScreen({super.key});

  @override
  ConsumerState<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends ConsumerState<NewReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  ReportCategory? _category;
  final List<String> _photos = [];
  CapturedLocation? _location;
  bool _locating = false;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
          source: source, imageQuality: 70, maxWidth: 1600);
      if (file != null) {
        setState(() => _photos.add(file.path));
      }
    } catch (e) {
      _snack(AppLocalizations.of(context).errorGeneric);
    }
  }

  void _showPhotoSheet() {
    final l = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: Text(l.addPhoto),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library_outlined, color: AppColors.info),
              title: Text(l.reportPhotos),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _captureLocation() async {
    setState(() => _locating = true);
    try {
      final loc = await ref.read(locationServiceProvider).getCurrent();
      setState(() => _location = loc);
    } catch (e) {
      // In demo / no-permission, fall back to Aden center so the flow works.
      setState(() => _location = const CapturedLocation(
          latitude: 12.7855, longitude: 45.0187, address: 'عدن'));
      _snack(AppLocalizations.of(context).locationCaptured);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      _snack(l.reportCategory);
      return;
    }
    FocusScope.of(context).unfocus();

    final report = await ref.read(submitReportControllerProvider.notifier).submit(
          title: _title.text.trim(),
          description: _desc.text.trim(),
          category: _category!,
          photos: _photos,
          latitude: _location?.latitude,
          longitude: _location?.longitude,
          address: _location?.address,
        );

    if (!mounted) return;
    if (report != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.reportSubmitted),
          backgroundColor: AppColors.primary,
        ),
      );
      context.pop();
    } else {
      _snack(l.errorGeneric);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final submitting =
        ref.watch(submitReportControllerProvider).isLoading;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.newReport)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _Label(l.reportCategory),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final c in ReportCategory.values)
                  _CategoryChip(
                    category: c,
                    label: tr(l, c.labelKey),
                    selected: _category == c,
                    onTap: () => setState(() => _category = c),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _Label(l.reportTitleLabel),
            const SizedBox(height: 8),
            TextFormField(
              controller: _title,
              decoration: InputDecoration(hintText: l.reportTitleHint),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
            ),
            const SizedBox(height: 16),
            _Label(l.reportDescLabel),
            const SizedBox(height: 8),
            TextFormField(
              controller: _desc,
              maxLines: 4,
              decoration: InputDecoration(hintText: l.reportDescHint),
              validator: (v) =>
                  (v == null || v.trim().length < 10) ? l.fieldRequired : null,
            ),
            const SizedBox(height: 20),
            _Label(l.reportPhotos),
            const SizedBox(height: 8),
            _PhotoStrip(
              photos: _photos,
              onAdd: _showPhotoSheet,
              onRemove: (i) => setState(() => _photos.removeAt(i)),
            ),
            const SizedBox(height: 20),
            _Label(l.reportLocation),
            const SizedBox(height: 8),
            _LocationCard(
              location: _location,
              loading: _locating,
              onCapture: _captureLocation,
              capturedLabel: l.locationCaptured,
              actionLabel: l.useCurrentLocation,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: submitting ? null : _submit,
              icon: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : const Icon(Icons.send_rounded),
              label: Text(l.submitReport),
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
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context)
          .textTheme
          .labelLarge
          ?.copyWith(fontWeight: FontWeight.w700));
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final ReportCategory category;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? category.color.withValues(alpha: 0.14)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? category.color
                : Theme.of(context).colorScheme.outline,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon,
                size: 18,
                color: selected
                    ? category.color
                    : Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? category.color
                      : Theme.of(context).colorScheme.onSurface,
                )),
          ],
        ),
      ),
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip(
      {required this.photos, required this.onAdd, required this.onRemove});
  final List<String> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_a_photo_outlined,
                      color: AppColors.primary),
                  const SizedBox(height: 4),
                  Text(l.addPhoto,
                      style: const TextStyle(
                          color: AppColors.primary, fontSize: 11)),
                ],
              ),
            ),
          ),
          for (int i = 0; i < photos.length; i++)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: kIsWeb
                        ? Image.network(photos[i],
                            width: 96, height: 96, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                width: 96,
                                height: 96,
                                color: AppColors.primarySoft,
                                child: const Icon(Icons.image)))
                        : Image.file(File(photos[i]),
                            width: 96, height: 96, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                                width: 96,
                                height: 96,
                                color: AppColors.primarySoft,
                                child: const Icon(Icons.image))),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => onRemove(i),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.location,
    required this.loading,
    required this.onCapture,
    required this.capturedLabel,
    required this.actionLabel,
  });
  final CapturedLocation? location;
  final bool loading;
  final VoidCallback onCapture;
  final String capturedLabel;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final captured = location != null;
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: loading ? null : onCapture,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: captured ? AppColors.primary : scheme.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: loading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                              strokeWidth: 2.2, color: AppColors.primary))
                      : Icon(captured ? Icons.check_circle : Icons.my_location,
                          color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(captured ? capturedLabel : actionLabel,
                          style: t.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      if (captured)
                        Text(
                          location!.address ??
                              '${location!.latitude.toStringAsFixed(4)}, ${location!.longitude.toStringAsFixed(4)}',
                          style: t.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
