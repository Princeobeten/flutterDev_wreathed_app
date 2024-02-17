import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'secrets.dart';
import 'widget/hourly_forecast_item.dart';
import 'widget/additonal_info_item.dart';
import 'package:http/http.dart' as http;

String cityName='';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  
  IconData customIcon = Icons.light_mode;  
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async{
    try {
      cityName = "Nigeria";
      final res = await http.get(Uri.parse("http://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey"));
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw "An unexpected error occurred";
      } return data;

    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // App Title 
        title: const Text('Weather App', style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ), centerTitle: true,

      // Icon on title bar
        actions: [ 
          IconButton(
            onPressed: () { 
              setState(() {
                weather = getCurrentWeather();
              });
             },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      // App Body
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentAirSpeed = currentWeatherData['wind']['speed'];

          return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column( //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          
                // Main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text('$cityName - $currentTemp K', style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 32,
                              ),), 
                              const SizedBox(height: 16,),
                                        
                              Icon(currentSky == 'Clouds' || currentSky == 'Rain' ? Icons.cloud : Icons.snowing, size: 64,),
                              const SizedBox(height: 16,),
                          
                              Text(currentSky, style: const TextStyle(fontSize: 20),),
                              const SizedBox(height: 16,),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ), const SizedBox(height: 20,),
            
                // Hourly forecast cards
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Hourly Forecast", style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24,
                    ),
                  ),
                ), const SizedBox(height: 10,),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final hourlyForecastData = data['list'][index];
                      final time = DateTime.parse(hourlyForecastData['dt_txt']);
                      return HourlyForecastItem( 
                        icon: hourlyForecastData['weather'][0]['main'] == "Clouds" || hourlyForecastData['weather'][0]['main'] == 'Rain' ? Icons.cloud :  Icons.snowing,
                        time: DateFormat.jm().format(time) ,
                        temperature: hourlyForecastData['main']['temp'].toString()
                      );
                    },
                  ),
                ), const SizedBox(height: 20,),
            
                // Additonal Info cards
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Additional Information", style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24,
                    ),
                  ),
                ), const SizedBox(height: 16,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem(icon: Icons.water_drop_sharp, label: "Humidity", value: currentHumidity.toString(),),
                    AdditionalInfoItem(icon: Icons.air, label: "Air speed", value: currentAirSpeed.toString()),
                    AdditionalInfoItem(icon: Icons.beach_access_sharp, label: "Pressure", value: currentPressure.toString(),),
                  ],
                ),
              ],
            ),
          ),
        );
        },
      ),
    );
  }
}