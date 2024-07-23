import 'package:flutter/material.dart';

class CityNameScreen extends StatelessWidget {
  CityNameScreen({super.key});

  final TextEditingController _cityTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("City Name"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _cityTextEditingController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter city name',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_cityTextEditingController.text.isNotEmpty) {
                final cityName = _cityTextEditingController.text;
                Navigator.of(context).pop(cityName);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Text("Get City Weather"),
          ),
        ],
      ),
    );
  }
}
