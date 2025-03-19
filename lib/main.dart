import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotifications();
  runApp(App());
}

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  void initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);

    // Manually request permission for notifications (Android 13+)
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }

    print("Notification permission requested!");
  }

  void showNotification(String title, String body) async {
    print("Trying to show notification: $title - $body");
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'WebSocket Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ticker: 'ticker',
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notifications.show(0, title, body, details);

    print("Notification Triggered!");
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late WebSocketChannel _channel;
  String _message = "Waiting for notifications...";
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      _channel = IOWebSocketChannel.connect("ws://192.168.0.171:8000/ws");
      print("Connected to WebSocket");

      _channel.stream.listen(
        (message) {
          print("Received: $message"); // Debugging log
          setState(() => _message = message);
          _notificationService.showNotification("Notification", message);
        },
        onError: (error) {
          print("WebSocket Error: $error");
          setState(() => _message = "Connection Error: $error");
        },
        onDone: () {
          print("WebSocket Disconnected!");
          setState(() => _message = "Disconnected!");
        },
      );
    } catch (e) {
      print("WebSocket Connection Failed: $e");
      setState(() => _message = "Failed to connect: $e");
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text("WebSocket Notification")),
        body: Center(child: Text(_message)),
      ),
    );
  }
}
