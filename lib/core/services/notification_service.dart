import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Hàm này phải nằm ngoài class (theo yêu cầu của Firebase)
// để xử lý thông báo khi app đang ở trạng thái terminated (bị đóng hoàn toàn)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Bạn có thể xử lý data ở đây nếu cần
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications;

  NotificationService(this._fcm, this._localNotifications);

  Future<void> init() async {
    // 1. Khởi tạo Local Notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
          'notification_icon',
        ); // Tên file icon của bạn

    // (Cấu hình cho iOS - bỏ qua nếu chỉ test Android)
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // 2. Lắng nghe thông báo khi app đang ở FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Hiển thị thông báo local
        _showLocalNotification(message);
      }
    });

    // 3. Lắng nghe khi app ở BACKGROUND (bấm vào thông báo)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // (Bạn có thể điều hướng đến một trang cụ thể ở đây)
    });

    // 4. Lắng nghe khi app bị TERMINATED (bấm vào thông báo)
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        print('App opened from terminated state by a notification!');
        // (Bạn có thể điều hướng đến một trang cụ thể ở đây)
      }
    });

    // 5. Đăng ký hàm xử lý background (phải gọi sau cùng)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Hàm private để hiển thị thông báo local
  void _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'your_channel_id', // ID của channel
          'Your Channel Name', // Tên channel
          channelDescription: 'Mô tả channel',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'notification_icon', // Tên file icon
        );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
    );
  }
}
