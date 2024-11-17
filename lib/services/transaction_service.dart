
import 'package:dio/dio.dart';

class TransactionService {
  final Dio _dio = Dio();

  Future<List<Transaction>> fetchTransactions() async {
    try {
      final response = await _dio.get('https://taximeter.onrender.com/payment/transactions');
      List<dynamic> transactionsJson = response.data['transactions'];
      return transactionsJson.map((json) => Transaction.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load transactions');
    }
  }
}

class Transaction {
  final int id;
  final String name;
  final DateTime createdAt;
  final double amount;
  final String phoneNumber;
  final DateTime validUntil;

  Transaction({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.amount,
    required this.phoneNumber,
    required this.validUntil,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    DateTime createdAt = DateTime.parse(json['createdAt']);
    return Transaction(
      id: json['id'],
      name: json['name'],
      createdAt: createdAt,
      amount: double.parse(json['amount']),
      phoneNumber: json['phoneNumber'] ?? 'N/A',
      validUntil: createdAt.add(Duration(days: 30)), // Add 1 month to createdAt
    );
  }
}
