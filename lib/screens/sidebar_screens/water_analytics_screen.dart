import 'package:aquasave/screens/sidebar_screens/room_usage_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aquasave/models/water_analytics.dart';

class WaterAnalyticsScreen extends StatefulWidget {
  const WaterAnalyticsScreen({super.key});

  @override
  _WaterAnalyticsScreenState createState() => _WaterAnalyticsScreenState();
}

class _WaterAnalyticsScreenState extends State<WaterAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref().child('water_management').onValue,
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

          final waterAnalytics = WaterAnalytics.fromJson(
            Map<String, dynamic>.from(rawData)
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Flow Rates
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Flow Rates',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildFlowRate(
                          'Master Flow Rate',
                          'master',
                          waterAnalytics.masterFlowmeter.flowRate,
                        ),
                        ...['room_1', 'room_2'].map((room) =>
                          _buildFlowRate(
                            'Room ${room.split('_')[1]} Flow Rate',
                            room,
                            waterAnalytics.rooms[room]?.flowRate ?? 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        } catch (e, stackTrace) {
          print('Data Processing Error: $e');
          print('Stack Trace: $stackTrace');
          return Center(child: Text('Error processing data: $e'));
        }
      },
    );
  }

  Widget _buildFlowRate(String title, String roomId, double flowRate) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        '$flowRate L/min',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        if (roomId != 'master') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomUsageScreen(roomId: roomId),
            ),
          );
        }
      },
    );
  }
}