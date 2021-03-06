import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:get_it/get_it.dart';
import 'package:noobcaster/core/network/network_info.dart';
import 'package:noobcaster/core/settings/app_settings.dart';
import 'package:noobcaster/core/speech_recognition/speech_recognition.dart';
import 'package:noobcaster/core/util/input_validator.dart';
import 'package:noobcaster/core/util/time_zone_handler.dart';
import 'package:noobcaster/features/weather_forecast/data/data_sources/local_weather_data_source.dart';
import 'package:noobcaster/features/weather_forecast/data/data_sources/remote_weather_data_source.dart';
import 'package:noobcaster/features/weather_forecast/data/repositories/weather_repository_impl.dart';
import 'package:noobcaster/features/weather_forecast/domain/repositories/weather_repository.dart';
import 'package:noobcaster/features/weather_forecast/domain/usecases/get_cached_weather_data.dart';
import 'package:noobcaster/features/weather_forecast/domain/usecases/get_local_weather_data.dart';
import 'package:noobcaster/features/weather_forecast/domain/usecases/get_location_weather_data.dart';
import 'package:noobcaster/features/weather_forecast/presentation/bloc/weather_data_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GetIt sl = GetIt.I;

Future<void> init() async {
  //Features - WeatherData
  sl.registerFactory(() => WeatherDataBloc(
      inputValidator: sl(), local: sl(), location: sl(), cached: sl()));
  //Use cases
  sl.registerLazySingleton(() => GetLocalWeatherData(repository: sl()));
  sl.registerLazySingleton(() => GetLocationWeatherData(repository: sl()));
  sl.registerLazySingleton(() => GetCachedWeatherData(repository: sl()));
  //Core
  sl.registerLazySingleton<InputValidator>(() => InputValidatorImpl());
  //Repository
  sl.registerLazySingleton<WeatherRepository>(() => WeatherRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      geolocator: sl(),
      appSettings: sl(),
      networkInfo: sl()));
  //Data sources
  sl.registerLazySingleton<LocalWeatherDataSource>(
      () => LocalWeatherDataSourceImpl(sharedPreferences: sl()));
  sl.registerLazySingleton<RemoteWeatherDataSource>(
      () => RemoteWeatherDataSourceImpl(client: sl(), timezoneHandler: sl()));
  //External
  final voiceRecognition = VoiceRecognitionImpl();
  await voiceRecognition.init();
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<TimezoneHandler>(() => TimezoneHandlerImpl());
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Geolocator());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => DataConnectionChecker());
  sl.registerLazySingleton<VoiceRecognition>(() => voiceRecognition);
  sl.registerLazySingleton<AppSettings>(
      () => AppSettingsImpl(preferences: sharedPreferences));
}
