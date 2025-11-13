// File này dùng để tạo JSON body gửi lên API PUT /api/users/me/notification-settings
class NotificationSettingsRequestModel {
  final bool remindWater;
  final bool remindSleep;

  NotificationSettingsRequestModel({
    required this.remindWater,
    required this.remindSleep,
  });

  Map<String, dynamic> toJson() {
    return {'remindWater': remindWater, 'remindSleep': remindSleep};
  }
}
