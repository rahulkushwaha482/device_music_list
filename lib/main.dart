import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'routes/app_pages.dart';

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.white),
  );

  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded<Future<void>>(
    () async {
      runApp(
        GetMaterialApp(
          title: 'Device Music',
          initialRoute: '/',
          debugShowCheckedModeBanner: false,
          getPages: AppPages.pages,
          theme: ThemeData(useMaterial3: true),
        ),
      );
    },
    (dynamic error, StackTrace stackTrace) {
      log('error $error');
      log('stackTrace $stackTrace');
    },
  );
}
