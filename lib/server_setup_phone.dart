import 'package:flutter/material.dart';
import 'package:scout_vote/vote_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ServerConfigScreen extends StatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  State<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  final TextEditingController _controller = TextEditingController(text: "192.168.1.70:5000");
  bool _isConnecting = false;

  void _tryConnect() {
    setState(() => _isConnecting = true);

    String url = _controller.text.trim();
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
          MaterialPageRoute(builder: (context) => VotingScreen(serverUrl: url)),
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
      appBar: AppBar(title: const Text("إعداد الاتصال")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lan, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "عنوان IP الحاسوب",
                hintText: "مثال: 192.168.1.70",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isConnecting 
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _tryConnect,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("بدأ عملية التصويت"),
            ),
          ],
        ),
      ),
    );
  }
}