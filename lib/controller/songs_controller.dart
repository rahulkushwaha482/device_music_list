import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:display_misic_list/utils/common.dart';
import 'package:display_misic_list/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart' as rx;

class SongController extends GetxController {
  var isPlaying = false.obs;
  var player = AudioPlayer().obs;
  var audioQuery = OnAudioQuery().obs;

  var id = 0.obs;
  var artist = 'Artist'.obs;
  var title = 'Title'.obs;
  var playing = false.obs;

  List<SongModel> songs = [];
  var currentIndex = 0.obs;

  void requestPermission() async {
    await Permission.storage.request();
    var status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    }
  }

  @override
  void onInit() {
    super.onInit();
    requestPermission();
    audioQuery.value = OnAudioQuery();
    player.value = AudioPlayer();
    //update the current playing song index listener
    player.value.currentIndexStream.listen((index) {
      if (index != null) {
        _updateCurrentPlayingSongDetails(index);
      }
    });
  }

  void _updateCurrentPlayingSongDetails(int index) {
    if (songs.isNotEmpty) {
      currentIndex = index.obs;
      setAudioSource(index);
    }
  }

  void setAudioSource(int index) async {
    try {
      var value = await getFilePath(songs[index].id).then((value) => value);
      await player.value
          .setAudioSource(createPlaylist(songs, value), initialIndex: index);
      title.value = songs[index].title;
      artist.value = songs[index].artist!;
      id.value = songs[index].id;

      isPlaying.value = true;
    } catch (e) {
      if (kDebugMode) {
        print("Error loading audio source: $e");
      }
    }
  }

  ConcatenatingAudioSource createPlaylist(
      List<SongModel> songs, String artWork) {
    List<AudioSource> sources = [];
    for (var song in songs) {
      final assetFile = File('assets/music.png');
      sources.add(AudioSource.uri(Uri.parse(song.uri!),
          tag: MediaItem(
            // Specify a unique ID for each media item:
            id: song.id.toString(),
            // Metadata to display in the notification:
            album: song.album.toString(),
            title: song.title.toString(),
            artist: song.artist.toString(),
            artUri:  getUriFromString(artWork),
          )));
    }
    return ConcatenatingAudioSource(children: sources);
  }

  Uri getUriFromString(String string) {
    if (validUrl(string)) {
      return Uri.parse(string);
    } else {
      return Uri.file(string);
    }
  }

  Future<String> getFilePath(int id) async {
    var fileBitmap = await audioQuery.value.queryArtwork(id, ArtworkType.AUDIO);
    if (fileBitmap != null) {
      Uint8List? imageInUnit8List = fileBitmap; // store unit8List image here ;

      final tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/$id.png').create();
      file.writeAsBytesSync(imageInUnit8List);

      return file.path;
    } else {
      return 'null';
    }
  }

  void audioPlayPause(String data, List<SongModel>? itemData, int index) async {
    await audioQuery.value.queryArtwork(itemData![index].id, ArtworkType.AUDIO);
    setAudioSource(index);
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

  void nextSong() {
    player.value.seekToNext();
  }

  void previousSong() {
    player.value.seekToPrevious();
  }

  void openPlayer(RxInt id) {
    Get.toNamed(
      '/player',
    );
  }

  void goBack() {
    Get.back();
  }

  //duration state stream
  Stream<DurationState> get durationStateStream =>
      rx.Rx.combineLatest2<Duration, Duration?, DurationState>(
          player.value.positionStream,
          player.value.durationStream,
          (position, duration) => DurationState(
              position: position, total: duration ?? Duration.zero));
}
