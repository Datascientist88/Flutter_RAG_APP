import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart' as audioplayers;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'IVF Training Bot'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController controller = TextEditingController();
  String results = "results to be shown here";
  List<ChatMessage> messages = <ChatMessage>[];
  ChatUser userMe = ChatUser(
    id: '1',
    firstName: 'Bahageel',
    lastName: 'Mohammed',
  );
  ChatUser openAIUser = ChatUser(
    id: '2',
    firstName: 'IVF Training ',
    lastName: 'AI Bot',
  );
  bool isTTS = false;
  SpeechToText _speechToText = SpeechToText();
  bool _isTyping = false;
  bool _isLoading = false;
  final audioplayers.AudioPlayer _audioPlayer = audioplayers.AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    controller.addListener(_handleTyping);
  }

  void _handleTyping() {
    setState(() {
      _isTyping = controller.text.isNotEmpty;
    });
  }

  bool _speechEnabled = false;

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: _onSpeechResult,
      );
      setState(() {});
    }
  }

  void _stopListening() async {
    if (_speechEnabled) {
      await _speechToText.stop();
      setState(() {});
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      ChatMessage msg = ChatMessage(
        user: userMe,
        createdAt: DateTime.now(),
        text: result.recognizedWords,
      );
      messages.insert(0, msg);
      setState(() {
        messages;
      });
      controller.text = result.recognizedWords;
      chatComplete();
    }
  }

  void _soundLevelListener(double level) {
    if (level < 0.5) {
      _stopListening();
      _startListening();
    }
  }

  void chatComplete() async {
    setState(() {
      _isLoading = true;
    });

    final requestPayload = {
      "message": controller.text,
    };

    try {
      final response = await http.post(
        Uri.parse('https://ivfendpoint-flask.onrender.com/chat'), // Replace with actual URL
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestPayload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        results = responseData['response'];
        ChatMessage msg = ChatMessage(
          user: openAIUser,
          createdAt: DateTime.now(),
          text: results,
        );
        messages.insert(0, msg);
        if (isTTS) {
          await _speak(results);
        }
        setState(() {
          messages;
          results;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }

    setState(() {
      _isLoading = false;
    });

    controller.text = "";
  }

  Future<void> _speak(String text) async {
    final requestPayload = {
      "text": text,
    };

    try {
      final response = await http.post(
        Uri.parse('https://elevenlabsflaskendpoint.onrender.com/text-to-speech'), // Replace with actual URL
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestPayload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print("Response Data: $responseData"); // Log the entire response data

        if (responseData.containsKey('audio_file_path')) {
          final audioFilePath = responseData['audio_file_path'];

          print("Audio File Path: $audioFilePath"); // Debugging line

          // Ensure the file path is valid
          if (audioFilePath.isNotEmpty) {
            // Construct the full URL for the audio file
            final audioUrl = 'https://example.com/audio/$audioFilePath'; // Replace with your actual base URL
            await _audioPlayer.play(audioUrl as audioplayers.Source);
          } else {
            print("Invalid audio file path");
          }
        } else {
          print("Key 'audio_file_path' not found in response");
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade900,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          InkWell(
            child: Padding(
              padding: EdgeInsets.all(7.0),
              child: Icon(
                isTTS ? Icons.record_voice_over : Icons.voice_over_off_sharp,
                color: Colors.white,
              ),
            ),
            onTap: () {
              setState(() {
                isTTS = !isTTS;
              });
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: _isLoading
                  ? LoadingWidget()
                  : DashChat(
                      currentUser: userMe,
                      onSend: (m) {},
                      readOnly: true,
                      messages: messages,
                      messageOptions: MessageOptions(
                        currentUserContainerColor: Colors.purple.shade900,
                        containerColor: Colors.white,
                        textColor: Colors.black,
                        currentUserTextColor: Colors.white,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(9.0),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: 'Type your message here ...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _isTyping
                      ? ElevatedButton(
                          onPressed: () {
                            ChatMessage msg = ChatMessage(
                              user: userMe,
                              createdAt: DateTime.now(),
                              text: controller.text,
                            );
                            messages.insert(0, msg);
                            setState(() {
                              messages;
                            });
                            chatComplete();
                            controller.text = "";
                          },
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(15),
                            backgroundColor: Colors.purple.shade900,
                          ),
                        )
                      : GestureDetector(
                          onLongPressStart: (details) {
                            _startListening();
                          },
                          onLongPressEnd: (details) {
                            _stopListening();
                          },
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Icon(
                              Icons.mic,
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(15),
                              backgroundColor: Colors.purple.shade900,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.removeListener(_handleTyping);
    controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/Animations.json', // Path to your Lottie file
        width: 200,
        height: 200,
        fit: BoxFit.fill,
      ),
    );
  }
}