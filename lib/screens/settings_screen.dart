import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final bool isCelsius;
  final bool is24Hour;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.isCelsius,
    required this.is24Hour,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDarkMode;
  late bool _isCelsius;
  late bool _is24Hour;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _isCelsius = widget.isCelsius;
    _is24Hour = widget.is24Hour;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Theme',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Theme'),
            subtitle: Text(_isDarkMode ? 'Enabled' : 'Disabled'),
            value: _isDarkMode,
            onChanged: (value) async {
              setState(() {
                _isDarkMode = value;
              });
              await _settingsService.setDarkMode(value);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Temperature',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Temperature in Celsius'),
            subtitle: Text(_isCelsius ? 'Celsius' : 'Fahrenheit'),
            value: _isCelsius,
            onChanged: (value) async {
              setState(() {
                _isCelsius = value;
              });
              await _settingsService.setIsCelsius(value);
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Time Format',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('24 hour time'),
            subtitle: Text(_is24Hour ? '24-hour' : '12-hour'),
            value: _is24Hour,
            onChanged: (value) async {
              setState(() {
                _is24Hour = value;
              });
              await _settingsService.setIs24Hour(value);
            },
          ),
        ],
      ),
    );
  }
}