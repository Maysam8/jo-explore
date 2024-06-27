import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widget/config.dart';  // Import the configuration file

class WeatherScreen extends StatefulWidget {
  final String governorateName;

  WeatherScreen({required this.governorateName});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  var weatherData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=${widget.governorateName},JO&appid=$openWeatherMapApiKey&units=metric'));

      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load weather data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather in ${widget.governorateName}'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : _buildWeatherInfo(),
    );
  }

  Widget _buildWeatherInfo() {
    /*final weatherMain = weatherData['weather'][0]['main'];*/
    final weatherDescription = weatherData['weather'][0]['description'];
    final temperature = weatherData['main']['temp'];
    final iconCode = weatherData['weather'][0]['icon'];

    return Container(
      color: Colors.blueGrey.shade900,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildWeatherIcon(iconCode),
          SizedBox(height: 20),
          Text(
            '$temperature°C',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            weatherDescription,
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherIcon(String iconCode) {
    return Image.network(
      'https://openweathermap.org/img/wn/$iconCode.png',
      width: 100,
      height: 100,
    );
  }
}