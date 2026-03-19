import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/design_system.dart';
import 'submit_button.dart';

class DatePickerSheet extends StatefulWidget {
  final DateTime initialDate;

  const DatePickerSheet({super.key, required this.initialDate});

  @override
  State<DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<DatePickerSheet> {
  late int selectedYear;
  late int selectedMonth;
  late int selectedDay;

  final List<int> years = List.generate(56, (i) => 1980 + i); // 1980-2035
  final List<int> months = List.generate(12, (i) => i + 1);

  late final FixedExtentScrollController _yearController;
  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _dayController;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
    selectedDay = widget.initialDate.day;

    _yearController = FixedExtentScrollController(
      initialItem: years.indexOf(selectedYear),
    );
    _monthController = FixedExtentScrollController(
      initialItem: months.indexOf(selectedMonth),
    );
    _dayController = FixedExtentScrollController(
      initialItem: selectedDay - 1,
    );
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  List<int> get days {
    final daysInMonth = DateTime(selectedYear, selectedMonth + 1, 0).day;
    return List.generate(daysInMonth, (i) => i + 1);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: 310 + bottomInset,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              children: [
                _buildPicker(years, _yearController, (value) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    selectedYear = value;
                    final maxDay = days.length;
                    if (selectedDay > maxDay) {
                      selectedDay = maxDay;
                      _dayController.jumpToItem(selectedDay - 1);
                    }
                  });
                }, '년'),
                _buildPicker(months, _monthController, (value) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    selectedMonth = value;
                    final maxDay = days.length;
                    if (selectedDay > maxDay) {
                      selectedDay = maxDay;
                      _dayController.jumpToItem(selectedDay - 1);
                    }
                  });
                }, '월'),
                _buildPicker(days, _dayController, (value) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    selectedDay = value;
                  });
                }, '일'),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 30 + bottomInset),
            child: SubmitButton(
              text: '확인',
              onPressed: () {
                Navigator.pop(
                  context,
                  DateTime(selectedYear, selectedMonth, selectedDay),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPicker(
    List<int> items,
    FixedExtentScrollController controller,
    ValueChanged<int> onChanged,
    String suffix,
  ) {
    return Expanded(
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 40,
        onSelectedItemChanged: (index) => onChanged(items[index]),
        children: items.map((item) {
          return Center(
            child: Text(
              '$item$suffix',
              style: pretendard(weight: 500, size: 23),
            ),
          );
        }).toList(),
      ),
    );
  }
}
