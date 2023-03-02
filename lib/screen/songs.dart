import 'package:display_misic_list/controller/songs_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../constant/app_string.dart';

class Songs extends StatelessWidget {
  final SongController controller = Get.put(SongController());

  Songs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(playerName),
        elevation: 2,
      ),
      bottomNavigationBar: Obx(
        () => (controller.isPlaying.value || controller.playing.value)
            ? InkWell(
                onTap: () {
                  controller.openPlayer(controller.id);
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 3.0),
                        child: StreamBuilder<bool>(
                          stream: controller.player.value.playingStream,
                          builder: (context, snapshot) {
                            return QueryArtworkWidget(
                              artworkHeight: 45,
                              artworkWidth: 45,
                              id: controller.id.toInt(),
                              type: ArtworkType.AUDIO,
                              nullArtworkWidget: const CircleAvatar(
                                radius: 22,
                                backgroundImage:
                                AssetImage('assets/icon.png'),
                              )
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 160,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 16,
                              child: Marquee(
                                text: controller.title.toString() ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                                scrollAxis: Axis.horizontal,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                velocity: 30,
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                              icon: const Icon(
                                Icons.skip_previous,
                              ),
                              iconSize: 25.0,
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
                                    iconSize: 25.0,
                                    onPressed: () {
                                      controller.pauseAudio();
                                    });
                              }
                              return IconButton(
                                  icon: const Icon(Icons.play_arrow),
                                  iconSize: 25.0,
                                  onPressed: () {
                                    controller.playAudio();
                                  });
                            },
                          ),
                          IconButton(
                              icon: const Icon(
                                Icons.skip_next,
                              ),
                              iconSize: 25.0,
                              onPressed: () {
                                controller.nextSong();
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(
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
                            backgroundImage:
                            AssetImage('assets/icon.png'),
                          )
                          
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
