import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistory extends HistoryEvent {
  const LoadHistory();
}

class DeleteBill extends HistoryEvent {
  final String id;
  const DeleteBill(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearAllHistory extends HistoryEvent {
  const ClearAllHistory();
}

class ShareBill extends HistoryEvent {
  final int index;
  const ShareBill(this.index);

  @override
  List<Object?> get props => [index];
}
