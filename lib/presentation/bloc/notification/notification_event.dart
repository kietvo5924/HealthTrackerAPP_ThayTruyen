import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object> get props => [];
}

// Tải danh sách thông báo (hỗ trợ phân trang)
class NotificationFetched extends NotificationEvent {}

// Đánh dấu 1 thông báo đã đọc
class NotificationRead extends NotificationEvent {
  final int id;
  const NotificationRead(this.id);
  @override
  List<Object> get props => [id];
}

// Đánh dấu tất cả đã đọc
class NotificationAllRead extends NotificationEvent {}

// Kiểm tra số lượng chưa đọc (để hiện chấm đỏ)
class NotificationCountChecked extends NotificationEvent {}
