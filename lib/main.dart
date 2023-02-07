import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'routes/app_pages.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded<Future<void>>(
    () async {
      runApp(
        GetMaterialApp(
          title: 'Device Info Access',
          initialRoute: '/',
          debugShowCheckedModeBanner: false,
          getPages: AppPages.pages,
        ),
      );
    },
    (dynamic error, StackTrace stackTrace) {
      log('error $error');
      log('stackTrace $stackTrace');
    },
  );
}
