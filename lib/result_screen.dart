import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class DashboardScreen extends StatefulWidget {
  final String serverUrl;
  const DashboardScreen({super.key, required this.serverUrl});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Real data from server
  Map<String, int> serverVotes = {
    "ashbal": 0, "kashaf": 0, "mutaqadim": 0, "jawala": 0,
  };

  // Data currently being displayed (for the animation)
  Map<String, int> displayVotes = {
    "ashbal": 0, "kashaf": 0, "mutaqadim": 0, "jawala": 0,
  };

  bool isRevealed = false;
  bool gender = false;
  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() {
    socket = IO.io(
      widget.serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    // Listen for the final results event
    socket!.on('final_results', (data) {
      if (mounted) {
        setState(() {
          serverVotes = Map<String, int>.from(data);
          // If already revealed, update live. If not, wait for button.
          if (isRevealed) displayVotes = Map<String, int>.from(data);
        });
      }
    });

    socket!.onDisconnect((_) => print("Disconnected"));
  }

  void _startRace() {
    setState(() {
      // Reset to 0 first to ensure the animation "starts" from the bottom
      displayVotes = {"ashbal": 0, "kashaf": 0, "mutaqadim": 0, "jawala": 0};
      isRevealed = true;
    });

    // Small delay to trigger the animation towards actual server values
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        displayVotes = Map<String, int>.from(serverVotes);
      });
    });
  }
// Inside your _DashboardScreenState class

void _triggerFinalResults() {
  // 1. Tell the server to broadcast the final data to everyone
  socket?.emit('end_voting');
  
  // 2. Prepare the local UI for the race
  setState(() {
    isRevealed = true;
    // Reset display to zero so the bars "grow" from the start
    displayVotes = {"ashbal": 0, "kashaf": 0, "mutaqadim": 0, "jawala": 0};
  });

  // 3. Small delay to ensure the 'final_results' listener updates serverVotes first
  Future.delayed(const Duration(milliseconds: 300), () {
    setState(() {
      displayVotes = Map<String, int>.from(serverVotes);
    });
  });
}

void _resetVotes() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("تصفير الأصوات؟", style: TextStyle(color: Colors.black),),
      content: const Text("سيتم حذف جميع الأصوات المسجلة بشكل نهائي.", style: TextStyle(color: Colors.black)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("إلغاء"),
        ),
        TextButton(
          onPressed: () {
            // 1. Tell server to clear data
            socket?.emit('reset_votes');
            
            // 2. Reset local UI state
            setState(() {
              isRevealed = false;
              serverVotes = {"ashbal": 0, "kashaf": 0, "mutaqadim": 0, "jawala": 0};
              displayVotes = {"ashbal": 0, "kashaf": 0, "mutaqadim": 0, "jawala": 0};
            });
            
            Navigator.pop(context);
          },
          child: const Text("تصفير الآن", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

@override
Widget build(BuildContext context) {
  int totalVotes = displayVotes.values.fold(0, (sum, item) => sum + item);

  return Scaffold(
    backgroundColor: const Color(0xFF0F0F1E),
    appBar: AppBar(
      title: const Text("نتائج التصويت النهائبة", style: TextStyle(color: Colors.white)),
      actions: [
        // Reset button to allow re-running the race if needed
        if (isRevealed)
          IconButton(
            onPressed: () => setState(() => isRevealed = false),
            icon: const Icon(Icons.refresh, color: Colors.white70),
          ),

          IconButton(
      onPressed: _resetVotes,
      icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
      tooltip: "تصفير الأصوات",
    ),
    IconButton(
      onPressed: () => setState(() => gender = !gender),
      icon: const Icon(Icons.change_circle_outlined, color: Colors.white),
    ),
      ],
      backgroundColor: Colors.transparent,
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildAnimatedBar(gender ? "زهرات" : "أشبال", displayVotes['ashbal']!, totalVotes, Colors.orange),
              _buildAnimatedBar(gender ? "مرشدات" : "كشاف", displayVotes['kashaf']!, totalVotes, Colors.green),
              _buildAnimatedBar(gender ? "متقدمات" : "متقدم", displayVotes['mutaqadim']!, totalVotes, Colors.red),
              _buildAnimatedBar(gender ? "جوالات" : "جوالة", displayVotes['jawala']!, totalVotes, Colors.blue),
              
              const Spacer(),
              
              // THE NEW TRIGGER BUTTON
              if (!isRevealed)
                GestureDetector(
                  onTap: _triggerFinalResults,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.deepPurple, Colors.blueAccent]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 20)
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.speed_sharp, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          "إعلان النتائج وبدء السباق",
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                
              const SizedBox(height: 30),
              Text(
                "إجمالي الأصوات المكتشفة: $totalVotes",
                style: const TextStyle(fontSize: 22, color: Colors.white54),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    ),
  );
}
  Widget _buildAnimatedBar(String label, int count, int total, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              // Counting number animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: count.toDouble()),
                duration: const Duration(seconds: 30),
                builder: (context, value, child) => Text(
                  "${value.toInt()} صوت",
                  style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              double maxAvailableWidth = constraints.maxWidth;
              double percentage = (total == 0) ? 0 : (count / total);
              
              return Stack(
                children: [
                  Container(
                    height: 35,
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
                  ),
                  AnimatedContainer(
                    duration: const Duration(seconds: 30), // Length of the race
                    curve: Curves.fastOutSlowIn,
                    height: 35,
                    width: maxAvailableWidth * percentage,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }
}