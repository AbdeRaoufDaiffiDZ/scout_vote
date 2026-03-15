import 'package:flutter/material.dart';
import 'package:scout_vote/vote_screen.dart';

class ServerConfigScreen extends StatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  State<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  final TextEditingController _controller = TextEditingController(text: "192.168.1.70");

  void _startVoting() {
    String url = "http://${_controller.text.trim()}:5000";
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VotingScreen(serverUrl: url)),
    );
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
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startVoting,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: const Text("بدأ عملية التصويت"),
            ),
          ],
        ),
      ),
    );
  }
}