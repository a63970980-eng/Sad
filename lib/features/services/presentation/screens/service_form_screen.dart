import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/l10n_lookup.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/services_catalog.dart';

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
  int _currentStep = 0;
  bool _submitting = false;

  // Form keys per step for validation
  final List<GlobalKey<FormState>> _formKeys = List.generate(6, (_) => GlobalKey<FormState>());

  // Field Controllers - Personal Info
  final _nameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();

  // Field Controllers - Specific Service Info
  final _districtController = TextEditingController(text: 'صيرة (كريتر)');
  final _addressController = TextEditingController();

  // Vehicle / Passport / Specific fields
  final _prevDocNumberController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _meterNumberController = TextEditingController();
  final _additionalDetailsController = TextEditingController();

  // File/Document attachment simulation flags
  bool _doc1Attached = false;
  bool _doc2Attached = false;

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

  @override
  void dispose() {
    _nameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _districtController.dispose();
    _addressController.dispose();
    _prevDocNumberController.dispose();
    _plateNumberController.dispose();
    _vehicleModelController.dispose();
    _meterNumberController.dispose();
    _additionalDetailsController.dispose();
    super.dispose();
  }

  List<String> _getStepTitles(AppLocalizations l) {
    switch (widget.serviceId) {
      case 'national_id':
        return [
          l.stepApplicantDetails,
          'بيانات السجل المدني',
          l.stepDocuments,
          l.stepReview,
        ];
      case 'passport':
        return [
          l.stepApplicantDetails,
          'بيانات الجواز والسفر',
          'بيانات الإقامة والتواصل',
          l.stepDocuments,
          l.stepReview,
        ];
      case 'driving_license':
        return [
          l.stepApplicantDetails,
          'الفحص الطبي والفئة',
          l.stepDocuments,
          l.stepReview,
        ];
      case 'vehicle':
        if (widget.actionId == 'ownership_transfer') {
          return [
            'بيانات المالك الجديد',
            'بيانات البائع والمركبة',
            'تفاصيل نقل الملكية',
            l.stepDocuments,
            l.stepReview,
          ];
        }
        return [
          l.stepApplicantDetails,
          'بيانات المركبة',
          'بيانات التجديد والترخيص',
          l.stepDocuments,
          l.stepReview,
        ];
      case 'municipality':
        return [
          l.stepApplicantDetails,
          'بيانات العقار والنشاط',
          l.stepDocuments,
          l.stepReview,
        ];
      case 'utilities':
        return [
          l.stepApplicantDetails,
          'بيانات العداد والحساب',
          l.stepDocuments,
          l.stepReview,
        ];
      default:
        return [
          l.stepApplicantDetails,
          l.stepServiceDetails,
          l.stepDocuments,
          l.stepReview,
        ];
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep < _formKeys.length && _formKeys[_currentStep].currentState != null) {
      return _formKeys[_currentStep].currentState!.validate();
    }
    return true;
  }

  void _nextStep(int totalSteps) {
    if (!_validateCurrentStep()) return;
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

  Future<void> _submit() async {
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
              l.requestSubmitted,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              l.requestSubmittedDesc(reference),
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

    final stepTitles = _getStepTitles(l);
    final totalSteps = stepTitles.length;
    final serviceColor = service?.color ?? AppColors.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Banner for Service Title
          if (service != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: serviceColor.withValues(alpha: 0.06),
              child: Row(
                children: [
                  Icon(action?.icon ?? service.icon, color: serviceColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${tr(l, service.titleKey)} • $title',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: serviceColor,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Stepper Progress Bar
          AppStepperHeader(
            currentStep: _currentStep,
            totalSteps: totalSteps,
            stepTitles: stepTitles,
            primaryColor: serviceColor,
          ),

          // Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: IndexedStack(
                index: _currentStep,
                children: [
                  for (int i = 0; i < totalSteps; i++)
                    Form(
                      key: _formKeys[i],
                      child: _buildStepContent(i, totalSteps, l, serviceColor),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar (Previous / Next / Review & Submit)
          _buildBottomNavigationBar(totalSteps, l, serviceColor),
        ],
      ),
    );
  }

  Widget _buildStepContent(
    int stepIndex,
    int totalSteps,
    AppLocalizations l,
    Color color,
  ) {
    final isReviewStep = stepIndex == totalSteps - 1;

    if (isReviewStep) {
      return _buildReviewStep(l, color);
    }

    // Return custom step content depending on service and step index
    switch (widget.serviceId) {
      case 'national_id':
        return _buildNationalIdStep(stepIndex, l);
      case 'passport':
        return _buildPassportStep(stepIndex, l);
      case 'driving_license':
        return _buildDrivingLicenseStep(stepIndex, l);
      case 'vehicle':
        return _buildVehicleStep(stepIndex, l);
      case 'municipality':
        return _buildMunicipalityStep(stepIndex, l);
      case 'utilities':
        return _buildUtilitiesStep(stepIndex, l);
      default:
        return _buildGenericStep(stepIndex, l);
    }
  }

  // --- Step Content Builders ---

  Widget _buildNationalIdStep(int stepIndex, AppLocalizations l) {
    if (stepIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(l.fullName),
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(hintText: l.fullName),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.nationalNumber),
          TextFormField(
            controller: _nationalIdController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
                hintText: widget.actionId == 'renew_id'
                    ? 'رقم الهوية الوطنية القائمة'
                    : l.nationalNumber),
            validator: (v) =>
                (v == null || v.trim().length < 6) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.phoneNumber),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(hintText: l.phoneHint),
            validator: (v) =>
                (v == null || v.trim().length < 9) ? l.fieldRequired : null,
          ),
        ],
      );
    } else if (stepIndex == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(l.districtLabel),
          DropdownButtonFormField<String>(
            value: _districtController.text.isEmpty
                ? _adenDistricts.first
                : _districtController.text,
            items: _adenDistricts
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _districtController.text = val);
            },
            decoration: InputDecoration(hintText: l.selectDistrict),
          ),
          const SizedBox(height: 16),
          const _Label('مركز السجل المدني الفعلي في عدن'),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(
              hintText: 'مثال: مجمع السجل المدني - كريتر',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.additionalNotes),
          TextFormField(
            controller: _additionalDetailsController,
            maxLines: 3,
            decoration: InputDecoration(hintText: l.additionalNotesHint),
          ),
        ],
      );
    } else {
      return _buildDocumentsStep(l, [
        'شهادة الميلاد / الهوية السابقة',
        'صورة شخصية حديثة (خلفية بيضاء)',
      ]);
    }
  }

  Widget _buildPassportStep(int stepIndex, AppLocalizations l) {
    if (stepIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(l.fullName),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(hintText: l.fullName),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.nationalNumber),
          TextFormField(
            controller: _nationalIdController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(hintText: l.nationalNumber),
            validator: (v) =>
                (v == null || v.trim().length < 6) ? l.fieldRequired : null,
          ),
        ],
      );
    } else if (stepIndex == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.actionId == 'renew_passport') ...[
            const _Label('رقم الجواز السابق'),
            TextFormField(
              controller: _prevDocNumberController,
              decoration: const InputDecoration(hintText: 'أدخل رقم الجواز السابق'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
            ),
            const SizedBox(height: 16),
          ],
          const _Label('المهنة أو الصفة في الجواز'),
          TextFormField(
            controller: _additionalDetailsController,
            decoration: const InputDecoration(hintText: 'أدخل المهنة كما في الوثائق الرسمية'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
        ],
      );
    } else if (stepIndex == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(l.districtLabel),
          DropdownButtonFormField<String>(
            value: _districtController.text.isEmpty
                ? _adenDistricts.first
                : _districtController.text,
            items: _adenDistricts
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _districtController.text = val);
            },
          ),
          const SizedBox(height: 16),
          _Label(l.phoneNumber),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(hintText: l.phoneHint),
            validator: (v) =>
                (v == null || v.trim().length < 9) ? l.fieldRequired : null,
          ),
        ],
      );
    } else {
      return _buildDocumentsStep(l, [
        'نسخة من البطاقة الشخصية الإلكترونية',
        'صورة الجواز القديم / الصور الشخصية',
      ]);
    }
  }

  Widget _buildDrivingLicenseStep(int stepIndex, AppLocalizations l) {
    if (stepIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(l.fullName),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(hintText: l.fullName),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.nationalNumber),
          TextFormField(
            controller: _nationalIdController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: l.nationalNumber),
            validator: (v) =>
                (v == null || v.trim().length < 6) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.phoneNumber),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(hintText: l.phoneHint),
            validator: (v) =>
                (v == null || v.trim().length < 9) ? l.fieldRequired : null,
          ),
        ],
      );
    } else if (stepIndex == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(l.districtLabel),
          DropdownButtonFormField<String>(
            value: _districtController.text.isEmpty
                ? _adenDistricts.first
                : _districtController.text,
            items: _adenDistricts
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _districtController.text = val);
            },
          ),
          const SizedBox(height: 16),
          const _Label('فئة رخصة القيادة المطلوبة'),
          DropdownButtonFormField<String>(
            value: 'خصوصي',
            items: const [
              DropdownMenuItem(value: 'خصوصي', child: Text('خصوصي (سيارات صغيرة)')),
              DropdownMenuItem(value: 'عمومي', child: Text('عمومي (أجرة / نقل)')),
              DropdownMenuItem(value: 'دراجة', child: Text('دراجة نارية')),
            ],
            onChanged: (_) {},
          ),
          const SizedBox(height: 16),
          _Label(l.additionalNotes),
          TextFormField(
            controller: _additionalDetailsController,
            decoration: const InputDecoration(hintText: 'مركز التدريب أو تفاصيل الفحص الطبي'),
          ),
        ],
      );
    } else {
      return _buildDocumentsStep(l, [
        'تقرير الفحص الطبي للياقة السائق',
        'صورة البطاقة الشخصية وصور شخصية',
      ]);
    }
  }

  Widget _buildVehicleStep(int stepIndex, AppLocalizations l) {
    if (stepIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(widget.actionId == 'ownership_transfer' ? 'اسم المالك الجديد' : l.fullName),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(hintText: l.fullName),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.nationalNumber),
          TextFormField(
            controller: _nationalIdController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: l.nationalNumber),
            validator: (v) =>
                (v == null || v.trim().length < 6) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.phoneNumber),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(hintText: l.phoneHint),
            validator: (v) =>
                (v == null || v.trim().length < 9) ? l.fieldRequired : null,
          ),
        ],
      );
    } else if (stepIndex == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('رقم لوحة المركبة والقعدة'),
          TextFormField(
            controller: _plateNumberController,
            decoration: const InputDecoration(hintText: 'مثال: 12345 عدن / خصوصي'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          const _Label('نوع المركبة والموديل وسنة الصنع'),
          TextFormField(
            controller: _vehicleModelController,
            decoration: const InputDecoration(hintText: 'مثال: تويوتا كورولا 2018'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
        ],
      );
    } else if (stepIndex == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(l.districtLabel),
          DropdownButtonFormField<String>(
            value: _districtController.text.isEmpty
                ? _adenDistricts.first
                : _districtController.text,
            items: _adenDistricts
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _districtController.text = val);
            },
          ),
          const SizedBox(height: 16),
          const _Label('مركز الفحص والترخيص في عدن'),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(hintText: 'إدارة شرطة السير - المنصورة / المعلا'),
          ),
        ],
      );
    } else {
      return _buildDocumentsStep(l, [
        'وثيقة ملكية المركبة (الكرت الأصفر/الرمادي)',
        'عقد المبايعة أو كرت الفحص الدوري',
      ]);
    }
  }

  Widget _buildMunicipalityStep(int stepIndex, AppLocalizations l) {
    if (stepIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(l.fullName),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(hintText: l.fullName),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.nationalNumber),
          TextFormField(
            controller: _nationalIdController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: l.nationalNumber),
            validator: (v) =>
                (v == null || v.trim().length < 6) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.phoneNumber),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(hintText: l.phoneHint),
            validator: (v) =>
                (v == null || v.trim().length < 9) ? l.fieldRequired : null,
          ),
        ],
      );
    } else if (stepIndex == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(l.districtLabel),
          DropdownButtonFormField<String>(
            value: _districtController.text.isEmpty
                ? _adenDistricts.first
                : _districtController.text,
            items: _adenDistricts
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _districtController.text = val);
            },
          ),
          const SizedBox(height: 16),
          const _Label('اسم الشارع / الحي / المخطط'),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(hintText: 'أدخل تفاصيل الموقع والدليل الهندسي'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.additionalNotes),
          TextFormField(
            controller: _additionalDetailsController,
            maxLines: 2,
            decoration: InputDecoration(hintText: l.additionalNotesHint),
          ),
        ],
      );
    } else {
      return _buildDocumentsStep(l, [
        'عقد الملكية أو الإيجار الموثق',
        'المخطط الهندسي أو ترخيص النشاط السابقت',
      ]);
    }
  }

  Widget _buildUtilitiesStep(int stepIndex, AppLocalizations l) {
    if (stepIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(l.fullName),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(hintText: l.fullName),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.nationalNumber),
          TextFormField(
            controller: _nationalIdController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: l.nationalNumber),
            validator: (v) =>
                (v == null || v.trim().length < 6) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.phoneNumber),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(hintText: l.phoneHint),
            validator: (v) =>
                (v == null || v.trim().length < 9) ? l.fieldRequired : null,
          ),
        ],
      );
    } else if (stepIndex == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('رقم العداد / رقم الاشتراك الحسابي'),
          TextFormField(
            controller: _meterNumberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'أدخل رقم الحساب المكتوب في الفاتورة'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.districtLabel),
          DropdownButtonFormField<String>(
            value: _districtController.text.isEmpty
                ? _adenDistricts.first
                : _districtController.text,
            items: _adenDistricts
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _districtController.text = val);
            },
          ),
          const SizedBox(height: 16),
          const _Label('العنوان المترابط والمربع السكني'),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(hintText: 'اسم الشارع وقرب معلم بارز'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
        ],
      );
    } else {
      return _buildDocumentsStep(l, [
        'نسخة من آخر فاتورة مسددة',
        'صورة الهوية الوطنية وإثبات السكن',
      ]);
    }
  }

  Widget _buildGenericStep(int stepIndex, AppLocalizations l) {
    if (stepIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(l.fullName),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(hintText: l.fullName),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.nationalNumber),
          TextFormField(
            controller: _nationalIdController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: l.nationalNumber),
            validator: (v) =>
                (v == null || v.trim().length < 6) ? l.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          _Label(l.phoneNumber),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(hintText: l.phoneHint),
            validator: (v) =>
                (v == null || v.trim().length < 9) ? l.fieldRequired : null,
          ),
        ],
      );
    } else if (stepIndex == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(l.districtLabel),
          DropdownButtonFormField<String>(
            value: _districtController.text.isEmpty
                ? _adenDistricts.first
                : _districtController.text,
            items: _adenDistricts
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _districtController.text = val);
            },
          ),
          const SizedBox(height: 16),
          _Label(l.additionalNotes),
          TextFormField(
            controller: _additionalDetailsController,
            maxLines: 3,
            decoration: InputDecoration(hintText: l.additionalNotesHint),
          ),
        ],
      );
    } else {
      return _buildDocumentsStep(l, [
        'المستند الرسمي ذو الصلة بالطلب',
        'الهوية الوطنية / الإثبات الشخصي',
      ]);
    }
  }

  Widget _buildDocumentsStep(AppLocalizations l, List<String> requiredDocs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.stepDocuments,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 6),
        Text(
          l.documentNotice,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),
        _buildDocUploadTile(
          title: requiredDocs[0],
          isAttached: _doc1Attached,
          onToggle: () => setState(() => _doc1Attached = !_doc1Attached),
        ),
        const SizedBox(height: 14),
        if (requiredDocs.length > 1)
          _buildDocUploadTile(
            title: requiredDocs[1],
            isAttached: _doc2Attached,
            onToggle: () => setState(() => _doc2Attached = !_doc2Attached),
          ),
      ],
    );
  }

  Widget _buildDocUploadTile({
    required String title,
    required bool isAttached,
    required VoidCallback onToggle,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAttached
              ? AppColors.primary.withValues(alpha: 0.08)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAttached ? AppColors.primary : scheme.outline,
            width: isAttached ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isAttached
                    ? AppColors.primary
                    : scheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAttached ? Icons.check : Icons.upload_file_rounded,
                color: isAttached ? Colors.white : scheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isAttached ? AppColors.primary : scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isAttached ? 'تم إرفاق المستند بنجاح' : 'انقر لإرفاق الملف أو التقاط صورة',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep(AppLocalizations l, Color color) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مراجعة وتأكيد البيانات',
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'يرجى مراجعة تفاصيل طلبك بدقة قبل الإرسال النهائي للمؤسسة الخدمية في عدن.',
          style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        AppCard(
          borderColor: color.withValues(alpha: 0.3),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildReviewRow(l.fullName, _nameController.text.isNotEmpty ? _nameController.text : 'لم يُدخل'),
              const Divider(height: 20),
              _buildReviewRow(l.nationalNumber, _nationalIdController.text.isNotEmpty ? _nationalIdController.text : 'لم يُدخل'),
              const Divider(height: 20),
              _buildReviewRow(l.phoneNumber, _phoneController.text.isNotEmpty ? _phoneController.text : 'لم يُدخل'),
              const Divider(height: 20),
              _buildReviewRow(l.districtLabel, _districtController.text.isNotEmpty ? _districtController.text : 'عدن'),
              if (_addressController.text.isNotEmpty) ...[
                const Divider(height: 20),
                _buildReviewRow('العنوان/الموقع', _addressController.text),
              ],
              if (_plateNumberController.text.isNotEmpty) ...[
                const Divider(height: 20),
                _buildReviewRow('رقم اللوحة', _plateNumberController.text),
              ],
              if (_vehicleModelController.text.isNotEmpty) ...[
                const Divider(height: 20),
                _buildReviewRow('المركبة والموديل', _vehicleModelController.text),
              ],
              if (_meterNumberController.text.isNotEmpty) ...[
                const Divider(height: 20),
                _buildReviewRow('رقم العداد/الحساب', _meterNumberController.text),
              ],
              const Divider(height: 20),
              _buildReviewRow('حالة المرفقات', (_doc1Attached || _doc2Attached) ? 'تم إرفاق المستندات المطلوب' : 'بدون مرفقات إضافية'),
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

  Widget _buildBottomNavigationBar(int totalSteps, AppLocalizations l, Color color) {
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
                onPressed: _submitting ? null : _previousStep,
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(l.stepPrevious),
              ),
            ),
          if (!isFirstStep) const SizedBox(width: 12),
          Expanded(
            flex: isFirstStep ? 2 : 1,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: color,
              ),
              onPressed: _submitting ? null : () => _nextStep(totalSteps),
              icon: _submitting
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
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      );
}
