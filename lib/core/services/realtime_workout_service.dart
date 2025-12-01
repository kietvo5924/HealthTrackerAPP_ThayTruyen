import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:health_tracker_app/domain/entities/workout_realtime_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class RealtimeWorkoutService {
  RealtimeWorkoutService(this._dio, this._sharedPreferences);

  final Dio _dio;
  final SharedPreferences _sharedPreferences;
  final StreamController<WorkoutRealtimeUpdate> _controller =
      StreamController<WorkoutRealtimeUpdate>.broadcast();

  StompClient? _stompClient;
  bool _subscribed = false;

  Stream<WorkoutRealtimeUpdate> get updates {
    _ensureConnection();
    return _controller.stream;
  }

  void disconnect() {
    _stompClient?.deactivate();
    _stompClient = null;
    _subscribed = false;
  }

  void _ensureConnection() {
    if (_stompClient != null) {
      if (!_subscribed) {
        _subscribe();
      }
      return;
    }

    final baseUrl = _dio.options.baseUrl;
    if (baseUrl.isEmpty) {
      debugPrint('[RealtimeWorkoutService] Missing base URL for websocket');
      return;
    }

    final restUri = Uri.parse(baseUrl);
    final scheme = restUri.scheme == 'https' ? 'wss' : 'ws';
    final wsUri = restUri.replace(path: 'ws', scheme: scheme);

    final token = _sharedPreferences.getString('auth_token');
    final headers = <String, String>{};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    _stompClient = StompClient(
      config: StompConfig(
        url: wsUri.toString(),
        onConnect: _onConnect,
        beforeConnect: () async {
          // Nhỡ các thao tác async như load token
          await Future.delayed(const Duration(milliseconds: 200));
        },
        onWebSocketError: (dynamic error) {
          debugPrint('[RealtimeWorkoutService] Socket error: $error');
        },
        onStompError: (StompFrame frame) {
          debugPrint('[RealtimeWorkoutService] STOMP error: ${frame.body}');
        },
        onDisconnect: (frame) {
          _subscribed = false;
        },
        reconnectDelay: const Duration(seconds: 5),
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
      ),
    );

    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    _subscribe();
  }

  void _subscribe() {
    if (_stompClient == null || _subscribed) {
      return;
    }

    _stompClient!.subscribe(
      destination: '/topic/workouts',
      callback: (frame) {
        final body = frame.body;
        if (body == null) {
          return;
        }

        try {
          final json = jsonDecode(body) as Map<String, dynamic>;
          final update = WorkoutRealtimeUpdate.fromJson(json);
          _controller.add(update);
        } catch (e) {
          debugPrint('[RealtimeWorkoutService] Failed to parse update: $e');
        }
      },
    );

    _subscribed = true;
  }
}
