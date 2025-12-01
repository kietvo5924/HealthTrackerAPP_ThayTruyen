import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/notification/notification_bloc.dart';
import 'package:health_tracker_app/presentation/bloc/notification/notification_event.dart';
import 'package:health_tracker_app/presentation/bloc/notification/notification_state.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationBloc>().add(NotificationRefreshed());
    });
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<NotificationBloc>().add(NotificationFetched());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Đánh dấu tất cả đã đọc',
            onPressed: () {
              context.read<NotificationBloc>().add(NotificationAllRead());
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading &&
              state.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.notifications.isEmpty) {
            return const Center(child: Text('Bạn chưa có thông báo nào'));
          }

          return ListView.separated(
            controller: _scrollController,
            itemCount: state.hasReachedMax
                ? state.notifications.length
                : state.notifications.length + 1,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index >= state.notifications.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final notif = state.notifications[index];
              return Container(
                color: notif.isRead
                    ? Colors.white
                    // ignore: deprecated_member_use
                    : Colors.blue.withOpacity(0.05),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getIconColor(notif.type),
                    child: Icon(_getIcon(notif.type), color: Colors.white),
                  ),
                  title: Text(
                    notif.title,
                    style: TextStyle(
                      fontWeight: notif.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(notif.body),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM HH:mm').format(notif.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  onTap: () {
                    if (!notif.isRead) {
                      context.read<NotificationBloc>().add(
                        NotificationRead(notif.id),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'ACHIEVEMENT':
        return Icons.emoji_events;
      case 'SOCIAL':
        return Icons.people;
      case 'REMINDER':
        return Icons.alarm;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'ACHIEVEMENT':
        return Colors.amber;
      case 'SOCIAL':
        return Colors.blue;
      case 'REMINDER':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
