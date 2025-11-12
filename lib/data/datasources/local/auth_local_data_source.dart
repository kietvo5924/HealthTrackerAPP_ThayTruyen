import 'package:health_tracker_app/core/error/failures.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
}

// ignore: constant_identifier_names
const CACHED_AUTH_TOKEN = 'auth_token';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheToken(String token) async {
    try {
      await sharedPreferences.setString(CACHED_AUTH_TOKEN, token);
    } catch (e) {
      throw CacheFailure('Không thể lưu token');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return sharedPreferences.getString(CACHED_AUTH_TOKEN);
    } catch (e) {
      throw CacheFailure('Không thể lấy token');
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      await sharedPreferences.remove(CACHED_AUTH_TOKEN);
    } catch (e) {
      throw CacheFailure('Không thể xóa token');
    }
  }
}
