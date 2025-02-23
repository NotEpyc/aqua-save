import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:aquasave/models/billing.dart';
import 'package:intl/intl.dart';

class BillingScreen extends StatelessWidget {
  BillingScreen({super.key});

  // Add currency formatter for INR
  final currencyFormat = NumberFormat.currency(
    symbol: '₹',
    locale: 'en_IN',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance
          .ref()
          .child('water_management/master_flowmeter/total_usage')
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final totalUsage = (snapshot.data?.snapshot.value as num?)?.toDouble() ?? 0.0;
        final currentBill = WaterBill(
          totalUsage: totalUsage,
          ratePerLiter: 0.05, // INR 0.05 per liter (adjust as needed)
          billingDate: DateTime.now(),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Current Usage Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Usage',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.water_drop),
                        title: const Text('Total Water Usage'),
                        trailing: Text(
                          '${currentBill.totalUsage.toStringAsFixed(2)} L',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Billing Summary Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Billing Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Rate per Liter'),
                        trailing: Text(
                          currencyFormat.format(currentBill.ratePerLiter),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16  
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text('Total Amount'),
                        trailing: Text(
                          currencyFormat.format(currentBill.totalAmount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      ListTile(
                        title: const Text('Billing Date'),
                        trailing: Text(
                          DateFormat('MMM d, y').format(currentBill.billingDate),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}