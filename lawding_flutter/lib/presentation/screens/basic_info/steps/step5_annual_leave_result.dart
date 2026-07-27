import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/network/network_error.dart';
import '../../../../domain/core/result.dart';
import '../../../../domain/entities/annual_leave.dart';
import '../../../../domain/repositories/annual_leave_repository.dart';
import '../../../core/design_system.dart';
import '../../../providers/providers.dart';
import '../manual_entry_screen.dart';
import 'step2_leave_standard.dart';

class Step5AnnualLeaveResult extends ConsumerStatefulWidget {
  final void Function(bool) onValidChanged;
  final Step2Data? step2Data;
  final void Function(double?)? onResultChanged;

  const Step5AnnualLeaveResult({
    super.key,
    required this.onValidChanged,
    this.step2Data,
    this.onResultChanged,
  });

  @override
  ConsumerState<Step5AnnualLeaveResult> createState() =>
      _Step5AnnualLeaveResultState();
}

class _Step5AnnualLeaveResultState extends ConsumerState<Step5AnnualLeaveResult>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isLoading = false;
  AnnualLeave? _result;
  String? _error;
  ManualEntryResult? _manualResult;

  @override
  void initState() {
    super.initState();
    if (widget.step2Data != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _calculate());
    }
  }

  @override
  void didUpdateWidget(Step5AnnualLeaveResult oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.step2Data != oldWidget.step2Data && widget.step2Data != null) {
      _calculate();
    }
  }

  Future<void> _calculate() async {
    final data = widget.step2Data;
    if (data == null) return;

    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });
    widget.onValidChanged(false);

    final useCase = ref.read(calculateAnnualLeaveUseCaseProvider);
    final calculationType = data.standard == LeaveStandard.hireDate
        ? CalculationType.standard
        : CalculationType.proRated;

    final now = DateTime.now();
    final fiscalYear = data.fiscalMonth != null
        ? DateFormatter.toMonthDayFormat(int.parse(data.fiscalMonth!))
        : null;

    final result = await useCase.execute(
      calculationType: calculationType,
      hireDate: data.hireDate,
      referenceDate: now,
      fiscalYear: fiscalYear,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      switch (result) {
        case Success(:final value):
          _result = value;
        case Failure(:final error):
          _error = _errorMessage(error);
      }
    });
    widget.onValidChanged(_result != null);
    widget.onResultChanged?.call(_result?.totalDays);
  }

  String _errorMessage(NetworkError error) {
    return switch (error) {
      ServerError(:final message) => message,
      NetworkConnectionError() => '인터넷 연결을 확인해주세요',
      TimeoutError() => '요청 시간이 초과되었습니다',
      _ => '계산 중 오류가 발생했습니다',
    };
  }

  static String _formatDays(double days) {
    if (days % 1 == 0) return '${days.toInt()}일';
    final s = days.toStringAsFixed(3).replaceAll(RegExp(r'0+$'), '');
    return '$s일';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 45),
          Text(
            '이번 연차발생 시기에 내가\n사용할 수 있는 총 연차',
            textAlign: TextAlign.center,
            style: pretendard(
              weight: 700,
              size: 24,
              color: AppColors.brandColor,
            ),
          ),
          Expanded(child: Center(child: _buildCircle())),
          Text(
            '내가 알고있거나, 인사팀에서 안내한 바와 다른가요?',
            textAlign: TextAlign.center,
            style: pretendard(
              weight: 600,
              size: 14,
              color: AppColors.brandColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildManualEntryButton(),
        ],
      ),
    );
  }

  Widget _buildCircle() {
    return Container(
      width: 195,
      height: 195,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(-0.6, -0.8),
          end: Alignment(0.6, 0.8),
          colors: [Color(0xFF0173D6), Color(0xFFCFE6FF)],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Center(
        child: Container(
          width: 187,
          height: 187,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          alignment: Alignment.center,
          child: _buildCircleContent(),
        ),
      ),
    );
  }

  Widget _buildCircleContent() {
    if (_manualResult != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _formatDays(_manualResult!.totalLeave),
            style: pretendard(weight: 700, size: 46, color: AppColors.brandColor),
          ),
        ),
      );
    }
    if (_isLoading) {
      return const CircularProgressIndicator();
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          _error!,
          textAlign: TextAlign.center,
          style: pretendard(
            weight: 600,
            size: 13,
            color: const Color(0xFFFF7B7B),
          ),
        ),
      );
    }
    if (_result != null) {
      return Text(
        _formatDays(_result!.totalDays),
        style: pretendard(weight: 700, size: 46, color: AppColors.brandColor),
      );
    }
    // step2Data가 아직 없는 초기 상태
    return Text(
      '--',
      style: pretendard(weight: 700, size: 46, color: const Color(0xFFBEC1C8)),
    );
  }

  Widget _buildManualEntryButton() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push<ManualEntryResult>(
          MaterialPageRoute(builder: (_) => const ManualEntryScreen()),
        );
        if (result != null && mounted) {
          setState(() => _manualResult = result);
          widget.onValidChanged(true);
          widget.onResultChanged?.call(result.totalLeave);
        }
      },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.brandColor, width: 2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          '수동으로 입력하기',
          style: pretendard(weight: 700, size: 15, color: AppColors.brandColor),
        ),
      ),
    );
  }
}
