import 'package:flutter/material.dart';

/// A [DropdownButton] menu where the user selects their quantity source.
///
/// Quanity can be specified manually, through a blockchain address that
/// automatically keeps itself updated, or when implemented, a Read-only
/// exchange API key.
///
class DataSourceDropdown extends StatelessWidget {
  final String currentDataSource;
  final List<String> dataSourceDropdownValues;
  final ValueChanged<String> dataSourceChangedCallback;

  const DataSourceDropdown({
    super.key,
    required this.currentDataSource,
    required this.dataSourceDropdownValues,
    required this.dataSourceChangedCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: DropdownButton<String>(
          dropdownColor: Theme.of(context).primaryColor,
          onChanged: ((String? selectedDataSource) {
            dataSourceChangedCallback(selectedDataSource!);
          }),
          value: currentDataSource,
          items: dataSourceDropdownValues
              .map<DropdownMenuItem<String>>((String dataSourceName) {
            return DropdownMenuItem<String>(
              value: dataSourceName,
              child: Text(dataSourceName),
            );
          }).toList(),
          isExpanded: true,
        ),
      ),
    );
  }
}
