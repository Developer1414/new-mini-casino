import 'package:just_audio/just_audio.dart';

enum AudioType { bet }

class AudioController {
  static late AudioPlayer betAudioSound;

  static Future<AudioPlayer> getAudio(String audioName) async {
    final player = AudioPlayer();

    await player.setAudioSource(
        AudioSource.asset('assets/audios/$audioName.mp3'),
        initialPosition: Duration.zero,
        preload: true);

    return player;
  }

  static Future initializeAudios() async {
    betAudioSound = await getAudio('click');
  }

  static Future play(AudioType audioType) async {
    switch (audioType) {
      case AudioType.bet:
        betAudioSound.play();
        break;
    }
  }
}
