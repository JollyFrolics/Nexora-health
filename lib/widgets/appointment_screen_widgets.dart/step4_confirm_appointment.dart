import 'package:flutter/material.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/appointment_confirm_screen.dart';
import 'package:patient_app/widgets/appointment_screen_widgets.dart/slot_group.dart';

class Step4DateTime extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime? selectedDate;
  final Slot? selectedSlot;
  final Map<String, bool> availability;
  final bool loadingSlots;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateSelect;
  final ValueChanged<Slot> onSlotSelect;
  const Step4DateTime({super.key, 
    required this.focusedMonth,
    required this.selectedDate,
    required this.selectedSlot,
    required this.availability,
    required this.loadingSlots,
    required this.onMonthChanged,
    required this.onDateSelect,
    required this.onSlotSelect,
  });

  static const _dayLabels = [
    'आइत',
    'सोम',
    'मंगल',
    'बुध',
    'बिहि',
    'शुक्र',
    'शनि',
  ];
  static const _monthNames = [
    'जनवरी',
    'फेब्रुअरी',
    'मार्च',
    'अप्रिल',
    'मे',
    'जुन',
    'जुलाई',
    'अगस्ट',
    'सेप्टेम्बर',
    'अक्टोबर',
    'नोभेम्बर',
    'डिसेम्बर',
  ];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'मिति र समय छान्नुहोस्',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 14),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Month navigation
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: [
                    // NavBtn(
                    //   Icons.chevron_left_rounded,
                    //   () => onMonthChanged(
                    //     DateTime(focusedMonth.year, focusedMonth.month - 1),
                    //   ),
                    // ),
                    Expanded(
                      child: Text(
                        '${_monthNames[focusedMonth.month - 1]} ${focusedMonth.year}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    // NavBtn(
                    //   Icons.chevron_right_rounded,
                    //   () => onMonthChanged(
                    //     DateTime(focusedMonth.year, focusedMonth.month + 1),
                    //   ),
                    // ),
                  ],
                ),
              ),
              // Day labels row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: _dayLabels
                      .map(
                        (d) => Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              // Date grid
              _buildGrid(),
              const SizedBox(height: 12),
            ],
          ),
        ),
        const SizedBox(height: 18),

        if (selectedDate != null) ...[
          Row(
            children: [
              const Text(
                'समय छान्नुहोस्',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              if (!loadingSlots && availability.isNotEmpty)
                Text(
                  '${availability.values.where((v) => !v).length} उपलब्ध',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (loadingSlots)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: AppConstants.primaryColor,
                ),
              ),
            )
          else ...[
            SlotGroup(
              'बिहान / Morning',
              morningSlots,
              selectedSlot,
              availability,
              onSlotSelect,
            ),
            const SizedBox(height: 14),
            SlotGroup(
              'दिउँसो / Afternoon',
              afternoonSlots,
              selectedSlot,
              availability,
              onSlotSelect,
            ),
          ],
        ] else
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  color: AppConstants.primaryColor.withOpacity(0.4),
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  'पहिले मिति छान्नुहोस्',
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  Widget _buildGrid() {
    final today = DateTime.now();
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    // weekday: Mon=1 … Sun=7; we want Sun=0 offset
    final offset = firstDay.weekday % 7;
    final daysInMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    ).day;
    final rows = ((offset + daysInMonth) / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: List.generate(
          rows,
          (row) => Row(
            children: List.generate(7, (col) {
              final idx = row * 7 + col;
              final dayNum = idx - offset + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 40));
              }

              final date = DateTime(
                focusedMonth.year,
                focusedMonth.month,
                dayNum,
              );
              final isPast = date.isBefore(
                DateTime(today.year, today.month, today.day),
              );
              final isToday =
                  date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final isSel =
                  selectedDate != null &&
                  date.year == selectedDate!.year &&
                  date.month == selectedDate!.month &&
                  date.day == selectedDate!.day;

              return Expanded(
                child: GestureDetector(
                  onTap: isPast ? null : () => onDateSelect(date),
                  child: Container(
                    height: 38,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppConstants.primaryColor
                          : isToday
                          ? AppConstants.primaryColor.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isToday && !isSel
                          ? Border.all(
                              color: AppConstants.primaryColor.withOpacity(0.3),
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSel || isToday
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSel
                              ? Colors.white
                              : isPast
                              ? const Color(0xFFCBD5E1)
                              : isToday
                              ? AppConstants.primaryColor
                              : const Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
