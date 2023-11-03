import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pinocho/pages/components/singleton.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  String selectedUrl = '';
  bool isPlaying = false;

  final List<String> musicUrls = [
    "music/Death Grips - Get Got.mp3",
    "music/Death Grips - I Have Seen Footage.mp3",
    "music/Death Grips - The Fever.mp3",
    "music/Glowworm - Periphescence.mp3"
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (GlobalAudioPlayer().currentPlayingUrl != null) {
      selectedUrl = GlobalAudioPlayer().currentPlayingUrl!;
      isPlaying = GlobalAudioPlayer().audioPlayer.state == PlayerState.playing;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      GlobalAudioPlayer().audioPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (isPlaying) {
        GlobalAudioPlayer().audioPlayer.resume();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String formatSongTitle(String url) {
    return url.split('/').last.replaceAll('.mp3', '').replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          const Text(
            'Selecciona música de fondo:',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: musicUrls.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(formatSongTitle(musicUrls[index])),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedUrl == musicUrls[index])
                        IconButton(
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          onPressed: () async {
                            if (isPlaying) {
                              await GlobalAudioPlayer().audioPlayer.pause();
                            } else {
                              await GlobalAudioPlayer().audioPlayer.resume();
                            }
                            setState(() {
                              isPlaying = !isPlaying;
                            });
                          },
                        ),
                    ],
                  ),
                  onTap: () async {
                    if (selectedUrl != musicUrls[index] || !isPlaying) {
                      await GlobalAudioPlayer().audioPlayer.stop();
                      await GlobalAudioPlayer().audioPlayer.play(AssetSource(musicUrls[index]));
                      setState(() {
                        selectedUrl = musicUrls[index];
                        isPlaying = true;
                      });
                      GlobalAudioPlayer().currentPlayingUrl = musicUrls[index];
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
