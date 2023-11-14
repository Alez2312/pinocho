import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:pinocho/pages/components/singleton.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  static const String RUTA = '/music';

  @override
  _MusicPageState createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage>
    with WidgetsBindingObserver {
  String selectedUrl = '';
  bool isPlaying = false;


// Lista de URLs de las canciones.
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

// Método para manejar los cambios en el ciclo de vida de la aplicación.
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
// Remover el observador del ciclo de vida al destruir el widget.
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

// Método para dar formato al título de la canción.
  String formatSongTitle(String url) {
    return url.split('/').last.replaceAll('.mp3', '').replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Música'),
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
