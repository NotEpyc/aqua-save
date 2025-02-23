class LeakDetection {
  final double masterFlow;
  final Map<String, double> roomFlows;
  final double flowDifference;
  final bool isLeakDetected;
  final String leakStatus;

  LeakDetection({
    required this.masterFlow,
    required this.roomFlows,
    required this.flowDifference,
    required this.isLeakDetected,
    required this.leakStatus,
  });

  factory LeakDetection.fromWaterManagement(Map<String, dynamic> data) {
    final masterFlow = (data['master_flowmeter']?['flow_rate'] ?? 0.0).toDouble();
    
    final roomFlows = {
      for (String room in ['room_1', 'room_2'])
        room: (data[room]?['flow_rate'] ?? 0.0).toDouble() as double
    };

    final totalRoomFlow = roomFlows.values.fold<double>(0, (sum, flow) => sum + flow);
    final difference = (masterFlow - totalRoomFlow).abs();
    
    // Define leak threshold (e.g., 10% of master flow)
    final leakThreshold = masterFlow * 0.1;
    final isLeak = difference > leakThreshold && masterFlow > 0;

    return LeakDetection(
      masterFlow: masterFlow,
      roomFlows: roomFlows,
      flowDifference: difference,
      isLeakDetected: isLeak,
      leakStatus: _getLeakStatus(isLeak, difference, masterFlow),
    );
  }

  static String _getLeakStatus(bool isLeak, double difference, double masterFlow) {
    if (!isLeak) return 'No leaks detected';
    if (difference > masterFlow * 0.3) return 'Critical leak detected!';
    if (difference > masterFlow * 0.2) return 'Major leak detected';
    return 'Minor leak detected';
  }
}