import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/info_card.dart';
import '../widgets/condition_badge.dart';
import '../widgets/temperature_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff667eea), Color(0xff764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder(
            stream: service.streamSensor(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              final data = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "🌡 Smart Room Monitoring",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 30),
                    InfoCard(
                      title: "Temperature",
                      value: "${data.temperature} °C",
                      icon: Icons.thermostat,
                    ),
                    InfoCard(
                      title: "Humidity",
                      value: "${data.humidity} %",
                      icon: Icons.water_drop,
                    ),
                    TemperatureChart(history: data.history),
                    const SizedBox(height: 20),
                    ConditionBadge(condition: data.condition),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
