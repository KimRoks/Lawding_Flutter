import 'package:flutter/material.dart';

import '../../../domain/entities/help_content.dart';
import '../../../domain/entities/non_working_type.dart';
import '../../core/design_system.dart';
import '../../widgets/common/badge_label.dart';
import '../../widgets/common/card_container.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/custom_scaffold.dart';
import '../../widgets/common/date_button.dart';
import '../../widgets/common/date_picker_sheet.dart';
import '../../widgets/common/dropdown_button.dart';
import '../../widgets/common/help_button.dart';
import '../../widgets/common/quick_help_sheet.dart';
import '../../widgets/common/submit_button.dart';

class SpecialPeriodAddScreen extends StatefulWidget {
  const SpecialPeriodAddScreen({super.key});

  @override
  State<SpecialPeriodAddScreen> createState() => _SpecialPeriodAddScreenState();
}

class _SpecialPeriodAddScreenState extends State<SpecialPeriodAddScreen> {
  NonWorkingType? selectedType;
  DateTime? startDate;
  DateTime? endDate;

  Future<void> _showDatePicker(BuildContext context, bool isStartDate) async {
    final currentDate = isStartDate ? startDate : endDate;
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          DatePickerSheet(initialDate: currentDate ?? DateTime.now()),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _handleAddPeriod() {
    if (selectedType == null || startDate == null || endDate == null) {
      return;
    }

    final data = {
      'type': selectedType!.serverCode,
      'startDate': DateFormatter.toApiFormat(startDate!),
      'endDate': DateFormatter.toApiFormat(endDate!),
      'displayName': selectedType!.displayName,
    };

    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: '선택사항'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '특이 사항이 있는 기간',
                          style: pretendard(weight: 700, size: 20),
                        ),
                        const SizedBox(width: 8),
                        HelpButton(
                          onTap: () {
                            QuickHelpSheet.show(
                              context,
                              kind: QuickHelpKind.detailPeriods,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const BadgeLabel(
                      text: '특이 사항은 최대 3개까지 입력 가능',
                      isRequired: false,
                    ),
                    const SizedBox(height: 18),
                    _buildReasonRow(),
                    const SizedBox(height: 12),
                    _buildDateRow('시작일', startDate, true),
                    const SizedBox(height: 12),
                    _buildDateRow('종료일', endDate, false),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SubmitButton(text: '추가하기', onPressed: _handleAddPeriod),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonRow() {
    return Row(
      children: [
        Text('사유', style: pretendard(weight: 700, size: 15)),
        const Spacer(),
        CustomDropdownButton<NonWorkingType>(
          selectedValue: selectedType?.displayName,
          items: NonWorkingType.values,
          itemBuilder: (type) => type.displayName,
          onChanged: (type) {
            setState(() {
              selectedType = type;
            });
          },
          placeholder: '선택',
        ),
      ],
    );
  }

  Widget _buildDateRow(String label, DateTime? date, bool isStartDate) {
    return Row(
      children: [
        Text(label, style: pretendard(weight: 700, size: 15)),
        const Spacer(),
        DateButton(
          placeholder: 'YYYY.MM.DD',
          selectedDate: date,
          onTap: () => _showDatePicker(context, isStartDate),
        ),
      ],
    );
  }
}
