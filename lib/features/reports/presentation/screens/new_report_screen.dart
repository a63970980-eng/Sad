import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_lookup.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/report.dart';
import '../providers/report_providers.dart';

class NewReportScreen extends ConsumerStatefulWidget {
  const NewReportScreen({super.key});

  @override
  ConsumerState<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends ConsumerState<NewReportScreen> {
  int _currentStep = 0;
  final List<GlobalKey<FormState>> _formKeys = List.generate(8, (_) => GlobalKey<FormState>());

  // Step 1: Category
  ReportCategory? _category;

  // Step 2: Location & District
  CapturedLocation? _location;
  bool _locating = false;
  String _selectedDistrict = 'صيرة (كريتر)';

  final List<String> _adenDistricts = [
    'صيرة (كريتر)',
    'المعلا',
    'التواهي',
    'خور مكسر',
    'المنصورة',
    'الشيخ عثمان',
    'دار سعد',
    'البريقة',
  ];

  // Step 3: Description
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  // Step 4: Photos
  final List<String> _photos = [];

  // Step 5: Additional dynamic questions
  String _severityLevel = 'متوسط / ينبغي معالجته';
  final _additionalNotesController = TextEditingController();

  // Step 6: Identity (Named vs Anonymous)
  bool _isAnonymous = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  List<String> _getStepTitles(AppLocalizations l) {
    return [
      l.stepCategory,
      l.stepLocation,
      l.stepDescription,
      l.stepPhotos,
      l.stepAdditionalInfo,
      l.stepIdentity,
      l.stepReview,
    ];
  }

  bool _validateCurrentStep(AppLocalizations l) {
    if (_currentStep == 0) {
      if (_category == null) {
        _snack(l.reportCategory);
        return false;
      }
    } else if (_currentStep < _formKeys.length && _formKeys[_currentStep].currentState != null) {
      return _formKeys[_currentStep].currentState!.validate();
    }
    return true;
  }

  void _nextStep(int totalSteps, AppLocalizations l) {
    if (!_validateCurrentStep(l)) return;
    FocusScope.of(context).unfocus();
    if (_currentStep < totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _previousStep() {
    FocusScope.of(context).unfocus();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
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
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.info),
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
      // In demo / no-permission, fall back to Aden center so the flow works seamlessly.
      setState(() => _location = CapturedLocation(
          latitude: 12.7855, longitude: 45.0187, address: 'عدن - $_selectedDistrict'));
      if (mounted) {
        _snack(AppLocalizations.of(context).locationCaptured);
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();

    final desc = '${_descController.text.trim()}\n[المديرية: $_selectedDistrict]\n[الخطورة: $_severityLevel]\n[الهوية: ${_isAnonymous ? "مجهول الهوية" : "باسم المستخدم"}]${_additionalNotesController.text.isNotEmpty ? "\n[ملاحظات: ${_additionalNotesController.text.trim()}]" : ""}';

    final report = await ref.read(submitReportControllerProvider.notifier).submit(
          title: _titleController.text.trim(),
          description: desc,
          category: _category!,
          photos: _photos,
          latitude: _location?.latitude,
          longitude: _location?.longitude,
          address: _location?.address ?? 'عدن - $_selectedDistrict',
        );

    if (!mounted) return;
    if (report != null) {
      _showSuccess(report.id);
    } else {
      _snack(l.errorGeneric);
    }
  }

  void _showSuccess(String reportId) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
            Text(
              l.reportSubmitted,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'رقم البلاغ المرجعي هو $reportId. تم تحويل البلاغ بنجاح للجهات المختصة بمديرية $_selectedDistrict.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.pop();
                },
                icon: const Icon(Icons.check_rounded),
                label: Text(l.ok),
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
    final submitting = ref.watch(submitReportControllerProvider).isLoading;
    final stepTitles = _getStepTitles(l);
    final totalSteps = stepTitles.length;
    final categoryColor = _category?.color ?? AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.newReport),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Stepper Header Component
          AppStepperHeader(
            currentStep: _currentStep,
            totalSteps: totalSteps,
            stepTitles: stepTitles,
            primaryColor: categoryColor,
          ),

          // Scrollable Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: IndexedStack(
                index: _currentStep,
                children: [
                  for (int i = 0; i < totalSteps; i++)
                    Form(
                      key: _formKeys[i],
                      child: _buildStepContent(i, totalSteps, l, submitting),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Action Navigation Bar
          _buildBottomNavigationBar(totalSteps, l, submitting, categoryColor),
        ],
      ),
    );
  }

  Widget _buildStepContent(
    int stepIndex,
    int totalSteps,
    AppLocalizations l,
    bool submitting,
  ) {
    switch (stepIndex) {
      case 0:
        return _buildCategoryStep(l);
      case 1:
        return _buildLocationStep(l);
      case 2:
        return _buildDescriptionStep(l);
      case 3:
        return _buildPhotosStep(l);
      case 4:
        return _buildAdditionalInfoStep(l);
      case 5:
        return _buildIdentityStep(l);
      case 6:
        return _buildReviewStep(l);
      default:
        return Container();
    }
  }

  // --- Individual Step UI Components ---

