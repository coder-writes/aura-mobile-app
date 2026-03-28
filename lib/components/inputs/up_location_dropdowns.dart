import 'package:flutter/material.dart';
import '../../core/constants/up_locations.dart';

class UpLocationDropdowns extends StatelessWidget {
  final String? selectedState;
  final String? selectedCity;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<String?> onCityChanged;
  final InputDecoration Function(String label) decorationBuilder;
  final bool allowAllOptions;
  final bool includeSelectedIfMissing;

  const UpLocationDropdowns({
    super.key,
    required this.selectedState,
    required this.selectedCity,
    required this.onStateChanged,
    required this.onCityChanged,
    required this.decorationBuilder,
    this.allowAllOptions = false,
    this.includeSelectedIfMissing = true,
  });

  @override
  Widget build(BuildContext context) {
    final stateOptions = [...UpLocations.states];
    if (includeSelectedIfMissing &&
        selectedState != null &&
        !stateOptions.contains(selectedState)) {
      stateOptions.insert(0, selectedState!);
    }

    final cityOptions = selectedState == null
        ? <String>[]
        : [...UpLocations.cities];

    if (includeSelectedIfMissing &&
        selectedCity != null &&
        !cityOptions.contains(selectedCity)) {
      cityOptions.insert(0, selectedCity!);
    }

    final stateItems = <DropdownMenuItem<String?>>[
      if (allowAllOptions)
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('All States'),
        ),
      ...stateOptions.map(
        (state) => DropdownMenuItem<String?>(
          value: state,
          child: Text(
            state,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    ];

    final cityItems = <DropdownMenuItem<String?>>[
      if (allowAllOptions)
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('All Cities'),
        ),
      ...cityOptions.map(
        (city) => DropdownMenuItem<String?>(
          value: city,
          child: Text(
            city,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    ];

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String?>(
            isExpanded: true,
            initialValue: selectedState,
            decoration: decorationBuilder('State'),
            items: stateItems,
            onChanged: (value) {
              onStateChanged(value);
              if (value == null || value != selectedState) {
                onCityChanged(null);
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String?>(
            isExpanded: true,
            initialValue: selectedCity,
            decoration: decorationBuilder('City'),
            items: cityItems,
            onChanged: selectedState == null
                ? null
                : (value) {
                    onCityChanged(value);
                  },
          ),
        ),
      ],
    );
  }
}
