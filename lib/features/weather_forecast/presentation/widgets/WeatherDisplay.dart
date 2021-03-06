import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:noobcaster/core/Lang/language_handler.dart';
import 'package:noobcaster/core/util/temp_converter.dart';
import 'package:noobcaster/core/util/time_converter.dart';
import 'package:noobcaster/features/weather_forecast/domain/entities/weather.dart';
import 'package:noobcaster/features/weather_forecast/presentation/bloc/weather_data_bloc.dart';
import 'package:noobcaster/features/weather_forecast/presentation/widgets/DataSnapshot.dart';
import 'package:noobcaster/features/weather_forecast/presentation/widgets/DetailsSnapshot.dart';
import 'package:noobcaster/features/weather_forecast/presentation/widgets/ForecastSnapshot.dart';

class WeatherDisplay extends StatefulWidget {
  final WeatherData data;
  const WeatherDisplay({Key key, @required this.data}) : super(key: key);

  @override
  _WeatherDisplayState createState() => _WeatherDisplayState();
}

class _WeatherDisplayState extends State<WeatherDisplay>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _opacityAnimation;
  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 850));
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).chain(CurveTween(curve: Curves.easeIn)).animate(_controller);
    _controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20),
        topLeft: Radius.circular(20),
      ),
      child: RefreshIndicator(
        onRefresh: () => Future.sync(() =>
            BlocProvider.of<WeatherDataBloc>(context)
                .add(RefreshWeatherDataEvent(widget.data))),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 60,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: "${widget.data.displayName}\n",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w500),
                        children: [
                          TextSpan(
                            text: formattedTime(widget.data.dateTime),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).focusColor,
                            ),
                          ),
                        ]),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SvgPicture.asset(
                    "assets/images/${widget.data.icon}.svg",
                    width: MediaQuery.of(context).size.width / 3,
                    height: MediaQuery.of(context).size.width / 3,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "${tempFromUnit(widget.data.currentTemp)}\n",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 70,
                        fontWeight: FontWeight.w100,
                      ),
                      children: [
                        TextSpan(
                          text:
                              "${translateFeelsLike()} ${tempFromUnit(widget.data.feelsLike)}\n",
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).focusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: translateDescription(widget.data.description),
                          style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).focusColor,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: DataSnapshot(
                            textUpper: translateUVDescription(),
                            textLower: translateUVLevel(widget.data.uvi),
                            icon: FaIcon(
                              FontAwesomeIcons.sun,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Center(
                          child: DataSnapshot(
                            textUpper: translateWind(),
                            textLower: "${widget.data.windspeed}m/s",
                            icon: FaIcon(
                              FontAwesomeIcons.wind,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: DataSnapshot(
                            textUpper: translateHumidity(),
                            textLower: "${widget.data.humidity}%",
                            icon: FaIcon(
                              FontAwesomeIcons.tint,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  ForecastSnapshot<HourlyWeatherData>(
                    data: widget.data.hourly,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ForecastSnapshot<DailyWeatherData>(
                    data: widget.data.daily,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  DetailsSnapshot(
                    data: widget.data,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 40),
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          (widget.data.isCached
                                  ? "${translateCached()} "
                                  : "${translateUpdated()} ") +
                              formattedTime(widget.data.dateTime),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        )),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
