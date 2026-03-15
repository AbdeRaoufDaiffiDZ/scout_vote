// --- الشاشة الأولى: إعداد الاتصال ---
import 'package:scout_vote/result_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:flutter/material.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _urlController = 
      TextEditingController(text: "http://192.168.1.70:5000");
  bool _isConnecting = false;

  void _tryConnect() {
    setState(() => _isConnecting = true);

    String url = _urlController.text.trim();
    if (!url.startsWith('http')) url = 'http://$url';

    // محاولة اتصال مؤقتة للتحقق
    IO.Socket socket = IO.io(url, IO.OptionBuilder()
        .setTransports(['websocket'])
        .setAckTimeout(5000) // 5 ثواني مهلة
        .build());

    socket.onConnect((_) {
      socket.dispose(); // نغلقه هنا لنفتحه في الشاشة التالية
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen(serverUrl: url)),
        );
      }
    });

    socket.onConnectError((err) {
      setState(() => _isConnecting = false);
      socket.dispose();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل الاتصال: $err"), backgroundColor: Colors.red),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings_remote, size: 80, color: Colors.deepPurpleAccent),
              const SizedBox(height: 20),
              const Text("إعداد خادم النتائج", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: "Server URL",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 20),
              _isConnecting 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _tryConnect,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                    ),
                    child: const Text("دخول للنتائج المباشرة"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}