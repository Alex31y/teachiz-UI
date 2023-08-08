//ciao alex del futuro, qui c'hai il caricamento delle note all'lm, durante il caricamento l'utente vede un indicatore di caricamento ed una serie di frasi per accompagnare durante l'attesa

import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:teachiz/components/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Note extends StatefulWidget {
  final String query;
  final Locale lang;

  const Note({super.key, required this.query, required this.lang});

  @override
  _NoteState createState() => _NoteState();
}

class _NoteState extends State<Note> {
  String imageUrl =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS_nEryednxwlHBPYTDqeuNBdV5osOWblWCXg46avY7bP7IWkaAOap7NB5g1Jppl63xTyQ&usqp=CAU';
  String _content = '';
  //roba per le frasine del caricamento
  List<String> phrases = [];
  String currentPhrase = "";
  bool isPhrasesLoaded = false; // Track the loading state
  Timer? timer;

  @override
  void initState() {
    super.initState();
    //roba per le frasine del caricamento
    loadImage();
    loadPhrases();
    // Start the timer to update the phrase every 5 seconds
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) {
      if (isPhrasesLoaded) {
        updatePhrase();
      }
    });
    _fetchData();
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> loadImage() async {
    final response = await http.get(Uri.parse(
        'https://teachizapi.ew.r.appspot.com/api/qetimage?query=${widget.query}'));

    if (response.statusCode == 200) {
      // Parse the JSON response as a List<dynamic>
      imageUrl = response.body;
    }
  }

  Future<void> loadPhrases() async {
    try {
      String data = await rootBundle.loadString('assets/text/frasi.json');
      print('Loaded data: $data'); // Print loaded data to check its content
      List<dynamic> phrasesJson = json.decode(data);
      setState(() {
        phrases = phrasesJson.map((phrase) => phrase.toString()).toList();
        isPhrasesLoaded = true;
      });
    } catch (e) {
      print('Error loading phrases: $e');
    }
  }

  void updatePhrase() {
    // Choose a random phrase from the list
    final random = Random();
    final randomPhrase = phrases[random.nextInt(phrases.length)];

    // Update the state to trigger a rebuild of the UI with the new phrase
    setState(() {
      currentPhrase = randomPhrase;
    });
  }

  Future<void> _fetchData() async {
    try {
      print(
          'https://teachizapi.ew.r.appspot.com/api/note?query=${widget.query}&lang=${widget.lang.languageCode}');
      // Make the API call using the query and lang from the previous page
      final response = await http.get(Uri.parse(
          'https://teachizapi.ew.r.appspot.com/api/note?query=${widget.query}&lang=${widget.lang.languageCode}'));

      if (response.statusCode == 200) {
        // Parse the JSON response as a List<dynamic>
        List<dynamic> dataList = json.decode(response.body);

        // Extract the "text" value from the first (and only) item in the list
        _content = dataList.isNotEmpty ? dataList[0]['text'] : '';
        // Cancel the timer to stop 5-second updates
        timer?.cancel();
      } else {
        // Handle API call failure
        print('API call failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('API call failed with error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Note'),
      ),
      body: Center(
        child: FutureBuilder<void>(
          future: _fetchData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 300, // Set your desired width
                    height: 300, // Set your desired height
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit
                          .contain, // Use BoxFit.contain to avoid stretching
                    ),
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16), //spazio tra i componenti
                  Text(currentPhrase),
                ],
              );
            } else if (snapshot.hasError) {
              return Text('Error occurred: ${snapshot.error}');
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 300, // Set your desired width
                    height: 300, // Set your desired height
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit
                          .contain, // Use BoxFit.contain to avoid stretching
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _content,
                        style: const TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, 'quiz',
                            arguments: widget.query);
                      },
                      child: const CustomButton(
                        text: 'startquiz',
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
