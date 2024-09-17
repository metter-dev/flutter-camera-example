import 'package:flutter/material.dart';

class DropdownOption {
  final String value;
  final String label;

  DropdownOption({required this.value, required this.label});
}

Widget buildGeneralDropdown({
  required List<DropdownOption> options,
  required Function(String?) onChanged,
  String? value,
  String? hint,
}) {
  return GestureDetector(
    onTap: () {
      print("Dropdown tapped!"); // Debug print
    },
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      hint: hint != null ? Text(hint) : null,
      value: value,
      onChanged: (newValue) {
        print("Option selected: $newValue"); // Debug print
        onChanged(newValue);
      },
      items: options.map<DropdownMenuItem<String>>((DropdownOption option) {
        return DropdownMenuItem<String>(
          value: option.value,
          child: Text(option.label),
        );
      }).toList(),
    ),
  );
}
