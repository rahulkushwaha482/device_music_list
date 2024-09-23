import 'package:display_misic_list/controller/songs_controller.dart';
import 'package:display_misic_list/screen/player_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:marquee/marquee.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../constant/app_string.dart';

class Songs extends StatelessWidget {

  final SongController controller = Get.put(SongController());

  Songs({super.key});

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(.2),
      appBar: AppBar(
        title: const Text(playerName,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      bottomNavigationBar: Obx(
        () => (controller.isPlaying.value || controller.playing.value && controller.player.value.playing)
            ? GestureDetector(
                onTap: () {
                  controller.fetchArtwork(controller.id.value);
                  showMaterialModalBottomSheet(
                    context: context,
                    builder: (context) => PlayerScreen(),
                  );
                  // controller.openPlayer(controller.id);
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment(0, 5),
                          colors: [
                            Colors.greenAccent,
                            Colors.lightGreen,
                            Colors.amberAccent,
                          ]),
                      borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, right: 3.0),
                        child: Hero(
                          tag: controller.id,
                          child: controller.cachedArtworkWidget.value ??
                        QueryArtworkWidget(
                        artworkHeight: 45,
                          artworkWidth: 45,
                          id: controller.id.toInt(),
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: const CircleAvatar(
                            radius: 22,
                            backgroundImage: AssetImage('assets/icon.png'),
                          ),
                        ),
                        )
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
                                velocity: 10,
                                blankSpace: 100.0,
                                pauseAfterRound: Duration(milliseconds: 1),
                                startPadding: 10.0,
                                accelerationDuration: Duration(milliseconds: 1),
                                accelerationCurve: Curves.linear,
                                decelerationDuration: Duration(milliseconds: 500),
                                decelerationCurve: Curves.easeOut,
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
                      Obx(() {
                        return Row(
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
                        );
                      }
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

              () => controller.isPermissionGranted.value==true?
              FutureBuilder<List<SongModel>>(
                future: controller.audioQuery.value.querySongs(
                    sortType: null,
                    orderType: OrderType.ASC_OR_SMALLER,
                    uriType: UriType.EXTERNAL),
                builder: (context, item) {

                  // Show progress indicator while loading songs
                  if (item.connectionState == ConnectionState.waiting ||
                      item.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }else{
                    // If no songs are found
                    if (item.data!.isEmpty) {
                      return const Center(child: Text('No songs found'));
                    }
                    // Populate songs list in the controller
                    controller.songs.clear();
                    controller.songs = item.data!;
                  }


                  // Build list of songs
                  return ListView.separated(
                    separatorBuilder: (context, index) {
                      return const Divider(
                        color: Colors.white30,
                        height: 0,
                        thickness: 1,
                        indent: 72,
                      );
                    },
                    physics: const BouncingScrollPhysics(),
                    itemCount: item.data!.length,
                    itemBuilder: (context, index) {

                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ListTile(
                          title: Text(
                            item.data![index].title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            item.data![index].album.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: QueryArtworkWidget(
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
                          ),
                          trailing:
                          Obx(() {
                            return controller.currentSongId.value == item.data![index].id && controller.playing.value
                                ? SizedBox(
                              width: 23,
                              child: LoadingAnimationWidget.prograssiveDots(
                                color: Colors.greenAccent,
                                size: 23,
                              ),
                            )
                                : const SizedBox();
                          }),
                          onTap: () {

                            if(item.data![index].data.isNotEmpty){
                              controller.audioPlayPause(
                                  item.data![index].data, item.data, index);
                              controller.playing.value = true;
                            }

                          },
                        ),
                      );
                    },
                  );
                },

              ):
              const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

