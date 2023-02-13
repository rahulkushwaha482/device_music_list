import 'package:display_misic_list/controller/songs_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'dart:math' as math;
import '../utils/common.dart';

class Songs extends StatefulWidget {
  const Songs({Key? key}) : super(key: key);

  @override
  _SongsState createState() => _SongsState();
}

class _SongsState extends State<Songs> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 3));

  final SongController controller = Get.put(SongController());

  Stream<PositionData> get _positionDataStream =>
      rx.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          controller.player.value.positionStream,
          controller.player.value.bufferedPositionStream,
          controller.player.value.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    controller.onInit();
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Music Gallery"),
        elevation: 2,
      ),
      bottomNavigationBar: Obx(
        () => (controller.isPlaying.value || controller.playing.value)
            ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                height: 75,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(0, 5),
                        colors: [
                          Colors.grey,
                          Colors.grey,
                        ]),
                    borderRadius: BorderRadius.circular(0)),
                child: ListTile(
                    leading: AnimatedBuilder(
                      animation: _animationController,
                      builder: (_, child) {
                        if (controller.playing.value) {
                          _animationController.forward();
                          _animationController.repeat();
                        } else {
                          _animationController.stop();
                        }
                        return Transform.rotate(
                            angle: _animationController.value * 2 * math.pi,
                            child: child);
                      },
                      child: QueryArtworkWidget(
                        id: controller.id.toInt(),
                        type: ArtworkType.AUDIO,
                      ),
                    ),
                    title: Text(
                      controller.title.toString() +
                          controller.artist.toString(),
                      style: const TextStyle(fontSize: 11),
                    ),
                    subtitle: Container(
                      height: 40,
                      color: Colors.transparent,
                      child: StreamBuilder<PositionData>(
                        stream: _positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data;
                          return SeekBar(
                            duration: positionData?.duration ?? Duration.zero,
                            position:
                                (controller.player.value.processingState ==
                                        ProcessingState.completed)
                                    ? Duration.zero
                                    : positionData?.position ?? Duration.zero,
                            bufferedPosition:
                                positionData?.bufferedPosition ?? Duration.zero,
                            onChangeEnd: controller.player.value.seek,
                          );
                        }, // Container
                      ),
                    ),
                    trailing: Obx(
                      () => (controller.playing.value)
                          ? IconButton(
                              icon: const Icon(Icons.pause),
                              iconSize: 40.0,
                              onPressed: () {
                                controller.pauseAudio();
                              })
                          : IconButton(
                              icon: const Icon(Icons.play_arrow),
                              iconSize: 40.0,
                              onPressed: () {
                                controller.playAudio();
                              }),
                    )),
              )
            : const Text(''),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SafeArea(
            child: Obx(
              () => FutureBuilder<List<SongModel>>(
                future: controller.audioQuery.value.querySongs(
                    sortType: null,
                    orderType: OrderType.ASC_OR_SMALLER,
                    uriType: UriType.EXTERNAL),
                builder: (context, item) {
                  if (item.data == null) {
                    return const CircularProgressIndicator();
                  }
                  if (item.data!.isEmpty) {
                    return const CircularProgressIndicator();
                  }
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: item.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(item.data![index].title.toString()),
                        subtitle: Text(item.data![index].artist.toString()),
                        leading: QueryArtworkWidget(
                          id: item.data![index].id,
                          type: ArtworkType.AUDIO,
                        ),
                        onTap: () {
                          controller.audioPlayPause(
                              item.data![index].uri.toString(),
                              item.data![index].id,
                              item.data![index].album,
                              item.data![index].title,
                              item.data![index].data);
                          controller.playing.value = true;

                          controller.artist.value =
                              item.data![index].artist.toString();
                          controller.title.value =
                              item.data![index].title.toString();
                          controller.id.value = item.data![index].id;
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
