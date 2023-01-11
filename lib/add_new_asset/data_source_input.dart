import 'package:flutter/material.dart';

/// A simple [Text] object to label the [DataSourceTextField].
///
/// Instructs the user what to enter in the [DataSourceTextField] directly
/// beneath this widget.
///
class DataSourceLabel extends StatelessWidget {
  const DataSourceLabel({super.key, required this.dataSourceLabel});

  final String dataSourceLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 24.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(dataSourceLabel),
      ),
    );
  }
}

/// Enter the source of user's [Asset] quantity data and other related data.
///
/// Can accept a manual entry, a blackchain address, or later, an exchange API
/// key.
///
class DataSourceTextField extends StatefulWidget {
  const DataSourceTextField({
    super.key,
    required this.dataSourceScannable,
    required this.qrIconPressedCallback,
    required this.qrCodeResult,
    required this.dataSourceTextFieldKeyboard,
    required this.dataSourceInputController,
  });
  final bool dataSourceScannable;
  final VoidCallback qrIconPressedCallback;
  final String qrCodeResult;
  final TextInputType dataSourceTextFieldKeyboard;
  final TextEditingController dataSourceInputController;

  @override
  State<DataSourceTextField> createState() => _DataSourceTextFieldState();
}

class _DataSourceTextFieldState extends State<DataSourceTextField> {
  @override
  void initState() {
    super.initState();
    widget.dataSourceInputController.addListener(
      () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: 50.0,
        child: TextField(
          cursorColor: Theme.of(context).iconTheme.color,
          controller: widget.dataSourceInputController,
          decoration: InputDecoration(
            fillColor: Theme.of(context).primaryColor,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).iconTheme.color!,
                width: 0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).iconTheme.color!,
                width: 0,
              ),
            ),
            filled: true,
            suffixIcon: widget.dataSourceInputController.text.isEmpty
                ? widget.dataSourceScannable
                    ? IconButton(
                        onPressed: onQRIconPressed,
                        icon: Icon(
                          Icons.qr_code_scanner,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      )
                    : Container(width: 0)
                : IconButton(
                    onPressed: () => widget.dataSourceInputController.clear(),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
          ),
          keyboardType: widget.dataSourceTextFieldKeyboard,
        ),
      ),
    );
  }

  void onQRIconPressed() {
    widget.qrIconPressedCallback();
    widget.dataSourceInputController.text = widget.qrCodeResult;
  }
}
