import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aquasave/models/room_usage.dart';
import 'package:aquasave/theme/theme.dart';

class RoomUsageScreen extends StatefulWidget {
  final String roomId;
  
  const RoomUsageScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<RoomUsageScreen> createState() => _RoomUsageScreenState();
}

class _RoomUsageScreenState extends State<RoomUsageScreen> {
  String _selectedPeriod = 'daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${widget.roomId.split('_')[1]} Usage'),
        backgroundColor: lightColorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance
            .ref()
            .child('water_management/${widget.roomId}/usage')
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Database Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          try {
            final dynamic rawData = snapshot.data?.snapshot.value;
            if (rawData == null || !(rawData is Map)) {
              return const Center(child: Text('No data available'));
            }

            // Fix the type casting
            final Map<Object?, Object?> dataMap = rawData as Map<Object?, Object?>;
            final roomUsage = RoomUsage.fromJson(
              widget.roomId,
              dataMap.cast<String, dynamic>()
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 20),
                  _buildUsageChart(roomUsage),
                  const SizedBox(height: 20),
                  _buildUsageStats(roomUsage),
                ],
              ),
            );
          } catch (e, stackTrace) {
            print('Error processing room usage data: $e');
            print('Stack trace: $stackTrace');
            return Center(child: Text('Error: $e'));
          }
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Period',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'daily', label: Text('Daily')),
                ButtonSegment(value: 'weekly', label: Text('Weekly')),
                ButtonSegment(value: 'monthly', label: Text('Monthly')),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _selectedPeriod = selection.first;
                });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return lightColorScheme.primary;
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageChart(RoomUsage roomUsage) {
    final usageData = switch (_selectedPeriod) {
      'daily' => roomUsage.dailyUsage,
      'weekly' => roomUsage.weeklyUsage,
      'monthly' => roomUsage.monthlyUsage,
      _ => roomUsage.dailyUsage,
    };

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Over Time',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= usageData.length) return const Text('');
                          final date = usageData[value.toInt()].timestamp;
                          return Text(
                            '${date.day}/${date.month}',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()} L',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: usageData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.usage,
                        );
                      }).toList(),
                      isCurved: true,
                      color: lightColorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: lightColorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageStats(RoomUsage roomUsage) {
    final usageData = switch (_selectedPeriod) {
      'daily' => roomUsage.dailyUsage,
      'weekly' => roomUsage.weeklyUsage,
      'monthly' => roomUsage.monthlyUsage,
      _ => roomUsage.dailyUsage,
    };

    final totalUsage = usageData.fold<double>(
      0,
      (sum, data) => sum + data.usage,
    );

    final averageUsage = usageData.isEmpty ? 0 : totalUsage / usageData.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatRow('Total Usage', '${totalUsage.toStringAsFixed(2)} L'),
            _buildStatRow(
              'Average Usage',
              '${averageUsage.toStringAsFixed(2)} L/${_selectedPeriod}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}