import 'package:flutter/material.dart';

/// A dropdown that also accepts free text — pick from the list or type your own.
/// Essential for Lebanon's grey-market imports, where a model/trim may not be
/// in any fixed catalog. The [controller]'s text is the value; read it on save.
class ComboField extends StatelessWidget {
  const ComboField({
    super.key,
    required this.controller,
    required this.label,
    required this.options,
    this.onSelected,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final List<String> options;
  final ValueChanged<String>? onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      controller: controller,
      label: Text(label),
      enabled: enabled,
      enableFilter: true,
      requestFocusOnTap: true,
      menuHeight: 320,
      expandedInsets: EdgeInsets.zero, // fill available width
      dropdownMenuEntries: [
        for (final o in options) DropdownMenuEntry(value: o, label: o),
      ],
      onSelected: (v) {
        if (v != null) onSelected?.call(v);
      },
    );
  }
}
