import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:wheatherapp_rebuild/getcityname.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  String weather = "";
  String weatherDescription = "";
  double temperature = 0.0;
  String cityName = "Pune";
  String icon = "10d";

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((_) => _determinePosition());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        backgroundColor: Color.fromARGB(96, 198, 14, 14),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CityNameScreen(),
                ),
              );
              if (result != null && result is String && result.isNotEmpty) {
                cityName = result;
                getWeather(lat: 0, lon: 0, isCityWeather: true);
              }
            },
            icon: const Icon(Icons.location_on),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator(
                color: Colors.amber,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(weather),
                  Image.network(
                    "https://openweathermap.org/img/wn/$icon@2x.png",
                    width: 200,
                    fit: BoxFit.fitHeight,
                  ),
                  Text(
                    temperature.toString(),
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Text(weatherDescription),
                ],
              ),
      ),
    );
  }

  Future<void> _requestPermissions() async {
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final position = await Geolocator.getCurrentPosition();
    log(position.toString());
    getWeather(
        lat: position.latitude, lon: position.longitude, isCityWeather: false);
  }

  void getWeather(
      {required double lat,
      required double lon,
      required bool isCityWeather}) async {
    setState(() {
      isLoading = true;
    });

    const weatherAPIKey = "93b12671c9864e69a5163b8d5f4a31f3";
    late String weatherUrl;

    if (isCityWeather) {
      weatherUrl =
          "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$weatherAPIKey&units=metric";
    } else {
      weatherUrl =
          "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$weatherAPIKey&units=metric";
    }

    final weatherUri = Uri.parse(weatherUrl);
    final response = await http.get(weatherUri);

    if (response.statusCode == 200) {
      final decodedWeatherData = json.decode(response.body);
      weather = decodedWeatherData["weather"][0]["main"];
      weatherDescription = decodedWeatherData["weather"][0]["description"];
      icon = decodedWeatherData["weather"][0]["icon"];
      temperature = decodedWeatherData["main"]["temp"];
    } else {
      log("Failed to load weather data");
      weather = "Error";
      weatherDescription = "Could not fetch weather data";

      temperature = 0.0;
    }

    setState(() {
      isLoading = false;
    });
  }
}
