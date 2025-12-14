import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

// Pastikan Anda mengganti 'YOUR_API_KEY' dengan kunci API Gemini Anda yang sebenarnya.
void main() {
  // Inisialisasi Gemini API
  Gemini.init(
    apiKey: 'YOUR_API_KEY', 
  );
  
  runApp(const MyApp());
}

// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, 
      title: 'Gemini Chat App', 
      home: ChatScreen(),
    );
  }
}

// Stateful widget for the chat screen
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

// State class for ChatScreen
class _ChatScreenState extends State<ChatScreen> {
  
  // 1. Variabel Inisialisasi (Controller & List Pesan)
  final TextEditingController _controller = TextEditingController(); 
  // List untuk menyimpan pesan: {'sender': 'user'/'bot', 'text': 'isi pesan'}
  final List<Map<String, String>> _messages = []; 
  
  // 2. Metode untuk mengirim pesan dan menerima respons
  void _sendMessage() async { 
    final inputText = _controller.text.trim(); 
    if (inputText.isEmpty) return; // Jangan kirim jika input kosong

    // 1. Tambahkan pesan pengguna ke riwayat dan update UI
    setState(() { 
      _messages.add({'sender': 'user', 'text': inputText}); 
    }); 

    _controller.clear(); // 2. Bersihkan kotak input

    try {
      // 3. Siapkan input untuk Gemini API
      final parts = [Part.text(inputText)]; 
      
      // 4. Kirim permintaan ke Gemini API
      final response = await Gemini.instance.prompt(parts: parts);

      // 5. Tambahkan respons dari bot ke riwayat dan update UI
      setState(() { 
        _messages.add({
          'sender': 'bot',
          'text': response?.output ?? 'Gagal mendapatkan respons dari Gemini.',
        });
      });
    } catch (e) {
      // Handle jika ada error koneksi atau API
       setState(() { 
        _messages.add({
          'sender': 'bot',
          'text': 'Terjadi error: $e',
        });
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GFG Chatbot'), 
        backgroundColor: Colors.green, 
        foregroundColor: Colors.white,
      ),
      // Struktur Body (Daftar Pesan dan Kotak Input)
      body: Column(
        children: <Widget>[
          // Bagian Atas: Menampilkan daftar pesan
          Expanded(
            child: ListView.builder(
              reverse: true, // Agar pesan terbaru muncul di bagian bawah
              padding: const EdgeInsets.all(12.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // Mengambil pesan dari urutan terbaru (dibalik)
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Bagian Bawah: Kotak Input Pesan
          _buildMessageComposer(),
        ],
      ),
    );
  }
  
  // Helper Widget untuk membuat tampilan bubble pesan
  Widget _buildMessageBubble(Map<String, String> message) {
    final isUser = message['sender'] == 'user';
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.green[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message['text'] ?? '',
          style: TextStyle(color: isUser ? Colors.green[800] : Colors.black87),
        ),
      ),
    );
  }
  
  // Helper Widget untuk Kotak Input dan Tombol Kirim
  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 3,
          offset: const Offset(0, 3),
        ),
      ]),
      child: Row(
        children: <Widget>[
          // Kotak Input Teks
          Expanded(
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _sendMessage(), // Kirim saat menekan Enter
              decoration: const InputDecoration.collapsed(
                hintText: 'Ketik pesan...',
              ),
            ),
          ),
          // Tombol Kirim
          IconButton(
            icon: const Icon(Icons.send, color: Colors.green),
            onPressed: _sendMessage, // Panggil metode _sendMessage saat ditekan
          ),
        ],
      ),
    );
  }
}