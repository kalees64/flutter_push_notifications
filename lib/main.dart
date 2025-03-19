import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late WebSocketChannel _channel;
  String _message = "Waiting for notifications...";

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
