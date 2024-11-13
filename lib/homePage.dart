import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late IO.Socket socket;
  String senderId = "";
  String receiverId = "";
  String message = "";
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    // Initialize the socket connection
    socket = IO.io('YOUR_BASEURL_HERE', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();

    // Listen for incoming messages
    socket.on('chat-message', (data) {
      setState(() {
        messages.add("${data['senderId']}: ${data['content']}");
      });
    });
  }

  void sendMessage() {
    if (message.trim().isNotEmpty && senderId.isNotEmpty && receiverId.isNotEmpty) {
      final data = {
        'senderId': senderId,
        'receiverId': receiverId,
        'content': message,
      };
      socket.emit('message', data);
      setState(() {
        messages.add("myid: $message");
        message = "";
      });
    }
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Interface')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Your ID'),
                  onChanged: (value) => senderId = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Receiver ID'),
                  onChanged: (value) => receiverId = value,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Type a message...'),
                    onChanged: (value) => message = value,
                    controller: TextEditingController(text: message),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}