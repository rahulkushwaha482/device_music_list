import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';

void main() {
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
