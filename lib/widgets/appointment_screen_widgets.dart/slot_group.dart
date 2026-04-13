import 'package:flutter/material.dart';
import 'package:patient_app/app_constants.dart';
import 'package:patient_app/appointment_confirm_screen.dart';

class SlotGroup extends StatelessWidget {
  final String title;
  final List<Slot> slots;
  final Slot? selected;
  final Map<String, bool> availability;
  final ValueChanged<Slot> onSelect;
  const SlotGroup(
    this.title,
    this.slots,
    this.selected,
    this.availability,
    this.onSelect, {super.key}
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: slots.map((slot) {
          final booked = availability[slot.value] == true;
          final isSel = selected?.value == slot.value;
          return GestureDetector(
            onTap: booked ? null : () => onSelect(slot),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: booked
                    ? const Color(0xFFF1F5F9)
                    : isSel
                    ? AppConstants.primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: booked
                      ? const Color(0xFFE2E8F0)
                      : isSel
                      ? AppConstants.primaryColor
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                slot.display,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: booked ? TextDecoration.lineThrough : null,
                  color: booked
                      ? const Color(0xFFCBD5E1)
                      : isSel
                      ? Colors.white
                      : const Color(0xFF1A1A2E),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}
