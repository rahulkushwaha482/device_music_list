import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../controller/songs_controller.dart';
import '../utils/common.dart';
import '../utils/utils.dart';

class PlayerScreen extends StatelessWidget {
  final SongController controller = Get.put(SongController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.only(top: 56.0, right: 20.0, left: 20.0),
          decoration: BoxDecoration(color: Colors.white24),
          child: Column(
            children: <Widget>[
              //exit button and the song title
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: InkWell(
                      onTap: () {
                        controller.goBack();
                      },
                      //hides the player view
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Text(
                      'currentSongTitle',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    flex: 5,
                  ),
                ],
              ),

              //artwork container
              Hero(
                tag: 'music',
                child: Container(
                  width: 300,
                  height: 300,
                  margin: const EdgeInsets.only(top: 30, bottom: 30),
                  child: QueryArtworkWidget(
                    artworkBorder: BorderRadius.circular(200),
                    id: controller.id.toInt(),
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.deepOrange,
                      child: Icon(
                        Icons.music_note,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              //slider , position and duration widgets
              Column(
                children: [
                  //slider bar container
                  Container(
                    //slider bar duration state stream
                    child: StreamBuilder<DurationState>(
                      stream: controller.durationStateStream,
                      builder: (context, snapshot) {
                        final durationState = snapshot.data;
                        final progress =
                            durationState?.position ?? Duration.zero;
                        final total = durationState?.total ?? Duration.zero;

                        return ProgressBar(
                          progress: progress,
                          total: total,
                          baseBarColor: Colors.grey,
                          progressBarColor: Colors.blue,
                          thumbColor: Colors.blue,
                          timeLabelTextStyle: const TextStyle(
                            fontSize: 0,
                          ),
                          onSeek: (duration) {
                            controller.player.value.seek(duration);
                          },
                        );

                      },
                    ),
                  ),

                  //position /progress and total text
                  StreamBuilder<DurationState>(
                    stream: controller.durationStateStream,
                    builder: (context, snapshot) {
                      final durationState = snapshot.data;
                      final progress = durationState?.position ?? Duration.zero;
                      final total = durationState?.total ?? Duration.zero;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: Text(
                              progress.toString().split(".")[0],
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              total.toString().split(".")[0],
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),

              SizedBox(
                height: 20,
              ),

              //prev, play/pause & seek next control buttons
              Container(
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          controller.player.value.loopMode == LoopMode.one
                              ? controller.player.value
                                  .setLoopMode(LoopMode.all)
                              : controller.player.value
                                  .setLoopMode(LoopMode.one);
                        },
                        child: Container(
                          child: StreamBuilder<LoopMode>(
                            stream: controller.player.value.loopModeStream,
                            builder: (context, snapshot) {
                              final loopMode = snapshot.data;
                              if (LoopMode.one == loopMode) {
                                return const Icon(
                                  Icons.repeat_one,
                                  color: Colors.black87,
                                );
                              }
                              return const Icon(
                                Icons.repeat,
                                color: Colors.black87,
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    //skip to previous
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          if (controller.player.value.hasPrevious) {
                            controller.player.value.seekToPrevious();
                          }
                        },
                        child: Container(
                          child: const Icon(
                            Icons.skip_previous,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    //play pause
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          if (controller.player.value.playing) {
                            controller.player.value.pause();
                          } else {
                            if (controller.player.value.currentIndex != null) {
                              controller.player.value.play();
                            }
                          }
                        },
                        child: Container(
                          child: StreamBuilder<bool>(
                            stream: controller.player.value.playingStream,
                            builder: (context, snapshot) {
                              bool? playingState = snapshot.data;
                              if (playingState != null && playingState) {
                                return const Icon(
                                  Icons.pause,
                                  size: 30,
                                  color: Colors.black87,
                                );
                              }
                              return const Icon(
                                Icons.play_arrow,
                                size: 30,
                                color: Colors.black87,
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    //skip to next
                    Flexible(
                      child: InkWell(
                        onTap: () {
                          if (controller.player.value.hasNext) {
                            controller.player.value.seekToNext();
                          }
                        },
                        child: Container(
                          child: const Icon(
                            Icons.skip_next,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    Flexible(
                      child: InkWell(
                        onTap: () {
                          controller.player.value.setShuffleModeEnabled(true);
                          toast(context, "Shuffling enabled");
                        },
                        child: Container(
                          child: const Icon(
                            Icons.shuffle,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
