import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseReference _historyRef =
  FirebaseDatabase.instance.ref('sensor/history');

  List<HistoryData> _historyList = [];
  bool _isLoading = true;
  String _filterType = 'all'; // all, hot, normal, cold

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    _historyRef.limitToLast(50).onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final List<HistoryData> tempList = [];

        data.forEach((key, value) {
          tempList.add(HistoryData(
            timestamp: int.parse(key),
            temperature: (value as num).toDouble(),
          ));
        });

        tempList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        setState(() {
          _historyList = tempList;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  List<HistoryData> get _filteredHistory {
    if (_filterType == 'all') return _historyList;

    return _historyList.where((data) {
      if (_filterType == 'hot') return data.temperature > 30;
      if (_filterType == 'normal') return data.temperature >= 25 && data.temperature <= 30;
      if (_filterType == 'cold') return data.temperature < 25;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterChips(),
            Expanded(child: _buildHistoryList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Temperature History',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_filteredHistory.length} records found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: Colors.blue[700],
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all', Icons.list_rounded),
            const SizedBox(width: 8),
            _buildFilterChip('Hot', 'hot', Icons.local_fire_department_rounded),
            const SizedBox(width: 8),
            _buildFilterChip('Normal', 'normal', Icons.check_circle_rounded),
            const SizedBox(width: 8),
            _buildFilterChip('Cold', 'cold', Icons.ac_unit_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _filterType == value;
    return GestureDetector(
      onTap: () => setState(() => _filterType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No history data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Temperature readings will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredHistory.length,
      itemBuilder: (context, index) {
        final data = _filteredHistory[index];
        return _buildHistoryCard(data, index);
      },
    );
  }

  Widget _buildHistoryCard(HistoryData data, int index) {
    final condition = _getCondition(data.temperature);
    final datetime = DateTime.fromMillisecondsSinceEpoch(data.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: condition['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              condition['icon'],
              color: condition['color'],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.temperature.toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(datetime),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: condition['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              condition['label'],
              style: TextStyle(
                color: condition['color'],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCondition(double temp) {
    if (temp < 25) {
      return {
        'label': 'Cold',
        'color': Colors.blue,
        'icon': Icons.ac_unit_rounded,
      };
    } else if (temp <= 30) {
      return {
        'label': 'Normal',
        'color': Colors.green,
        'icon': Icons.check_circle_rounded,
      };
    } else {
      return {
        'label': 'Hot',
        'color': Colors.orange,
        'icon': Icons.local_fire_department_rounded,
      };
    }
  }
}

class HistoryData {
  final int timestamp;
  final double temperature;

  HistoryData({required this.timestamp, required this.temperature});
}