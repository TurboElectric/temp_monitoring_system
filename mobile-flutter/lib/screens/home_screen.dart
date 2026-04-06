import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../services/mqtt_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> sensors = [];

  @override
  void initState() {
    super.initState();
    MqttService.instance.connect().then((_) {
      MqttService.instance.stream.listen((data) {
        setState(() {
          sensors = data['sensors'];
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Температура двигателей')),
      body: ListView.builder(
        itemCount: sensors.length,
        itemBuilder: (context, index) {
          var s = sensors[index];
          Color color = s['temp'] > 80 ? Colors.red : Colors.green;
          return ListTile(
            title: Text('Датчик ${s['id']}'),
            subtitle: Text('${s['temp']} °C'),
            trailing: Icon(Icons.circle, color: color },
      ),
    );
  }
}