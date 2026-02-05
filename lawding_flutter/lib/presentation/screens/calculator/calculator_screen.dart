import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/help_content.dart';
import '../../core/design_system.dart';
import '../../widgets/calculator/calculation_type_card.dart';
import '../../widgets/calculator/period_list_card.dart';
import '../../widgets/common/custom_scaffold.dart';
import '../../widgets/common/date_picker_sheet.dart';
import '../../widgets/common/quick_help_sheet.dart';
import '../../widgets/common/submit_button.dart';
import '../../widgets/common/terms_agreement_text.dart';
import '../company_holidays/company_holidays_add_screen.dart';
import '../result/result_screen.dart';
import '../special_period/special_period_add_screen.dart';
import '../webview/webview_screen.dart';
import 'calculator_view_model.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(calculatorViewModelProvider.notifier);
    final state = ref.watch(calculatorViewModelProvider);

    return CustomScaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CalculationTypeCard(
              selectedTypeIndex: state.calculationType.code == 1 ? 0 : 1,
              onTypeChanged: viewModel.setCalculationType,
              hireDate: state.hireDate,
              referenceDate: state.referenceDate,
              fiscalYearStartMonth: state.fiscalYearStartMonth,
              onFiscalYearStartMonthChanged: viewModel.setFiscalYearStartMonth,
              onHireDateTap: () => _showDatePicker(
                context,
                state.hireDate,
                viewModel.setHireDate,
              ),
              onReferenceDateTap: () => _showDatePicker(
                context,
                state.referenceDate,
                viewModel.setReferenceDate,
              ),
              onHelpTap: () {
                QuickHelpSheet.show(
                  context,
                  kind: QuickHelpKind.calculationType,
                );
              },
            ),
            const SizedBox(height: 20),
            PeriodListCard(
              title: '특이 사항이 있는 기간',
              items: state.nonWorkingPeriods
                  .map(
                    (p) => PeriodItem(
                      title: p.displayName,
                      duration: DateFormatter.toPeriodFormat(
                        p.startDate,
                        p.endDate,
                      ),
                    ),
                  )
                  .toList(),
              onAddTap: () async {
                final canAddError = viewModel.canAddNonWorkingPeriod();
                if (canAddError != null) {
                  UiHelpers.showSnackBar(context, canAddError);
                  return;
                }

                final result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SpecialPeriodAddScreen(),
                  ),
                );

                if (result != null && context.mounted) {
                  final error = viewModel.addNonWorkingPeriodFromMap(result);
                  if (error != null && context.mounted) {
                    UiHelpers.showSnackBar(context, error);
                  }
                }
              },
              onDeleteItem: viewModel.removeNonWorkingPeriod,
              onHelpTap: () {
                QuickHelpSheet.show(context, kind: QuickHelpKind.detailPeriods);
              },
            ),
            const SizedBox(height: 20),
            PeriodListCard(
              title: '공휴일 외 회사휴일',
              items: state.companyHolidays
                  .map(
                    (holiday) => PeriodItem(
                      title: holiday.displayName,
                      duration: DateFormatter.toDisplayFormat(holiday.date),
                    ),
                  )
                  .toList(),
              onAddTap: () async {
                final canAddError = viewModel.canAddCompanyHoliday();
                if (canAddError != null) {
                  UiHelpers.showSnackBar(context, canAddError);
                  return;
                }

                final result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompanyHolidaysAddScreen(),
                  ),
                );

                if (result != null && context.mounted) {
                  final error = viewModel.addCompanyHolidayFromMap(result);
                  if (error != null && context.mounted) {
                    UiHelpers.showSnackBar(context, error);
                  }
                }
              },
              onDeleteItem: viewModel.removeCompanyHoliday,
              onHelpTap: () {
                QuickHelpSheet.show(
                  context,
                  kind: QuickHelpKind.companyHolidays,
                );
              },
            ),
            const SizedBox(height: 20),
            TermsAgreementText(
              onTermsTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WebViewScreen(
                      url:
                          'https://maze-palladium-edf.notion.site/Lawding-273c4b24d2e2805f99f5f0eba1645a96?source=copy_link',
                      title: '이용약관',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            SubmitButton(
              text: '계산하기',
              isLoading: state.isLoading,
              onPressed: () async {
                final validationError = viewModel.validateCalculation();
                if (validationError != null) {
                  UiHelpers.showSnackBar(context, validationError);
                  return;
                }

                await viewModel.calculate();

                if (!context.mounted) return;

                final updatedState = ref.read(calculatorViewModelProvider);
                final result = updatedState.result;
                final error = updatedState.error;

                if (result != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(result: result),
                    ),
                  );
                } else if (error != null) {
                  UiHelpers.showSnackBar(context, error);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          DatePickerSheet(initialDate: initialDate ?? DateTime.now()),
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}
