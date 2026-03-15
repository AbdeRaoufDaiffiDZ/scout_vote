import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class VotingScreen extends StatefulWidget {
  final String serverUrl;
  const VotingScreen({super.key, required this.serverUrl});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  late IO.Socket socket;
  final List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  void initSocket() {
    socket = IO.io(widget.serverUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .enableAutoConnect()
      .build());
    
    socket.connect();
    socket.onConnect((_) => print('متصل بالسيرفر ✅'));
  }

  void _handleVote(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else if (_selectedCategories.length < 2) {
        _selectedCategories.add(category);
      }
    });
  }

  void _submitVotes() {
    if (_selectedCategories.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى اختيار فرقتين للتصويت")),
      );
      return;
    }

    socket.emit('cast_vote', _selectedCategories);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("شكراً لك", textAlign: TextAlign.center),
        content: const Text("تم تسجيل تصويتك بنجاح", textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _selectedCategories.clear());
              Navigator.pop(context);
            },
            child: const Center(child: Text("إغلاق")),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("صوّت لفرقتك"), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            "تم اختيار: ${_selectedCategories.length} / 2",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              children: [
                _voteButton("أشبال", "ashbal", Colors.orange),
                _voteButton("كشاف", "kashaf", Colors.green),
                _voteButton("متقدم", "mutaqadim", Colors.red),
                _voteButton("جوالة", "jawala", Colors.blue),
              ],
            ),
          ),
          // زر التأكيد (Submit Button)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: _selectedCategories.length == 2 ? _submitVotes : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("تأكيد وإرسال التصويت", style: TextStyle(fontSize: 20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _voteButton(String label, String key, Color color) {
    bool isSelected = _selectedCategories.contains(key);
    return GestureDetector(
      onTap: () => _handleVote(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.4), // باهت إذا لم يتم اختياره
          border: isSelected ? Border.all(color: Colors.black, width: 4) : null,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
              if (isSelected) const Icon(Icons.check_circle, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}