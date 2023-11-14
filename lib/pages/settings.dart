import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pinocho/pages/components/singleton.dart';
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
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.pushNamed(context, MusicPage.RUTA);
              },
              child: const Text("Música"))
        ],
      ),
    );
  }
}
