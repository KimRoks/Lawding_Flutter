import 'package:flutter/material.dart';

import '../../../domain/entities/company_holiday_type.dart';
import '../../../domain/entities/help_content.dart';
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

class CompanyHolidaysAddScreen extends StatefulWidget {
  const CompanyHolidaysAddScreen({super.key});

  @override
  State<CompanyHolidaysAddScreen> createState() =>
      _CompanyHolidaysAddScreenState();
}

class _CompanyHolidaysAddScreenState extends State<CompanyHolidaysAddScreen> {
  CompanyHolidayType? selectedType;
  DateTime? selectedDate;

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          DatePickerSheet(initialDate: selectedDate ?? DateTime.now()),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _handleAddHoliday() {
    if (selectedType == null || selectedDate == null) {
      return;
    }

    final data = {
      'date': DateFormatter.toApiFormat(selectedDate!),
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
                          '공휴일 외 회사휴일',
                          style: pretendard(weight: 700, size: 20),
                        ),
                        const SizedBox(width: 8),
                        HelpButton(
                          onTap: () {
                            QuickHelpSheet.show(
                              context,
                              kind: QuickHelpKind.companyHolidays,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    const BadgeLabel(
                      text: '회사휴일은 최대 3개까지 입력 가능',
                      isRequired: false,
                    ),
                    const SizedBox(height: 18),
                    _buildReasonRow(),
                    const SizedBox(height: 12),
                    _buildDateRow(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SubmitButton(text: '추가하기', onPressed: _handleAddHoliday),
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
        CustomDropdownButton<CompanyHolidayType>(
          selectedValue: selectedType?.displayName,
          items: CompanyHolidayType.values,
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

  Widget _buildDateRow() {
    return Row(
      children: [
        Text('날짜', style: pretendard(weight: 700, size: 15)),
        const Spacer(),
        DateButton(
          placeholder: 'YYYY.MM.DD',
          selectedDate: selectedDate,
          onTap: () => _showDatePicker(context),
        ),
      ],
    );
  }
}
