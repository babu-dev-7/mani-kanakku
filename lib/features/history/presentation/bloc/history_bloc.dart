import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../calculator/domain/calculator_repository.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final CalculatorRepository repository;

  HistoryBloc({required this.repository}) : super(const HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<DeleteBill>(_onDeleteBill);
    on<ClearAllHistory>(_onClearAllHistory);
    on<ShareBill>(_onShareBill);
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    final bills = await repository.getHistory();
    emit(HistoryLoaded(bills));
  }

  Future<void> _onDeleteBill(
    DeleteBill event,
    Emitter<HistoryState> emit,
  ) async {
    await repository.deleteBill(event.id);
    final bills = await repository.getHistory();
    emit(HistoryLoaded(bills));
  }

  Future<void> _onClearAllHistory(
    ClearAllHistory event,
    Emitter<HistoryState> emit,
  ) async {
    await repository.clearHistory();
    emit(const HistoryLoaded([]));
  }

  Future<void> _onShareBill(
    ShareBill event,
    Emitter<HistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is HistoryLoaded &&
        event.index < currentState.bills.length) {
      final bill = currentState.bills[event.index];
      final shareText = '''
Mani Kanakku - Bill
━━━━━━━━━━━━━━━━
${bill.expression}
Rate: ₹${bill.rate.toInt()}/hr
Amount: ₹${bill.amount.toStringAsFixed(2)}
━━━━━━━━━━━━━━━━''';
      await Share.share(shareText);
    }
  }
}
