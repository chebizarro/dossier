import 'package:flutter/material.dart';
import '../utils/preferences.dart';

class PreferencesDialog extends StatefulWidget {
  final Preferences preferences;

  PreferencesDialog({required this.preferences});

  @override
  _PreferencesDialogState createState() => _PreferencesDialogState();
}

class _PreferencesDialogState extends State<PreferencesDialog> {
  late bool startMaximized;

  @override
  void initState() {
    super.initState();
    startMaximized = widget.preferences.startMaximized;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Preferences'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            title: Text('Start maximized'),
            value: startMaximized,
            onChanged: (value) {
              setState(() {
                startMaximized = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            widget.preferences.startMaximized = startMaximized;
            await widget.preferences.save();
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
