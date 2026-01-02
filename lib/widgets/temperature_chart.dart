import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TemperatureChart extends StatelessWidget {
  final Map history;

  const TemperatureChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    int i = 0;

    history.forEach((key, value) {
      spots.add(FlSpot(i.toDouble(), value.toDouble()));
      i++;
    });

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: false),
              color: Colors.orangeAccent,
            ),
          ],
        ),
      ),
    );
  }
}
