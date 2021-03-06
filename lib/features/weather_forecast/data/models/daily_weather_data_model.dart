import 'package:noobcaster/core/util/time_zone_handler.dart';
import 'package:noobcaster/features/weather_forecast/domain/entities/weather.dart';
import 'package:meta/meta.dart';

class DailyWeatherDataModel extends DailyWeatherData {
  DailyWeatherDataModel({
    @required double minTemp,
    @required double maxTemp,
    @required int humidity,
    @required int weekday,
    @required String icon,
  }) : super(
            humidity: humidity,
            icon: icon,
            maxTemp: maxTemp,
            minTemp: minTemp,
            weekday: weekday);
  factory DailyWeatherDataModel.fromServerJsonWithTimezone(
      Map<String, dynamic> json, TimezoneHandler handler, String timezone) {
    return DailyWeatherDataModel(
        humidity: (json["humidity"] as num).toInt(),
        icon: json["weather"][0]["icon"] as String,
        weekday: handler
            .dateTimeFromUnixAndTimezone(timezone, json["dt"] as int)
            .weekday,
        maxTemp: (json["temp"]["max"] as num).toDouble(),
        minTemp: (json["temp"]["min"] as num).toDouble());
  }
  factory DailyWeatherDataModel.fromCacheJson(Map<String, dynamic> json) {
    return DailyWeatherDataModel(
        humidity: json["humidity"] as int,
        icon: json["icon"] as String,
        weekday: json["weekday"] as int,
        maxTemp: (json["max"] as num).toDouble(),
        minTemp: (json["min"] as num).toDouble());
  }
  Map<String, dynamic> toJson() {
    return {
      "humidity": humidity,
      "icon": icon,
      "weekday": weekday,
      "max": maxTemp,
      "min": minTemp
    };
  }
}
