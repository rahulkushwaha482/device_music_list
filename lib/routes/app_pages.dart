import 'package:display_misic_list/screen/songs.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(name: '/', page: () => const Songs()),
  ];
}
