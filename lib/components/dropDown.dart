import 'package:flutter/material.dart';

class CustomDropdownWithButtons extends StatefulWidget {
  final List<String> dropdownItems;
  final List<String> buttonLabels;
  final List<VoidCallback?> buttonCallbacks; // List of callback functions
  final void Function(String)? onDropdownChanged;

  const CustomDropdownWithButtons({
    Key? key,
    required this.dropdownItems,
    required this.buttonLabels,
    required this.buttonCallbacks, // Add this required param
    this.onDropdownChanged,
  })  : assert(buttonLabels.length == buttonCallbacks.length,
            'buttonLabels and buttonCallbacks must have the same length'),
        super(key: key);

  @override
  State<CustomDropdownWithButtons> createState() =>
      _CustomDropdownWithButtonsState();
}

class _CustomDropdownWithButtonsState extends State<CustomDropdownWithButtons> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    // If dropdownItems has exactly one item, set it as the initial selected value
    if (widget.dropdownItems.isNotEmpty) {
      selectedValue = widget.dropdownItems.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Only show dropdown if dropdownItems is not empty
        if (widget.dropdownItems.isNotEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select action...'),
              value: selectedValue,
              items: widget.dropdownItems.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue;
                });
                if (widget.onDropdownChanged != null && newValue != null) {
                  widget.onDropdownChanged!(newValue);
                }
              },
            ),
          ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: List.generate(widget.buttonLabels.length, (index) {
            return ElevatedButton(
              onPressed: widget.buttonCallbacks[index],
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 149, 238, 152),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(widget.buttonLabels[index]),
            );
          }),
        ),
      ],
    );
  }
}
