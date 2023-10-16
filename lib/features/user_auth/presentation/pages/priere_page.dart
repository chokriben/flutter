import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class PrayerTimeService {
  Future<Map<String, dynamic>> getPrayerTimes(String city, String country, DateTime date) async {
    try {
      final formattedDate = "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";

      final apiUrl = "https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&date=$formattedDate&method=2"; // Ajout du paramètre 'method=2' pour le calcul précis du lever et du coucher du soleil.

      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Impossible de récupérer les heures de prière. Code de statut : ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Impossible de récupérer les heures de prière. Erreur : $e');
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PrayerTimeScreen(),
    );
  }
}

class PrayerTimeScreen extends StatefulWidget {
  @override
  _PrayerTimeScreenState createState() => _PrayerTimeScreenState();
}

class _PrayerTimeScreenState extends State<PrayerTimeScreen> {
  final PrayerTimeService prayerTimeService = PrayerTimeService();
  TextEditingController cityController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  Map<String, dynamic> prayerTimes = {};

  fetchPrayerTimes() async {
    final data = await prayerTimeService.getPrayerTimes(cityController.text, 'Tunisia', selectedDate);
    setState(() {
      prayerTimes = data['data']['timings'];
    });
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Heures de prière'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Sélectionnez une ville et une date :'),
            TextFormField(
              controller: cityController,
              decoration: InputDecoration(labelText: 'Ville'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Date : '),
                TextButton(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          selectedDate = value;
                        });
                      }
                    });
                  },
                  child: Text(
                    "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: fetchPrayerTimes,
              child: Text("Obtenir les heures de prière"),
            ),
            if (prayerTimes.isNotEmpty)
              Column(
                children: [
                  Text('Heures de prière pour ${cityController.text} le ${selectedDate.toLocal()} :'),
                  for (var key in prayerTimes.keys)
                    Text('$key : ${prayerTimes[key]}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
