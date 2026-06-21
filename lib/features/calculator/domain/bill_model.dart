import 'dart:convert';
import 'package:equatable/equatable.dart';

class BillModel extends Equatable {
  final String id;
  final DateTime date;
  final String expression;
  final String finalTime;
  final double rate;
  final double amount;

  const BillModel({
    required this.id,
    required this.date,
    required this.expression,
    required this.finalTime,
    required this.rate,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'expression': expression,
      'finalTime': finalTime,
      'rate': rate,
      'amount': amount,
    };
  }

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      expression: json['expression'] as String,
      finalTime: json['finalTime'] as String,
      rate: (json['rate'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
    );
  }

  static String encodeList(List<BillModel> bills) {
    return jsonEncode(bills.map((b) => b.toJson()).toList());
  }

  static List<BillModel> decodeList(String jsonString) {
    if (jsonString.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.map((item) => BillModel.fromJson(item)).toList();
  }

  @override
  List<Object?> get props => [id, date, expression, finalTime, rate, amount];
}
