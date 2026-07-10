import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/core/result.dart';
import '../../../domain/entities/leave_policy_request.dart';
import '../../core/design_system.dart';
import '../../providers/providers.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'steps/step1_name_terms.dart';
import 'steps/step2_leave_standard.dart';
import 'steps/step3_work_schedule.dart';
import 'steps/step4_worker_count.dart';
import 'steps/step5_annual_leave_result.dart';
import 'steps/step6_used_leave.dart';

class BasicInfoScreen extends ConsumerStatefulWidget {
  final VoidCallback onCompleted;
  final bool isEditMode; // true: PUT(수정), false: POST(최초 등록)

  const BasicInfoScreen({
    super.key,
    required this.onCompleted,
    this.isEditMode = false,
  });

  @override
  ConsumerState<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends ConsumerState<BasicInfoScreen> {
  final _pageController = PageController();
  final _stepValidity = <int, bool>{};
  int _currentStep = 0;
  bool _canProceed = false;
  bool _isSubmitting = false;

  // 각 step에서 수집한 데이터
  Step1Data? _step1Data;
  Step2Data? _step2Data;
  Step3Data? _step3Data;
  int? _companySize;
  double? _totalDays;
  double? _usedLeave;

  static const int _totalSteps = 6;

  static const _dayNames = {
    1: 'MONDAY',
    2: 'TUESDAY',
    3: 'WEDNESDAY',
    4: 'THURSDAY',
    5: 'FRIDAY',
    6: 'SATURDAY',
    7: 'SUNDAY',
  };

  void _setStepValid(int stepIndex, bool valid) {
    _stepValidity[stepIndex] = valid;
    if (_currentStep == stepIndex && _canProceed != valid) {
      setState(() => _canProceed = valid);
    }
  }

  void _onStep2DataChanged(Step2Data data) {
    setState(() => _step2Data = data);
  }

  void _onTotalDaysChanged(double? days) {
    setState(() => _totalDays = days);
  }

  Future<void> _onNext() async {
    if (!_canProceed || _isSubmitting) return;
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _submitLeavePolicy();
    }
  }

  Future<void> _submitLeavePolicy() async {
    final request = _buildRequest();
    if (request == null) return;

    setState(() => _isSubmitting = true);

    final result = widget.isEditMode
        ? await ref.read(updateLeavePolicyUseCaseProvider).execute(request)
        : await ref.read(submitLeavePolicyUseCaseProvider).execute(request);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        widget.onCompleted();
      case Failure(:final error):
        debugPrint('[LeavePolicySubmit] 실패: $error');
    }
  }

  LeavePolicyRequest? _buildRequest() {
    final s1 = _step1Data;
    final s2 = _step2Data;
    final s3 = _step3Data;
    final size = _companySize;
    final total = _totalDays;
    final used = _usedLeave;

    if (s1 == null ||
        s2 == null ||
        s3 == null ||
        size == null ||
        total == null ||
        used == null) {
      debugPrint('[LeavePolicyRequest] 데이터 누락 — 요청 생성 불가');
      return null;
    }

    String fmtTime(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    String fmtDate(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final workPattern = {
      for (final day in s3.workStarts.keys)
        _dayNames[day]!: WorkTimeSlot(
          start: fmtTime(s3.workStarts[day]!),
          end: fmtTime(s3.workEnds[day]!),
        ),
    };

    final breakTimePattern = {
      for (final day in s3.breakStarts.keys)
        _dayNames[day]!: WorkTimeSlot(
          start: fmtTime(s3.breakStarts[day]!),
          end: fmtTime(s3.breakEnds[day]!),
        ),
    };

    final request = LeavePolicyRequest(
      nickname: s1.nickname,
      acceptedTerms: s1.acceptedTerms,
      leaveAccrualBasis: s2.standard == LeaveStandard.hireDate ? 1 : 2,
      fiscalYearBaseMonth: s2.fiscalMonth != null
          ? int.parse(s2.fiscalMonth!)
          : null,
      hireDate: fmtDate(s2.hireDate),
      workPattern: workPattern,
      breakTimePattern: breakTimePattern,
      companySize: size,
      totalLeave: total,
      usedLeave: used,
    );

    debugPrint('--- [LeavePolicyRequest] ---');
    debugPrint(const JsonEncoder.withIndent('  ').convert(request.toJson()));
    debugPrint('----------------------------');

    return request;
  }

  void _onBack() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(title: '기본 정보 입력', onBack: _onBack),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() {
                  _currentStep = i;
                  _canProceed = _stepValidity[i] ?? false;
                }),
                children: [
                  Step1NameTerms(
                    onValidChanged: (v) => _setStepValid(0, v),
                    onDataChanged: (d) => setState(() => _step1Data = d),
                  ),
                  Step2LeaveStandard(
                    onValidChanged: (v) => _setStepValid(1, v),
                    onDataChanged: _onStep2DataChanged,
                  ),
                  Step3WorkSchedule(
                    onValidChanged: (v) => _setStepValid(2, v),
                    onDataChanged: (d) => setState(() => _step3Data = d),
                  ),
                  Step4WorkerCount(
                    onValidChanged: (v) => _setStepValid(3, v),
                    onDataChanged: (v) => setState(() => _companySize = v),
                  ),
                  Step5AnnualLeaveResult(
                    onValidChanged: (v) => _setStepValid(4, v),
                    step2Data: _step2Data,
                    onResultChanged: _onTotalDaysChanged,
                  ),
                  Step6UsedLeave(
                    onValidChanged: (v) => _setStepValid(5, v),
                    onDataChanged: (v) => setState(() => _usedLeave = v),
                    totalDays: _totalDays,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: _buildNextButton(),
            ),
          ],
          ),
      ),
    );
  }


  Widget _buildProgressBar() {
    const segmentWidth = 29.42;
    const segmentGap = 5.15;
    const totalWidth = 6 * segmentWidth + 5 * segmentGap;

    return Center(
      child: SizedBox(
        width: totalWidth,
        height: 4,
        child: Row(
          children: List.generate(6, (i) {
            return Padding(
              padding: EdgeInsets.only(right: i < 5 ? segmentGap : 0),
              child: Container(
                width: segmentWidth,
                height: 4,
                decoration: BoxDecoration(
                  color: i <= _currentStep
                      ? AppColors.brandColor
                      : const Color(0xFFE1E1E1),
                  borderRadius: BorderRadius.circular(27),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: (_canProceed && !_isSubmitting) ? _onNext : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 48,
        decoration: BoxDecoration(
          color: (_canProceed && !_isSubmitting)
              ? AppColors.brandColor
              : const Color(0xFFBEC1C8),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          style: pretendard(
            weight: 700,
            size: 15,
            color: Colors.white.withValues(
              alpha: (_canProceed && !_isSubmitting) ? 1.0 : 0.7,
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(_currentStep == _totalSteps - 1 ? '시작하기' : '다음'),
        ),
      ),
    );
  }
}
