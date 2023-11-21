import 'package:flutter/material.dart';
import 'package:pinocho/pages/components/title_button.dart';
import 'package:pinocho/pages/data_database.dart';
import 'package:pinocho/pages/music.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.purple,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(
              Icons.music_note,
              color: Colors.purple,
              size: 25,
            ),
            title: const Text('Música',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pushNamed(context, MusicPage.RUTA);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