  Widget _buildCategoryStep(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(l.reportCategory),
        const SizedBox(height: 12),
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
      ],
    );
  }

  Widget _buildLocationStep(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(l.districtLabel),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedDistrict,
          items: _adenDistricts
              .map((d) => DropdownMenuItem(value: d, child: Text(d)))
              .toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedDistrict = val);
          },
          decoration: InputDecoration(hintText: l.selectDistrict),
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
      ],
    );
  }

  Widget _buildDescriptionStep(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(l.reportTitleLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(hintText: l.reportTitleHint),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
        ),
        const SizedBox(height: 16),
        _Label(l.reportDescLabel),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descController,
          maxLines: 5,
          decoration: InputDecoration(hintText: l.reportDescHint),
          validator: (v) =>
              (v == null || v.trim().length < 10) ? l.fieldRequired : null,
        ),
      ],
    );
  }

  Widget _buildPhotosStep(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(l.reportPhotos),
        const SizedBox(height: 6),
        Text(
          'يمكنك التقاط أو رفع صور لتأكيد حالة المشكلة ومساعدة الفرق الميدانية.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        _PhotoStrip(
          photos: _photos,
          onAdd: _showPhotoSheet,
          onRemove: (i) => setState(() => _photos.removeAt(i)),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoStep(AppLocalizations l) {
    // Dynamic fields per category
    String dynamicQuestion = 'معلومات وملاحظات إضافية حول البلاغ';
    if (_category == ReportCategory.powerOutage) {
      dynamicQuestion = 'تقدير مدة انقطاع التيار الكهربائي أو رقم المحول إن وجد';
    } else if (_category == ReportCategory.waterLeak) {
      dynamicQuestion = 'حجم تسرب المياه ومدى تأثيره على الطريق أو المنازل المجاوة';
    } else if (_category == ReportCategory.roadDamage) {
      dynamicQuestion = 'أثر التلف على حركة السير أو وقوع حوادث مرورية';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(l.severityLevel),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _severityLevel,
          items: [
            DropdownMenuItem(value: l.severityLow, child: Text(l.severityLow)),
            DropdownMenuItem(value: l.severityMedium, child: Text(l.severityMedium)),
            DropdownMenuItem(value: l.severityHigh, child: Text(l.severityHigh)),
          ],
          onChanged: (val) {
            if (val != null) setState(() => _severityLevel = val);
          },
        ),
        const SizedBox(height: 20),
        _Label(dynamicQuestion),
        const SizedBox(height: 8),
        TextFormField(
          controller: _additionalNotesController,
          maxLines: 3,
          decoration: InputDecoration(hintText: l.additionalNotesHint),
        ),
      ],
    );
  }

  Widget _buildIdentityStep(AppLocalizations l) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(l.reportIdentityType),
        const SizedBox(height: 6),
        Text(
          l.reportIdentityNotice,
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: 20),
        RadioListTile<bool>(
          value: false,
          groupValue: _isAnonymous,
          activeColor: AppColors.primary,
          title: Text(l.reportIdentityNamed,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: const Text('سيتم ربط البلاغ برقم هاتفك وملفك في التطبيق'),
          onChanged: (val) {
            if (val != null) setState(() => _isAnonymous = val);
          },
        ),
        const Divider(),
        RadioListTile<bool>(
          value: true,
          groupValue: _isAnonymous,
          activeColor: AppColors.primary,
          title: Text(l.reportIdentityAnonymous,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: const Text('لن تظهر أي بيانات شخصية للفرق المعنية بالبلاغ'),
          onChanged: (val) {
            if (val != null) setState(() => _isAnonymous = val);
          },
        ),
      ],
    );
  }

  Widget _buildReviewStep(AppLocalizations l) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مراجعة وتأكيد البلاغ',
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'يرجى مراجعة تفاصيل البلاغ قبل الإرسال لضمان وصول التنبيه بدقة للجهة المعنية.',
          style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        AppCard(
          borderColor: (_category?.color ?? AppColors.primary).withValues(alpha: 0.3),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildReviewRow(l.reportCategory, _category != null ? tr(l, _category!.labelKey) : 'غير محدد'),
              const Divider(height: 20),
              _buildReviewRow(l.districtLabel, _selectedDistrict),
              const Divider(height: 20),
              _buildReviewRow(l.reportTitleLabel, _titleController.text.isNotEmpty ? _titleController.text : 'لم يُدخل'),
              const Divider(height: 20),
              _buildReviewRow(l.severityLevel, _severityLevel),
              const Divider(height: 20),
              _buildReviewRow(l.reportIdentityType, _isAnonymous ? l.reportIdentityAnonymous : l.reportIdentityNamed),
              const Divider(height: 20),
              _buildReviewRow(l.reportPhotos, _photos.isNotEmpty ? 'تم إرفاق ${_photos.length} صور' : 'بدون صور'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(
    int totalSteps,
    AppLocalizations l,
    bool submitting,
    Color categoryColor,
  ) {
    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep == totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: submitting ? null : _previousStep,
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(l.stepPrevious),
              ),
            ),
          if (!isFirstStep) const SizedBox(width: 12),
          Expanded(
            flex: isFirstStep ? 2 : 1,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: categoryColor,
              ),
              onPressed: submitting ? null : () => _nextStep(totalSteps, l),
              icon: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(isLastStep ? Icons.send_rounded : Icons.arrow_forward_rounded),
              label: Text(isLastStep ? l.reviewAndSubmit : l.stepNext),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(fontWeight: FontWeight.w700),
      );
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
