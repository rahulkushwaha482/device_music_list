import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class SongController extends GetxController {
  var isPlaying = false.obs;
  var player = AudioPlayer().obs;
  var audioQuery = OnAudioQuery().obs;
  var id = 0.obs;
  var artist = ''.obs;
  var title = ''.obs;
  var playing = false.obs;

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    player.value.dispose();
  }

  void requestPermission() async {
    await Permission.storage.request();
    var status = await Permission.storage.status;

    if (status.isDenied) {
      await Permission.storage.request();
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    requestPermission();
    audioQuery.value = OnAudioQuery();

    player.value.playbackEventStream.listen(
        (event) {
          if (event.processingState == ProcessingState.completed) {}
          if (event.processingState == ProcessingState.idle) {}
        },
        onDone: () {},
        onError: (Object e, StackTrace stackTrace) {
          //print('A stream error occurred: $e');
        });
  }

  void setAudioSource(String uri) {
    try {
      player.value.setAudioSource(AudioSource.uri(Uri.parse(uri)));
      isPlaying.value = true;
    } catch (e) {
      if (kDebugMode) {
        print("Error loading audio source: $e");
      }
    }
  }

  void audioPlayPause(String uri) async {
    setAudioSource(uri);
    playing.value = true;
    await player.value.play();

  }

  void playAudio() async {
    playing.value = true;
    await player.value.play();
  }

  void pauseAudio() async {
    playing.value = false;
    await player.value.pause();
  }
}
