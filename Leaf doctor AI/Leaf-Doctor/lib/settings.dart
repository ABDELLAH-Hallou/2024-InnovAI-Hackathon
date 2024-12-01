import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: _darkMode,
            onChanged: (bool value) {
              setState(() {
                _darkMode = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('Notifications'),
            value: _notifications,
            onChanged: (bool value) {
              setState(() {
                _notifications = value;
              });
            },
          ),
          ListTile(
            title: Text('Language'),
            subtitle: Text(_selectedLanguage),
            onTap: _selectLanguage,
          ),
          ListTile(
            title: Text('Privacy Policy'),
            onTap: () {
              // Handle privacy policy action
            },
          ),
          ListTile(
            title: Text('Terms of Service'),
            onTap: () {
              // Handle terms of service action
            },
          ),
          ListTile(
            title: Text('About'),
            onTap: () {
              // Handle about action
            },
          ),
        ],
      ),
    );
  }

  void _selectLanguage() async {
    String? language = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Select Language'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Arabic');
              },
              child: Text('العربية'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'English');
              },
              child: Text('English'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'French');
              },
              child: Text('French'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Spanish');
              },
              child: Text('Spanish'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Tamazight');
              },
              child: Text('Tamazight'),
            ),
          ],
        );
      },
    );

    if (language != null) {
      setState(() {
        _selectedLanguage = language;
      });
    }
  }
}
