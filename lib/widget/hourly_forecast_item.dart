import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {
   final IconData icon; final String time; final String temperature;
  const HourlyForecastItem({super.key, required this.icon, required this.time, required this.temperature});

  @override
  Widget build(BuildContext context) {
    return  Card( 
      elevation: 6,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis,), const SizedBox(height: 8,),
            Icon(icon, size: 32), const SizedBox(height: 8,),
            Text(temperature, style: const TextStyle(fontSize: 12),), const SizedBox(height: 8,),
          ],
        ),
      ),
    );          
  }
}