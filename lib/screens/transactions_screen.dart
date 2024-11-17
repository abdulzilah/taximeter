import 'package:flutter/material.dart';
import 'package:taximeter_project/services/transaction_service.dart';
import 'package:taximeter_project/utils/colors.dart';

class TransactionPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late Future<List<Transaction>> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = TransactionService().fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _transactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No transactions available.'));
          }

          final transactions = snapshot.data!;
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              return TransactionCard(transaction: transactions[index]);
            },
          );
        },
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 5,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: coloringThemes.primary),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${transaction.name}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: coloringThemes.containers),
                ),
                SizedBox(height: 8),
                Text(
                  'Created At: ${transaction.createdAt.year}/${transaction.createdAt.month}/${transaction.createdAt.day}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: coloringThemes.containers),
                ),
                SizedBox(height: 8),
                Text(
                  'Valid Until: ${transaction.validUntil.year}/${transaction.validUntil.month}/${transaction.validUntil.day}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: coloringThemes.containers),
                ),
                SizedBox(height: 8),
                Text(
                  'Amount: \$${transaction.amount.toStringAsFixed(2)} (excluding fees)',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: coloringThemes.containers),
                ),
                SizedBox(height: 8),
                Text(
                  'Phone Number: ${transaction.phoneNumber}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: coloringThemes.containers),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
