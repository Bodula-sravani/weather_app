import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(MaterialApp(
    home: Scaffold(
      body: const MyApp(),
    ),
  ));
  // runApp(MaterialApp(
  //   home: const MyApp(),
  // ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var temperature = 0.0;
  var minTemperature = 0.0;
  var maxTemperature = 0.0;
  var pressure = 0;
  var humidity = 0;
  var city = "";
  List<String> cities = ['Delhi', 'Mumbai', 'Kolkata', 'Chennai'];
  String selectedCity = 'Delhi';

  @override
  void initState() {
    print("init");
    super.initState();
    getLocationAndWeather();
  }

  Future getWeatherByCity(String cityChoosen) async {
    final apiKey = dotenv.env['API_KEY'];
    http.Response response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$cityChoosen&appid=$apiKey&units=metric'));
    var results = jsonDecode(response.body);
    print("get wea by city");
    // print(results['main']['temp']);
    setState(() {
      city = results['name'];
      temperature = results['main']['temp'];
      minTemperature = results['main']['temp_min'];
      maxTemperature = results['main']['temp_max'];
      pressure = results['main']['pressure'];
      humidity = results['main']['humidity'];
    });
    print('temp: $temperature');
    print('city: $city');
  }

  Future getWeather(double latitude, double longitude) async {
    final apiKey = dotenv.env['API_KEY'];

    http.Response response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric'));

    var results = jsonDecode(response.body);
    setState(() {
      temperature = results['main']['temp'];
      city = results['name'];
      minTemperature = results['main']['temp_min'];
      maxTemperature = results['main']['temp_max'];
      pressure = results['main']['pressure'];
      humidity = results['main']['humidity'];
    });
    print('temp: $temperature');
    print('city: $city');
  }

  Future<void> getLocationAndWeather() async {
    final permissionStatus = await Permission.locationWhenInUse.request();
    print("loc and wea");
    if (permissionStatus.isGranted) {
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        getWeather(position.latitude, position.longitude);
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print("denied the permissionnn");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Location permission denied'),
          duration: const Duration(seconds: 2),
        ),
      );
      // showDialog(
      //   context: context,
      //   builder: (context) => AlertDialog(
      //     title: const Text('Location Permission Denied'),
      //     content: const Text(
      //         'You have denied the location permission. Please enable it to fetch the weather.'),
      //     actions: [
      //       TextButton(
      //         onPressed: () => Navigator.pop(context),
      //         child: const Text('OK'),
      //       ),
      //     ],
      //   ),
      // );
    }
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Weather'),
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedCity,
              hint: const Text('Select a city'),
              dropdownColor: Colors.lightBlueAccent,
              style: const TextStyle(
                color: Color.fromARGB(255, 8, 0, 0),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              items: cities.map((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCity = newValue!;
                  getWeatherByCity(selectedCity);
                });
              },
            ),
            Text(
              city.toString(),
              style: const TextStyle(
                fontSize: 30,
                fontFamily: AutofillHints.location,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              temperature.toStringAsFixed(1) + "\u00B0",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Card(
              margin: const EdgeInsets.all(10),
              color: Colors.lightBlueAccent,
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: const Text(
                      'Temperature',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      'Min: ' +
                          minTemperature.toStringAsFixed(1) +
                          "\u00B0" +
                          "\nMax: " +
                          maxTemperature.toStringAsFixed(1) +
                          "\u00B0",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Pressure',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      pressure.toString() + " hPa",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ListTile(
                    title: const Text(
                      'Humidity',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      humidity.toString() + "%",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: getLocationAndWeather,
              child: Text('Get Current Location Weather'),
              style: ElevatedButton.styleFrom(
                primary: Colors.lightBlueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
