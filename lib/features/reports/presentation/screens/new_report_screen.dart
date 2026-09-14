import 'dart:io' show File;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_lookup.dart';
import '../../../../core/utils/location_service.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/report.dart';
import '../providers/report_providers.dart';
import '../widgets/report_location_picker.dart';

class NewReportScreen extends ConsumerStatefulWidget {
  const NewReportScreen({super.key});

  @override
  ConsumerState<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends ConsumerState<NewReportScreen> {
  int _currentStep = 0;
  final List<GlobalKey<FormState>> _formKeys = List.generate(8, (_) => GlobalKey<FormState>());
  ReportCategory? _category;
  CapturedLocation? _location;
  bool _locating = false;
  String _selectedDistrict = 'صيرة (كريتر)';
  final List<String> _adenDistricts = ['صيرة (كريتر)', 'المعلا', 'التواهي', 'خور مكسر', 'المنصورة', 'الشيخ عثمان', 'دار سعد', 'البريقة'];
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final List<String> _photos = [];
  String _severityLevel = 'متوسط / ينبغي معالجته';
  final _additionalNotesController = TextEditingController();
  bool _isAnonymous = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  List<String> _getStepTitles(AppLocalizations l) => [
        l.stepCategory, l.stepLocation, l.stepDescription, l.stepPhotos,
        l.stepAdditionalInfo, l.stepIdentity, l.stepReview,
      ];

  bool _validateCurrentStep(AppLocalizations l) {
    if (_currentStep == 0) {
      if (_category == null) {
        _snack(l.reportCategory);
        return false;
      }
    } else if (_currentStep == 1 && _location == null) {
      _snack('حدد موقع البلاغ من GPS أو اختره من الخريطة قبل المتابعة.');
      return false;
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
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await ImagePicker().pickImage(source: source, imageQuality: 70, maxWidth: 1600);
      if (file != null && mounted) setState(() => _photos.add(file.path));
    } catch (_) {
      if (mounted) _snack(AppLocalizations.of(context).errorGeneric);
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
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
              title: Text(l.addPhoto),
              onTap: () { Navigator.pop(context); _pickPhoto(ImageSource.camera); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.info),
              title: Text(l.reportPhotos),
              onTap: () { Navigator.pop(context); _pickPhoto(ImageSource.gallery); },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _captureLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final loc = await ref.read(locationServiceProvider).getCurrent();
      if (mounted) setState(() => _location = loc);
    } on LocationServiceException catch (e) {
      if (mounted) _snack(e.message);
    } catch (_) {
      if (mounted) _snack(AppLocalizations.of(context).errorGeneric);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pickLocationFromMap() async {
    final initial = _location == null
        ? const LatLng(AppConstants.adenLat, AppConstants.adenLng)
        : LatLng(_location!.latitude, _location!.longitude);
    final picked = await showModalBottomSheet<CapturedLocation>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ReportLocationPicker(
        initial: initial,
        locationService: ref.read(locationServiceProvider),
      ),
    );
    if (picked != null && mounted) setState(() => _location = picked);
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    if (_location == null) {
      _snack('يجب تحديد موقع البلاغ قبل الإرسال.');
      return;
    }
    FocusScope.of(context).unfocus();
    final desc = '${_descController.text.trim()}\n'
        '[المديرية: $_selectedDistrict]\n'
        '[الخطورة: $_severityLevel]'
        '${_additionalNotesController.text.isNotEmpty ? "\n[ملاحظات: ${_additionalNotesController.text.trim()}]" : ""}';
    final report = await ref.read(submitReportControllerProvider.notifier).submit(
      title: _titleController.text.trim(),
      description: desc,
      category: _category!,
      photos: _photos,
      isAnonymous: _isAnonymous,
      latitude: _location!.latitude,
      longitude: _location!.longitude,
      address: _location!.address ?? 'إحداثيات موقع البلاغ',
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
            const SizedBox(height: 24),
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 52),
            ),
            const SizedBox(height: 20),
            Text(l.reportSubmitted, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text(
              'رقم البلاغ المرجعي هو $reportId. تم تحويل البلاغ بنجاح للجهات المختصة بمديرية $_selectedDistrict.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () { Navigator.pop(context); context.pop(); },
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
    final titles = _getStepTitles(l);
    final color = _category?.color ?? AppColors.primary;
    return Scaffold(
      appBar: AppBar(title: Text(l.newReport), elevation: 0),
      body: Column(
        children: [
          AppStepperHeader(currentStep: _currentStep, totalSteps: titles.length, stepTitles: titles, primaryColor: color),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: IndexedStack(
                index: _currentStep,
                children: [for (int i = 0; i < titles.length; i++) Form(key: _formKeys[i], child: _buildStepContent(i, l))],
              ),
            ),
          ),
          _buildBottomNavigationBar(titles.length, l, submitting, color),
        ],
      ),
    );
  }

  Widget _buildStepContent(int i, AppLocalizations l) => switch (i) {
        0 => _buildCategoryStep(l),
        1 => _buildLocationStep(l),
        2 => _buildDescriptionStep(l),
        3 => _buildPhotosStep(l),
        4 => _buildAdditionalInfoStep(l),
        5 => _buildIdentityStep(l),
        6 => _buildReviewStep(l),
        _ => const SizedBox.shrink(),
      };

  Widget _buildCategoryStep(AppLocalizations l) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.reportCategory, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('اختر نوع المشكلة أو البلاغ الذي تريد إرساله.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          ...ReportCategory.values.map((category) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: RadioListTile<ReportCategory>(
                  value: category,
                  groupValue: _category,
                  onChanged: (value) => setState(() => _category = value),
                  title: Text(l10nCategory(context, category)),
                  secondary: Icon(category.icon, color: category.color),
                ),
              )),
        ],
      );

  Widget _buildLocationStep(AppLocalizations l) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.reportLocation, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('حدد الموقع بدقة لمساعدة الجهة المختصة على الوصول إلى البلاغ.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _locating ? null : _captureLocation,
              icon: _locating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location_rounded),
              label: Text(_locating ? 'جارٍ تحديد موقعك...' : 'استخدام موقعي الحالي'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _pickLocationFromMap,
              icon: const Icon(Icons.map_outlined),
              label: Text('اختيار الموقع من الخريطة'),
            ),
          ),
          if (_location != null) ...[
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on_rounded, color: AppColors.primary),
                title: Text(_location!.address ?? 'الموقع المحدد'),
                subtitle: Text('${_location!.latitude.toStringAsFixed(6)}, ${_location!.longitude.toStringAsFixed(6)}'),
              ),
            ),
          ],
        ],
      );

  Widget _buildDescriptionStep(AppLocalizations l) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.reportDescription, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(labelText: l.reportTitle, border: const OutlineInputBorder()),
            validator: (value) => value == null || value.trim().isEmpty ? 'اكتب عنوان البلاغ.' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _descController,
            minLines: 6,
            maxLines: 10,
            decoration: InputDecoration(labelText: l.reportDescription, alignLabelWithHint: true, border: const OutlineInputBorder()),
            validator: (value) => value == null || value.trim().length < 10 ? 'اكتب وصفًا أوضح للبلاغ.' : null,
          ),
        ],
      );

  Widget _buildPhotosStep(AppLocalizations l) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.reportPhotos, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('أضف صورًا تساعد على توضيح المشكلة، ويمكن المتابعة دون صور.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _showPhotoSheet, icon: const Icon(Icons.add_a_photo_outlined), label: Text(l.addPhoto))),
          const SizedBox(height: 14),
          if (_photos.isEmpty) const SizedBox(height: 100, child: Center(child: Text('لم تتم إضافة صور بعد.'))),
          if (_photos.isNotEmpty) Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _photos.asMap().entries.map((entry) {
              final index = entry.key;
              final path = entry.value;
              return Stack(
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: kIsWeb ? Image.network(path, width: 100, height: 100, fit: BoxFit.cover) : Image.file(File(path), width: 100, height: 100, fit: BoxFit.cover)),
                  Positioned(top: 2, right: 2, child: IconButton(onPressed: () => setState(() => _photos.removeAt(index)), icon: const CircleAvatar(radius: 13, child: Icon(Icons.close, size: 16)))),
                ],
              );
            }).toList(),
          ),
        ],
      );

  Widget _buildAdditionalInfoStep(AppLocalizations l) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.additionalInfo, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedDistrict,
            decoration: const InputDecoration(labelText: 'مديرية البلاغ', border: OutlineInputBorder()),
            items: _adenDistricts.map((district) => DropdownMenuItem(value: district, child: Text(district))).toList(),
            onChanged: (value) { if (value != null) setState(() => _selectedDistrict = value); },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: _severityLevel,
            decoration: const InputDecoration(labelText: 'درجة الأهمية', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'منخفض / يمكن معالجته لاحقًا', child: Text('منخفض / يمكن معالجته لاحقًا')),
              DropdownMenuItem(value: 'متوسط / ينبغي معالجته', child: Text('متوسط / ينبغي معالجته')),
              DropdownMenuItem(value: 'مرتفع / يحتاج تدخلًا سريعًا', child: Text('مرتفع / يحتاج تدخلًا سريعًا')),
              DropdownMenuItem(value: 'عاجل / خطر مباشر', child: Text('عاجل / خطر مباشر')),
            ],
            onChanged: (value) { if (value != null) setState(() => _severityLevel = value); },
          ),
          const SizedBox(height: 14),
          TextFormField(controller: _additionalNotesController, minLines: 4, maxLines: 7, decoration: const InputDecoration(labelText: 'ملاحظات إضافية (اختياري)', alignLabelWithHint: true, border: OutlineInputBorder())),
        ],
      );

  Widget _buildIdentityStep(AppLocalizations l) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.identity, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('اختر ما إذا كنت تريد إظهار هويتك للجهة المختصة.', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Card(
            child: SwitchListTile.adaptive(
              value: _isAnonymous,
              onChanged: (value) => setState(() => _isAnonymous = value),
              title: Text(_isAnonymous ? 'بلاغ مجهول الهوية' : 'بلاغ باسم المستخدم'),
              subtitle: Text(_isAnonymous ? 'لن تظهر هويتك ضمن بيانات البلاغ للجهات المستلمة.' : 'سيكون البلاغ مرتبطًا بحسابك لتتمكن من متابعته.'),
              secondary: Icon(_isAnonymous ? Icons.visibility_off_outlined : Icons.person_outline),
            ),
          ),
        ],
      );

  Widget _buildReviewStep(AppLocalizations l) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.review, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _reviewTile('نوع البلاغ', _category == null ? 'غير محدد' : l10nCategory(context, _category!)),
          _reviewTile('العنوان', _titleController.text.trim()),
          _reviewTile('المديرية', _selectedDistrict),
          _reviewTile('الأهمية', _severityLevel),
          _reviewTile('الموقع', _location?.address ?? 'تم تحديد الإحداثيات'),
          _reviewTile('الهوية', _isAnonymous ? 'مجهول الهوية' : 'باسم المستخدم'),
          if (_photos.isNotEmpty) _reviewTile('الصور', '${_photos.length} صورة'),
          const SizedBox(height: 10),
          Text(_descController.text.trim(), style: Theme.of(context).textTheme.bodyMedium),
        ],
      );

  Widget _reviewTile(String label, String value) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(value.isEmpty ? 'غير محدد' : value)),
      );

  Widget _buildBottomNavigationBar(int totalSteps, AppLocalizations l, bool submitting, Color color) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              if (_currentStep > 0) Expanded(child: OutlinedButton(onPressed: submitting ? null : _previousStep, child: Text(l.back))),
              if (_currentStep > 0) const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: color),
                  onPressed: submitting ? null : () => _nextStep(totalSteps, l),
                  child: submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(_currentStep == totalSteps - 1 ? l.submit : l.next),
                ),
              ),
            ],
          ),
        ),
      );
}
