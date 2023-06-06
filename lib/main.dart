import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  var temperature = 0.0;
  var city = "chennai";
Future fetchData() async
{
 http.Response response = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=89727fd78420e93cc55a572c11542774&units=metric'));

    var results = jsonDecode(response.body);
     
    // print(results['main']['temp']);
    setState(() {
      temperature = results['main']['temp'];
    });
    print('city: $city temp  $temperature');
}

@override
  void initState() {
    // TODO: implement initState
    var response = fetchData();
    super.initState();
  }
  Widget build(BuildContext context)
  {
return MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather',
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Align(alignment: Alignment.center,),
          Text(
            city.toString(),
            style: TextStyle(fontSize: 30,
            fontFamily: AutofillHints.location,
            fontWeight: FontWeight.bold,),
            textAlign: TextAlign.center,
            
          ),
          Text(
            temperature.toString()+ "\u00B0",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),);
  }
}


