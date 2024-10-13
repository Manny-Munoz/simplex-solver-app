import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _userInput =TextEditingController();

  static const apiKey = 'AIzaSyBZ6zklgGDZEKUlpfdg0cTY9jKwhpuojAA';

  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);

  final List<Message> _messages = [];

  Future<void> sendMessage() async{
    final message = _userInput.text;

    setState(() {
      _messages.add(Message(isUser: true, message: message, date: DateTime.now()));
      _userInput.clear();
    });

    final content = [Content.text(message)];
    final response = await model.generateContent(content);


    setState(() {
      _messages.add(Message(isUser: false, message: response.text?? "", date: DateTime.now()));
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
        title: const Text('Habla con PLEXY', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color.fromARGB(255, 151,80,27),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color.fromARGB(255, 252,235,211),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.dstATop),
            image: const NetworkImage('https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEigDbiBM6I5Fx1Jbz-hj_mqL_KtAPlv9UsQwpthZIfFLjL-hvCmst09I-RbQsbVt5Z0QzYI_Xj1l8vkS8JrP6eUlgK89GJzbb_P-BwLhVP13PalBm8ga1hbW5pVx8bswNWCjqZj2XxTFvwQ__u4ytDKvfFi5I2W9MDtH3wFXxww19EVYkN8IzIDJLh_aw/s1920/space-soldier-ai-wallpaper-4k.webp'),
            fit: BoxFit.cover
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
                child: ListView.builder(itemCount:_messages.length,itemBuilder: (context,index){
                  final message = _messages[index];
                  return Messages(isUser: message.isUser, message: message.message, date: DateFormat('HH:mm').format(message.date));
                })
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: TextFormField(
                      style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                      controller: _userInput,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        label: const Text('Enter Your Message')
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    padding: const EdgeInsets.all(12),
                      iconSize: 30,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 228, 155,56)),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(const CircleBorder())
                      ),
                      onPressed: (){
                      sendMessage();
                      },
                      icon: const Icon(Icons.send))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Message{
  final bool isUser;
  final String message;
  final DateTime date;

  Message({ required this.isUser, required this.message, required this.date});
}

class Messages extends StatelessWidget {

  final bool isUser;
  final String message;
  final String date;

  const Messages(
      {
        super.key,
        required this.isUser,
        required this.message,
        required this.date
      });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isUser ? 100:10,
        right: isUser ? 10: 100
      ),
      decoration: BoxDecoration(
        color: isUser ? Color.fromARGB(255, 235, 145, 93) : Color.fromARGB(255, 255, 189, 147),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          bottomLeft: isUser ? const Radius.circular(10): Radius.zero,
          topRight: const Radius.circular(10),
          bottomRight: isUser ? Radius.zero : const Radius.circular(10)
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 16,color: isUser ? Colors.white: Colors.black),
          ),
          Text(
            date,
            style: TextStyle(fontSize: 10,color: isUser ? Colors.white: Colors.black,),
          )
        ],
      ),
    );
  }
}