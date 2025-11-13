part of 'statistics_bloc.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object> get props => [];
}

// Event để tải dữ liệu (mặc định là 7 ngày qua)
class StatisticsFetched extends StatisticsEvent {
  final DateTime endDate; // Ngày cuối (thường là hôm nay)
  final int days; // Số ngày (ví dụ: 7)

  const StatisticsFetched({required this.endDate, this.days = 7});
}

class StatisticsDaysChanged extends StatisticsEvent {
  final int days;
  const StatisticsDaysChanged(this.days);

  @override
  List<Object> get props => [days];
}
