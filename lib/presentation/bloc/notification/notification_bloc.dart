import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/domain/usecases/get_notifications_usecase.dart';
import 'package:health_tracker_app/domain/usecases/get_unread_notification_count_usecase.dart';
import 'package:health_tracker_app/domain/usecases/mark_notification_read_usecase.dart';
import 'package:health_tracker_app/core/usecase/usecase.dart';

import 'notification_event.dart';
import 'notification_state.dart';

const _pageSize = 20;

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markReadUseCase;
  final GetUnreadNotificationCountUseCase _getUnreadCountUseCase;

  NotificationBloc({
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkNotificationReadUseCase markReadUseCase,
    required GetUnreadNotificationCountUseCase getUnreadCountUseCase,
  }) : _getNotificationsUseCase = getNotificationsUseCase,
       _markReadUseCase = markReadUseCase,
       _getUnreadCountUseCase = getUnreadCountUseCase,
       super(const NotificationState()) {
    on<NotificationFetched>(_onFetched);
    on<NotificationRead>(_onRead);
    on<NotificationAllRead>(_onAllRead);
    on<NotificationCountChecked>(_onCountChecked);
  }

  Future<void> _onFetched(
    NotificationFetched event,
    Emitter<NotificationState> emit,
  ) async {
    if (state.hasReachedMax) return;

    if (state.status == NotificationStatus.initial) {
      emit(state.copyWith(status: NotificationStatus.loading));
    }

    final result = await _getNotificationsUseCase(
      GetNotificationsParams(page: state.page, size: _pageSize),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotificationStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (newNotifs) {
        final allNotifs = List.of(state.notifications)..addAll(newNotifs);
        emit(
          state.copyWith(
            status: NotificationStatus.success,
            notifications: allNotifs,
            hasReachedMax: newNotifs.length < _pageSize,
            page: state.page + 1,
          ),
        );
        // Sau khi tải xong, cập nhật lại số chưa đọc
        add(NotificationCountChecked());
      },
    );
  }

  Future<void> _onRead(
    NotificationRead event,
    Emitter<NotificationState> emit,
  ) async {
    // Optimistic Update: Cập nhật UI ngay
    final updatedList = state.notifications.map((n) {
      if (n.id == event.id && !n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    // Giảm số lượng chưa đọc nếu cần
    final currentUnread =
        state.notifications.firstWhere((n) => n.id == event.id).isRead
        ? state.unreadCount
        : (state.unreadCount > 0 ? state.unreadCount - 1 : 0);

    emit(
      state.copyWith(notifications: updatedList, unreadCount: currentUnread),
    );

    // Gọi API
    await _markReadUseCase(event.id);
  }

  Future<void> _onAllRead(
    NotificationAllRead event,
    Emitter<NotificationState> emit,
  ) async {
    final updatedList = state.notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    emit(state.copyWith(notifications: updatedList, unreadCount: 0));

    // Gọi API (Bạn cần implement UseCase này nếu chưa có, hoặc dùng vòng lặp tạm)
    // await _markAllReadUseCase(NoParams());
  }

  Future<void> _onCountChecked(
    NotificationCountChecked event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _getUnreadCountUseCase(NoParams());
    result.fold(
      (l) => null,
      (count) => emit(state.copyWith(unreadCount: count)),
    );
  }
}
