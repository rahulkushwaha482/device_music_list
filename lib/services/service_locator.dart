import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';

import 'audio_handler.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // services
  getIt.registerSingleton<AudioHandler>(await initAudioService());
  //getIt.registerLazySingleton<PlaylistRepository>(() => DemoPlaylist());
}
