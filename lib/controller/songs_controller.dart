import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/constant.dart';

class SongController extends GetxController {
  var isPlaying = false.obs;
  var player = AudioPlayer().obs;
  var audioQuery = OnAudioQuery().obs;

//  var _audioEdit = OnAudioEdit().obs;
  var audioHandler = AudioHandler;
  var id = 0.obs;
  var artist = ''.obs;
  var title = ''.obs;
  var playing = false.obs;

  //more variables
  // var songs = [].obs;
  List<SongModel> songs = [];
  var currentIndex = 0.obs;

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
      //   currentSongTitle = songs[index].title;
      currentIndex = index.obs;
      setAudioSource(index);
    }
  }

  void setAudioSource(int index) async {
    try {
      var value = await getFilePath(songs[index]!.id).then((value) => value);
      await player.value
          .setAudioSource(createPlaylist(songs, value), initialIndex: index);
      title.value = songs[index].title;
      artist.value = songs[index].artist!;
      id.value = songs[index].id;
      // player.value.setAudioSource(AudioSource.uri(
      //   Uri.parse(uri),
      //   tag: MediaItem(
      //     // Specify a unique ID for each media item:
      //     id: id.toString(),
      //     // Metadata to display in the notification:
      //     album: album.toString(),
      //     title: title.toString(),
      //     artUri: Uri.parse("https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      //   ),
      // ));

      // player.value.open(
      // Audio.file(
      //   uri,
      //   metas: Metas(
      //     title: title.toString(),
      //     artist: artist.toString(),
      //     album: album.toString(),
      //     onImageLoadFail: MetasImage.network(
      //         "https://img.freepik.com/free-vector/elegant-musical-notes-music-chord-background_1017-20759.jpg"),
      //     image: MetasImage.file(asdasd.toString()),
      //   ),
      // ),
      // showNotification: true);

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
      sources.add(AudioSource.uri(Uri.parse(song.uri!),
          tag: MediaItem(
            // Specify a unique ID for each media item:
            id: song.id.toString(),
            // Metadata to display in the notification:
            album: song.album.toString(),
            title: song.title.toString(),
            artist: song.artist.toString(),
            artUri: getUriFromString(artWork),
          )));
    }
    return ConcatenatingAudioSource(children: sources);
  }

  Uri getUriFromString(String string) {
    if (UrlParser.validUrl(string)) {
      return Uri.parse(string);
    } else {
      return Uri.file(string);
    }
  }

  Future<String> getFilePath(int id) async {
    var asdasd = await audioQuery.value.queryArtwork(id, ArtworkType.AUDIO);
    if (asdasd != null) {
      Uint8List? imageInUnit8List = asdasd; // store unit8List image here ;

      final tempDir = await getTemporaryDirectory();
      File file = await File('${tempDir.path}/${id}.png').create();
      print(imageInUnit8List);
      file.writeAsBytesSync(imageInUnit8List);

      print('filepath');
      print(file.path);
      return file.path;
    } else {
      return 'null';
    }
  }

  void audioPlayPause(String data, List<SongModel>? itemData, int index) async {
    var asdasd = await audioQuery.value
        .queryArtwork(itemData![index].id, ArtworkType.AUDIO);
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
}
