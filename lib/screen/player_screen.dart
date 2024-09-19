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

  PlayerScreen( {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
              onPressed: () => controller.goBack(),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 30,
                color: Colors.white,
              )),
        ),
      ),
      extendBodyBehindAppBar: true,
      body:  Obx(
    () =>
         Center(

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                //artwork container




                Hero(
                  tag: controller.id,
                  child:
                      QueryArtworkWidget(
                        artworkHeight: 250,
                        artworkWidth: 250,
                        id: controller.id.toInt(),
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: const CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage('assets/icon.png'),
                        ),
                      ),
                ),
                //slider , position and duration widgets
                Padding(
                  padding: const EdgeInsets.only(left: 30.0,right: 30.0,top: 50),

                  child: Column(
                    children: [

                      //slider bar container
                      StreamBuilder<DurationState>(
                        stream: controller.durationStateStream,
                        builder: (context, snapshot) {
                          final durationState = snapshot.data;
                          final progress = durationState?.position ?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;
                          return ProgressBar(
                            progress: progress,
                            total: total,
                            baseBarColor: Colors.grey,
                            progressBarColor: Colors.red,
                            thumbColor: Colors.white,
                            timeLabelTextStyle: const TextStyle(
                              fontSize: 10,
                            ),
                            onSeek: (duration) {
                              controller.player.value.seek(duration);
                            },
                          );



                        },
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
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  total.toString().split(".")[0],
                                  style: const TextStyle(
                                    color: Colors.white,
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
                ),

                const SizedBox(
                  height: 20,
                ),

                //prev, play/pause & seek next control buttons
                Padding(
                  padding: const EdgeInsets.only(left: 30.0,right: 30.0),
                  child: Container(
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
                            child: StreamBuilder<LoopMode>(
                              stream: controller.player.value.loopModeStream,
                              builder: (context, snapshot) {
                                final loopMode = snapshot.data;
                                if (LoopMode.one == loopMode) {
                                  return const Icon(
                                    Icons.repeat_one,
                                    color: Colors.white,
                                    size: 35,
                                  );
                                }
                                return const Icon(
                                  Icons.repeat,
                                  color: Colors.white,
                                  size: 35,
                                );
                              },
                            ),
                          ),
                        ),

                        //skip to previous
                        Flexible(
                          child: InkWell(
                            onTap: () {
                              if (controller.player.value.hasPrevious) {
                                controller.previousSong();
                              }
                            },
                            child: const Icon(
                              Icons.skip_previous,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),

                        //play pause
                        Flexible(
                          child: InkWell(
                            onTap: () {
                              if (controller.player.value.playing) {
                                controller.pauseAudio();
                              } else {
                                if (controller.player.value.currentIndex != null) {
                                  controller.playAudio();
                                }
                              }
                            },
                            child: StreamBuilder<bool>(
                              stream: controller.player.value.playingStream,
                              builder: (context, snapshot) {
                                bool? playingState = snapshot.data;
                                if (playingState != null && playingState) {
                                  return const Icon(
                                    Icons.pause,
                                    size: 35,
                                    color: Colors.white,
                                  );
                                }
                                return const Icon(
                                  Icons.play_arrow,
                                  size: 35,
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                        ),

                        //skip to next
                        Flexible(
                          child: InkWell(
                            onTap: () {
                              if (controller.player.value.hasNext) {
                                controller.nextSong();
                              }
                            },
                            child: const Icon(
                              Icons.skip_next,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),

                        Flexible(
                          child: InkWell(
                            onTap: () {
                              controller.player.value.setShuffleModeEnabled(true);
                              toast(context, "Shuffling enabled");
                            },
                            child: const Icon(
                              Icons.shuffle,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ),

    );
  }
}
