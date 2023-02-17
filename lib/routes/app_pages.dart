import 'package:display_misic_list/screen/player_screen.dart';
import 'package:display_misic_list/screen/songs.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(name: '/', page: () => const Songs()),
    GetPage(name: '/player', page: () =>  PlayerScreen()),
  ];
}
