import 'package:audioplayers/audioplayers.dart';

class GlobalAudioPlayer {
  static final GlobalAudioPlayer _instance = GlobalAudioPlayer._internal();
  final AudioPlayer audioPlayer = AudioPlayer();

  // Agrega estas líneas para almacenar el URL de la canción actual
  String? currentPlayingUrl;

  factory GlobalAudioPlayer() {
    return _instance;
  }

  GlobalAudioPlayer._internal();
}
