import 'package:display_misic_list/controller/songs_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Songs extends StatefulWidget {
  const Songs({Key? key}) : super(key: key);

  @override
  _SongsState createState() => _SongsState();
}

class _SongsState extends State<Songs> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 3));

  final SongController controller = Get.put(SongController());

  // Stream<PositionData> get _positionDataStream =>
  //     rx.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
  //         controller.player.value.positionStream,
  //         controller.player.value.bufferedPositionStream,
  //         controller.player.value.durationStream,
  //         (position, bufferedPosition, duration) => PositionData(
  //             position, bufferedPosition, duration ?? Duration.zero));

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
                height: 60,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(0, 5),
                        colors: [
                          Colors.grey,
                          Colors.grey,
                        ]),
                    borderRadius: BorderRadius.circular(30)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 10.0),
                      child: QueryArtworkWidget(
                        artworkHeight: 45,
                        artworkWidth: 45,
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
                    SizedBox(
                      width: 160,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                            child: Marquee(
                              text: controller.title.toString() ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              velocity: 50,
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                          Text(
                            controller.artist.toString(),
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 10,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                            icon: const Icon(
                              Icons.skip_previous,
                            ),
                            iconSize: 30.0,
                            onPressed: () {
                              controller.previousSong();
                            }),
                        StreamBuilder<bool>(
                          stream: controller.player.value.playingStream,
                          builder: (context, snapshot) {
                            bool? playingState = snapshot.data;
                            if (playingState != null && playingState) {
                              return IconButton(
                                  icon: const Icon(Icons.pause),
                                  iconSize: 30.0,
                                  onPressed: () {
                                    controller.pauseAudio();
                                  });
                            }
                            return IconButton(
                                icon: const Icon(Icons.play_arrow),
                                iconSize: 30.0,
                                onPressed: () {
                                  controller.playAudio();
                                });
                          },
                        ),
                        IconButton(
                            icon: const Icon(
                              Icons.skip_next,
                            ),
                            iconSize: 30.0,
                            onPressed: () {
                              controller.nextSong();
                            }),
                      ],
                    ),
                  ],

                  // subtitle: Container(
                  //   height: 40,
                  //   color: Colors.transparent,
                  //   child: StreamBuilder<PositionData>(
                  //     stream: _positionDataStream,
                  //     builder: (context, snapshot) {
                  //       final positionData = snapshot.data;
                  //       return SeekBar(
                  //         duration: positionData?.duration ?? Duration.zero,
                  //         position:
                  //             (controller.player.value.processingState ==
                  //                     ProcessingState.completed)
                  //                 ? Duration.zero
                  //                 : positionData?.position ?? Duration.zero,
                  //         bufferedPosition:
                  //             positionData?.bufferedPosition ?? Duration.zero,
                  //         onChangeEnd: controller.player.value.seek,
                  //       );
                  //     }, // Container
                  //   ),
                  // ),
                ),
              )
            : SizedBox(
                height: 1,
              ),
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
                  controller.songs.clear();
                  controller.songs = item.data!;
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: item.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          item.data![index].title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          item.data![index].album.toString(),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 13),
                        ),
                        leading: QueryArtworkWidget(
                          artworkHeight: 40,
                          artworkWidth: 40,
                          id: item.data![index].id,
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
                        onTap: () {
                          controller.audioPlayPause(
                              item.data![index].data, item.data, index);
                          controller.playing.value = true;
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
