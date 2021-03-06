import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:noobcaster/core/Lang/language_handler.dart';
import 'package:noobcaster/core/city_list.dart';
import 'package:noobcaster/core/speech_recognition/speech_recognition.dart';
import 'package:noobcaster/features/weather_forecast/presentation/bloc/weather_data_bloc.dart';
import 'package:noobcaster/injection_container.dart';

class SearchRoute extends StatefulWidget {
  const SearchRoute({Key key}) : super(key: key);

  @override
  _SearchRouteState createState() => _SearchRouteState();
}

class _SearchRouteState extends State<SearchRoute> {
  bool _isListening = false;
  TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          _titleFromState(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: _getTextFromSpeech,
              icon: Icon(
                Icons.mic,
                color: _getColorFromState(),
                size: 30,
              ),
            ),
          )
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TypeAheadField(
              suggestionsBoxDecoration: SuggestionsBoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade900,
              ),
              hideOnEmpty: true,
              textFieldConfiguration: TextFieldConfiguration(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: translateTypeSomething(),
                  hintStyle: TextStyle(color: Theme.of(context).hintColor),
                  suffix: IconButton(
                    splashColor: Colors.transparent,
                    onPressed: _clearKeyboard,
                    icon: Icon(
                      Icons.clear,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                onSubmitted: (input) =>
                    _searchLocation(input as String, context),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.text,
                autofocus: true,
              ),
              suggestionsCallback: (text) =>
                  text.isNotEmpty ? _getSuggestionText(text) : null,
              itemBuilder: (context, suggestion) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      title: suggestion["widget"] as Widget,
                    ),
                    Container(
                      color: Colors.grey[300].withOpacity(0.3),
                      height: 1,
                      width: MediaQuery.of(context).size.width - 40,
                    )
                  ],
                );
              },
              onSuggestionSelected: (suggestion) =>
                  _searchLocation(suggestion["text"] as String, context),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 52),
              child: Center(
                child: Text(
                  translateEnterALocation(),
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Iterable<Map<String, dynamic>> _getSuggestionText(String text) {
    return cityList
        .where((city) =>
            RegExp(text, caseSensitive: false).matchAsPrefix(city) != null)
        .take(10)
        .map(
          (match) => {
            "text": match,
            "widget": RichText(
              text: TextSpan(
                text: match.substring(0, text.length),
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 20,
                ),
                children: [
                  TextSpan(
                    text: match.substring(text.length),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          },
        );
  }

  void _searchLocation(String value, BuildContext context) {
    BlocProvider.of<WeatherDataBloc>(context)
        .add(GetLocationWeatherEvent(value));
    Navigator.of(context).pop();
  }

  void _clearKeyboard() {
    _controller.clear();
  }

  void _getTextFromSpeech() {
    _clearKeyboard();
    setState(() {
      _isListening = true;
    });
    sl<VoiceRecognition>().stream.listen(
      (text) {
        _controller.text = text as String;
      },
      onDone: () => setState(() => _isListening = false),
    );
    sl<VoiceRecognition>().startListening();
  }

  Color _getColorFromState() {
    if (!_isListening) {
      return Colors.white;
    }
    return Theme.of(context).accentColor;
  }

  String _titleFromState() {
    if (!_isListening) {
      return translateSearch();
    }
    return translateListening();
  }
}
