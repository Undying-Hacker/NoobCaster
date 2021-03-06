import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:noobcaster/core/error/exceptions.dart';
import 'package:noobcaster/core/util/time_zone_handler.dart';
import 'package:noobcaster/features/weather_forecast/data/models/weather_forcast_model.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:noobcaster/keys/key.dart';

abstract class RemoteWeatherDataSource {
  Future<WeatherDataModel> getLocalWeatherData(Placemark placemark);
  Future<WeatherDataModel> getLocationWeatherData(Placemark placemark);
}

class RemoteWeatherDataSourceImpl implements RemoteWeatherDataSource {
  final http.Client client;
  final TimezoneHandler timezoneHandler;
  RemoteWeatherDataSourceImpl(
      {@required this.client, @required this.timezoneHandler});
  @override
  Future<WeatherDataModel> getLocalWeatherData(Placemark placemark) async {
    final displayName =
        _getValidDisplayName(placemark.locality, placemark.name);
    final response = await _responseFromServer(placemark.position);
    if (response.statusCode == 200) {
      return WeatherDataModel.fromServerJsonWithTimezone(
        json.decode(response.body) as Map<String, dynamic>,
        displayName: displayName,
        handler: timezoneHandler,
        isLocal: true,
      );
    }
    throw ServerError();
  }

  @override
  Future<WeatherDataModel> getLocationWeatherData(Placemark placemark) async {
    final displayName =
        _getValidDisplayName(placemark.locality, placemark.name);
    final response = await _responseFromServer(placemark.position);
    if (response.statusCode == 200) {
      return WeatherDataModel.fromServerJsonWithTimezone(
        json.decode(response.body) as Map<String, dynamic>,
        displayName: displayName,
        handler: timezoneHandler,
        isLocal: false,
      );
    }
    throw ServerError();
  }

  String _getValidDisplayName(String locality, String name) {
    if (locality.isNotEmpty) {
      return locality;
    } else if (name.isNotEmpty) {
      return name;
    }
    return "Unknown";
  }

  Future<http.Response> _responseFromServer(Position position) async {
    return client.get(
      Uri.http("api.openweathermap.org", "/data/2.5/onecall", {
        "lon": position.longitude.toString(),
        "lat": position.latitude.toString(),
        "appid": API_KEY,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
