import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aquasave/models/leak_detection.dart';
class LeakDetectionScreen extends StatelessWidget {
  const LeakDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref().child('water_management').onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        try {
          final data = Map<String, dynamic>.from(
            snapshot.data?.snapshot.value as Map? ?? {}
          );
          
          final leakDetection = LeakDetection.fromWaterManagement(data);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeakStatusCard(leakDetection),
                const SizedBox(height: 20),
                _buildFlowComparisonCard(leakDetection),
                const SizedBox(height: 20),
                _buildRoomFlowsCard(leakDetection),
              ],
            ),
          );
        } catch (e) {
          return Center(child: Text('Error processing data: $e'));
        }
      },
    );
  }

  Widget _buildLeakStatusCard(LeakDetection detection) {
    return Card(
      elevation: 4,
      child: ListTile(
        leading: Icon(
          detection.isLeakDetected ? Icons.warning : Icons.check_circle,
          color: detection.isLeakDetected ? Colors.red : Colors.green,
          size: 32,
        ),
        title: Text(
          detection.leakStatus,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: detection.isLeakDetected
            ? const Text('Immediate attention required')
            : const Text('System operating normally'),
      ),
    );
  }

  Widget _buildFlowComparisonCard(LeakDetection detection) {
    final totalRoomFlow = detection.roomFlows.values.fold<double>(
      0,
      (sum, flow) => sum + flow,
    );

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flow Comparison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Master Flow'),
              trailing: Text(
                '${detection.masterFlow.toStringAsFixed(2)} L/min',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('Total Room Flow'),
              trailing: Text(
                '${totalRoomFlow.toStringAsFixed(2)} L/min',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              title: const Text('Difference'),
              trailing: Text(
                '${detection.flowDifference.toStringAsFixed(2)} L/min',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: detection.isLeakDetected ? Colors.red : Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomFlowsCard(LeakDetection detection) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Room Flow Rates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...detection.roomFlows.entries.map((entry) => ListTile(
              title: Text('Room ${entry.key.split('_')[1]}'),
              trailing: Text(
                '${entry.value.toStringAsFixed(2)} L/min',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )),
          ],
        ),
      ),
    );
  }
}