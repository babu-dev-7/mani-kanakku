import 'bill_model.dart';

abstract class CalculatorRepository {
  Future<double> getRate();
  Future<void> saveRate(double rate);
  Future<List<BillModel>> getHistory();
  Future<void> saveHistory(List<BillModel> history);
  Future<void> addBill(BillModel bill);
  Future<void> deleteBill(String id);
  Future<void> clearHistory();
  Future<String> getLanguage();
  Future<void> saveLanguage(String languageCode);
  Future<bool> getAmountEnabled();
  Future<void> saveAmountEnabled(bool enabled);
}
