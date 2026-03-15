// --- الشاشة الثانية: عرض النتائج ---
import 'package:flutter/material.dart';
import 'package:scout_vote/setup_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DashboardScreen extends StatefulWidget {
  final String serverUrl;
  const DashboardScreen({super.key, required this.serverUrl});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, int> votes = {"ashbal": 0, "kashaf": 0, "mutaqadim": 0, "jawala": 0};
  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() {
    socket = IO.io(widget.serverUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build());

    socket!.on('update_votes', (data) {
      if (mounted) {
        setState(() => votes = Map<String, int>.from(data));
      }
    });

    socket!.onDisconnect((_) => print("Disconnected"));
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalVotes = votes.values.fold(0, (sum, item) => sum + item);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        title: const Text("لوحة النتائج المباشرة"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SetupScreen())),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildBar("الأشبال", votes['ashbal']!, totalVotes, Colors.orange),
                _buildBar("الكشاف", votes['kashaf']!, totalVotes, Colors.green),
                _buildBar("المتقدم", votes['mutaqadim']!, totalVotes, Colors.red),
                _buildBar("الجوالة", votes['jawala']!, totalVotes, Colors.blue),
                const Spacer(),
                Text("إجمالي الأصوات: $totalVotes", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBar(String label, int count, int total, Color color) {
    double percentage = (total == 0) ? 0 : (count / total);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              Text("$count صوت", style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(height: 40, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20))),
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.elasticOut,
                height: 40,
                width: (MediaQuery.of(context).size.width * 0.7) * percentage,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 15)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}