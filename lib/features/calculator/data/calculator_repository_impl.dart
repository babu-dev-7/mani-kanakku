import 'package:shared_preferences/shared_preferences.dart';
import '../domain/bill_model.dart';
import '../domain/calculator_repository.dart';

class CalculatorRepositoryImpl implements CalculatorRepository {
  final SharedPreferences _prefs;

  static const String _rateKey = 'mk_rate';
  static const String _historyKey = 'mk_history';
  static const String _languageKey = 'mk_language';
  static const String _amountEnabledKey = 'mk_amount_enabled';
  static const double _defaultRate = 1500.0;

  CalculatorRepositoryImpl(this._prefs);

  @override
  Future<double> getRate() async {
    return _prefs.getDouble(_rateKey) ?? _defaultRate;
  }

  @override
  Future<void> saveRate(double rate) async {
    await _prefs.setDouble(_rateKey, rate);
  }

  @override
  Future<List<BillModel>> getHistory() async {
    final jsonString = _prefs.getString(_historyKey) ?? '';
    return BillModel.decodeList(jsonString);
  }

  @override
  Future<void> saveHistory(List<BillModel> history) async {
    await _prefs.setString(_historyKey, BillModel.encodeList(history));
  }

  @override
  Future<void> addBill(BillModel bill) async {
    final history = await getHistory();
    history.insert(0, bill);
    await saveHistory(history);
  }

  @override
  Future<void> deleteBill(String id) async {
    final history = await getHistory();
    history.removeWhere((bill) => bill.id == id);
    await saveHistory(history);
  }

  @override
  Future<void> clearHistory() async {
    await _prefs.remove(_historyKey);
  }

  @override
  Future<String> getLanguage() async {
    return _prefs.getString(_languageKey) ?? 'en';
  }

  @override
  Future<void> saveLanguage(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
  }

  @override
  Future<bool> getAmountEnabled() async {
    return _prefs.getBool(_amountEnabledKey) ?? true;
  }

  @override
  Future<void> saveAmountEnabled(bool enabled) async {
    await _prefs.setBool(_amountEnabledKey, enabled);
  }
}
