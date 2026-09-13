import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/repositories/supabase_service_repository.dart';
import '../../data/services_catalog.dart';
import '../../domain/entities/gov_service.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({
    super.key,
    required this.serviceId,
    required this.actionId,
  });

  final String serviceId;
  final String actionId;

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _repository = SupabaseServiceRepository();
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
  final _name = TextEditingController();
  final _nationalNumber = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _documentNumber = TextEditingController();
  final _plate = TextEditingController();
  final _vehicleModel = TextEditingController();
  final _meter = TextEditingController();
  final _details = TextEditingController();

  int _step = 0;
  bool _submitting = false;
  bool _acknowledgedDocuments = false;
  String _district = 'صيرة (كريتر)';
  String? _error;

  static const _districts = [
    'صيرة (كريتر)',
    'المعلا',
    'التواهي',
    'خور مكسر',
    'المنصورة',
    'الشيخ عثمان',
    'دار سعد',
    'البريقة',
  ];

  @override
  void dispose() {
    _name.dispose();
    _nationalNumber.dispose();
    _phone.dispose();
    _address.dispose();
    _documentNumber.dispose();
    _plate.dispose();
    _vehicleModel.dispose();
    _meter.dispose();
    _details.dispose();
    super.dispose();
  }

  List<String> _stepTitles(AppLocalizations l) => [
        l.stepApplicantDetails,
        l.stepServiceDetails,
        l.stepDocuments,
        l.stepReview,
      ];

  GovService? get _service => ServicesCatalog.byId(widget.serviceId);

  ServiceAction? get _action =>
      _service?.actions.where((item) => item.id == widget.actionId).firstOrNull;

  String _title(AppLocalizations l) {
    final key = _action?.titleKey;
    switch (key) {
      case 'actApplyId': return l.actApplyId;
      case 'actRenewId': return l.actRenewId;
      case 'actNewPassport': return l.actNewPassport;
      case 'actRenewPassport': return l.actRenewPassport;
      case 'actNewLicense': return l.actNewLicense;
      case 'actRenewLicense': return l.actRenewLicense;
      case 'actVehicleReg': return l.actVehicleReg;
      case 'actOwnershipTransfer': return l.actOwnershipTransfer;
      default: return l.servicesTitle;
    }
  }

  bool _validateStep() {
    if (!_formKeys[_step].currentState!.validate()) return false;
    if (_step == 2 && !_acknowledgedDocuments) {
      setState(() => _error = 'يرجى تأكيد جاهزية المستندات المطلوبة قبل المتابعة.');
      return false;
    }
    setState(() => _error = null);
    return true;
  }

  void _next() {
    FocusScope.of(context).unfocus();
    if (!_validateStep()) return;
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step > 0) setState(() => _step--);
  }

  Map<String, dynamic> _formData() => {
        'action': widget.actionId,
        'applicant': {
          'full_name': _name.text.trim(),
          'national_number': _nationalNumber.text.trim(),
          'phone': _phone.text.trim(),
        },
        'location': {
          'directorate': _district,
          'address': _address.text.trim(),
        },
        'service_details': {
          'document_number': _documentNumber.text.trim(),
          'plate_number': _plate.text.trim(),
          'vehicle_model': _vehicleModel.text.trim(),
          'meter_number': _meter.text.trim(),
          'details': _details.text.trim(),
        },
        'documents_acknowledged': _acknowledgedDocuments,
      };

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await _repository.submitRequest(
        serviceId: widget.serviceId,
        formData: _formData(),
        notes: _details.text.trim().isEmpty ? null : _details.text.trim(),
      );
      if (!mounted) return;
      setState(() => _submitting = false);
      _showSuccess(result['reference_no'].toString());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = 'تعذر إرسال الطلب حالياً. تحقق من الاتصال وحاول مرة أخرى.';
      });
    }
  }

  void _showSuccess(String reference) {
    final l = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
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
            const CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.primarySoft,
              child: Icon(Icons.check_rounded, color: AppColors.primary, size: 52),
            ),
            const SizedBox(height: 20),
            Text(l.requestSubmitted, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              l.requestSubmittedDesc(reference),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  context.pushReplacement('/services/${widget.serviceId}/track/${widget.actionId}?ref=$reference');
                },
                icon: const Icon(Icons.track_changes_rounded),
                label: Text(l.track),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
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
    final service = _service;
    final color = service?.color ?? AppColors.primary;
    final title = _title(l);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          if (service != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              color: color.withValues(alpha: 0.07),
              child: Row(
                children: [
                  Icon(_action?.icon ?? service.icon, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_serviceTitle(l, service)} • $title',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: color, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          AppStepperHeader(currentStep: _step, totalSteps: 4, stepTitles: _stepTitles(l), primaryColor: color),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Form(key: _formKeys[_step], child: _buildStep(_step, l, color)),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(_error!, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.danger, fontWeight: FontWeight.w700)),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  if (_step > 0) Expanded(child: OutlinedButton(onPressed: _submitting ? null : _back, child: const Text('السابق'))),
                  if (_step > 0) const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _submitting ? null : _next,
                      child: _submitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                          : Text(_step == 3 ? 'إرسال الطلب' : 'متابعة'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _serviceTitle(AppLocalizations l, GovService service) {
    switch (service.titleKey) {
      case 'svcNationalId': return l.svcNationalId;
      case 'svcPassport': return l.svcPassport;
      case 'svcDrivingLicense': return l.svcDrivingLicense;
      case 'svcVehicle': return l.svcVehicle;
      case 'svcMunicipality': return l.svcMunicipality;
      case 'svcUtilities': return l.svcUtilities;
      default: return l.servicesTitle;
    }
  }

  Widget _buildStep(int step, AppLocalizations l, Color color) {
    switch (step) {
      case 0: return _buildApplicantStep(l);
      case 1: return _buildDetailsStep(l, color);
      case 2: return _buildDocumentsStep(color);
      default: return _buildReviewStep(l, color);
    }
  }

  Widget _buildApplicantStep(AppLocalizations l) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'بيانات مقدم الطلب', subtitle: 'تُستخدم لإتمام الطلب والتواصل الرسمي.'),
          const SizedBox(height: 16),
          _label(l.fullName),
          TextFormField(controller: _name, textInputAction: TextInputAction.next, decoration: InputDecoration(hintText: l.fullName, prefixIcon: const Icon(Icons.person_outline_rounded)), validator: (v) => v == null || v.trim().length < 3 ? l.fieldRequired : null),
          const SizedBox(height: 14),
          _label(l.nationalNumber),
          TextFormField(controller: _nationalNumber, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: InputDecoration(hintText: l.nationalNumber, prefixIcon: const Icon(Icons.badge_outlined)), validator: (v) => v == null || v.trim().length < 6 ? l.fieldRequired : null),
          const SizedBox(height: 14),
          _label(l.phoneNumber),
          TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: InputDecoration(hintText: l.phoneHint, prefixIcon: const Icon(Icons.phone_outlined)), validator: (v) => v == null || v.trim().length < 9 ? l.fieldRequired : null),
        ],
      );

  Widget _buildDetailsStep(AppLocalizations l, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'تفاصيل الخدمة', subtitle: 'أدخل المعلومات المرتبطة بالخدمة المطلوبة.'),
          const SizedBox(height: 16),
          _label(l.districtLabel),
          DropdownButtonFormField<String>(value: _district, decoration: InputDecoration(prefixIcon: Icon(Icons.location_on_outlined, color: color)), items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(), onChanged: (value) => setState(() => _district = value ?? _district)),
          const SizedBox(height: 14),
          _label('العنوان'),
          TextFormField(controller: _address, maxLines: 2, decoration: const InputDecoration(hintText: 'الحي، الشارع، وأقرب معلم')),
          const SizedBox(height: 14),
          if (widget.serviceId == 'passport' || widget.serviceId == 'national_id') ...[
            _label('رقم الوثيقة السابقة (إن وجد)'),
            TextFormField(controller: _documentNumber, decoration: const InputDecoration(prefixIcon: Icon(Icons.description_outlined))),
            const SizedBox(height: 14),
          ],
          if (widget.serviceId == 'vehicle') ...[
            _label('رقم اللوحة'),
            TextFormField(controller: _plate, decoration: const InputDecoration(prefixIcon: Icon(Icons.pin_outlined))),
            const SizedBox(height: 14),
            _label('طراز المركبة'),
            TextFormField(controller: _vehicleModel, decoration: const InputDecoration(prefixIcon: Icon(Icons.directions_car_outlined))),
            const SizedBox(height: 14),
          ],
          if (widget.serviceId == 'utilities') ...[
            _label('رقم العداد / الحساب'),
            TextFormField(controller: _meter, decoration: const InputDecoration(prefixIcon: Icon(Icons.speed_outlined))),
            const SizedBox(height: 14),
          ],
          _label(l.additionalNotes),
          TextFormField(controller: _details, maxLines: 4, decoration: InputDecoration(hintText: l.additionalNotesHint)),
        ],
      );

  Widget _buildDocumentsStep(Color color) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.folder_open_rounded, color: color, size: 34),
            const SizedBox(height: 12),
            Text('المستندات المطلوبة', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('ستختلف المستندات النهائية حسب الجهة الحكومية. لا نعرض للمستخدم أن ملفاً رُفع ما لم يتم حفظه فعلياً في النظام.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 18),
            CheckboxListTile(
              value: _acknowledgedDocuments,
              onChanged: (value) => setState(() => _acknowledgedDocuments = value ?? false),
              contentPadding: EdgeInsets.zero,
              title: const Text('أؤكد أنني أستطيع تقديم المستندات الرسمية المطلوبة عند الطلب.'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      );

  Widget _buildReviewStep(AppLocalizations l, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'مراجعة الطلب', subtitle: 'تحقق من البيانات قبل الإرسال إلى الجهة الحكومية.'),
          const SizedBox(height: 14),
          _ReviewCard(title: 'مقدم الطلب', rows: {'الاسم': _name.text, 'الرقم الوطني': _nationalNumber.text, 'الهاتف': _phone.text}, color: color),
          const SizedBox(height: 12),
          _ReviewCard(title: 'الخدمة', rows: {'الخدمة': _title(l), 'المديرية': _district, 'العنوان': _address.text.isEmpty ? 'غير محدد' : _address.text}, color: color),
          const SizedBox(height: 12),
          _ReviewCard(title: 'بيانات إضافية', rows: {'رقم الوثيقة': _documentNumber.text.isEmpty ? '—' : _documentNumber.text, 'اللوحة': _plate.text.isEmpty ? '—' : _plate.text, 'العداد': _meter.text.isEmpty ? '—' : _meter.text}, color: color),
        ],
      );

  Widget _label(String text) => Padding(padding: const EdgeInsets.only(bottom: 7), child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)));
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.title, required this.rows, required this.color});
  final String title;
  final Map<String, String> rows;
  final Color color;

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 10),
            for (final entry in rows.entries) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 110, child: Text(entry.key, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entry.value.isEmpty ? '—' : entry.value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700))),
                ],
              ),
              if (entry.key != rows.keys.last) const Divider(height: 18),
            ],
          ],
        ),
      );
}
