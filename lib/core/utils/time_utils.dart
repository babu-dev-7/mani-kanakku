import 'package:equatable/equatable.dart';

class TimeValue extends Equatable {
  final int hours;
  final int minutes;

  const TimeValue(this.hours, this.minutes);

  const TimeValue.zero() : hours = 0, minutes = 0;

  int get totalMinutes => (hours * 60) + minutes;

  bool get isZero => hours == 0 && minutes == 0;

  factory TimeValue.fromMinutes(int totalMinutes) {
    if (totalMinutes < 0) totalMinutes = 0;
    return TimeValue(totalMinutes ~/ 60, totalMinutes % 60);
  }

  @override
  List<Object?> get props => [hours, minutes];
}

class TimeUtils {
  TimeUtils._();

  static TimeValue parseTimeInput(String raw) {
    if (raw.isEmpty) return const TimeValue.zero();

    final cleaned = raw.replaceAll(':', '');
    if (cleaned.isEmpty) return const TimeValue.zero();

    final digits = int.tryParse(cleaned);
    if (digits == null) return const TimeValue.zero();

    int hours;
    int minutes;

    if (cleaned.length <= 2) {
      hours = 0;
      minutes = digits;
    } else {
      final minuteStr = cleaned.substring(cleaned.length - 2);
      final hourStr = cleaned.substring(0, cleaned.length - 2);
      minutes = int.tryParse(minuteStr) ?? 0;
      hours = int.tryParse(hourStr) ?? 0;
    }

    if (minutes >= 60) {
      hours += minutes ~/ 60;
      minutes = minutes % 60;
    }

    return TimeValue(hours, minutes);
  }

  static String formatRawInput(String raw) {
    final cleaned = raw.replaceAll(':', '');
    if (cleaned.isEmpty) return '0:00';

    if (cleaned.length <= 2) {
      return '0:${cleaned.padLeft(2, '0')}';
    }

    final minuteStr = cleaned.substring(cleaned.length - 2);
    final hourStr = cleaned.substring(0, cleaned.length - 2);
    return '$hourStr:$minuteStr';
  }

  static TimeValue addTime(TimeValue a, TimeValue b) {
    return TimeValue.fromMinutes(a.totalMinutes + b.totalMinutes);
  }

  static TimeValue subtractTime(TimeValue a, TimeValue b) {
    final result = a.totalMinutes - b.totalMinutes;
    return TimeValue.fromMinutes(result < 0 ? 0 : result);
  }

  static String formatTime(TimeValue t) {
    return '${t.hours}:${t.minutes.toString().padLeft(2, '0')}';
  }

  static String formatTimeForDisplay(TimeValue t) {
    return formatTime(t);
  }
}
