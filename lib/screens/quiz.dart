import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import 'package:teachiz/components/quiz_option.dart';

class Quiz extends StatefulWidget {
  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  late List? questions;
  String? currentTitle;
  String? currentCorrectAnswer;
  List<dynamic>? currentAnswers;
  late int corrects;
  late int currentQuestion;
  late int? selectedAnswer;
  DateTime? now;

  @override
  void initState() {
    now = DateTime.now();
    corrects = 0;
    currentQuestion = 0;
    questions = null;
    selectedAnswer = null;
    getQuestions();
    super.initState();
  }

  void getQuestions() async {
    final response = await http
        .get(Uri.parse('https://opentdb.com/api.php?amount=10&category=18'));
    Map data = json.decode(response.body);
    List answers = [data['results'][0]['correct_answer']] +
        data['results'][0]['incorrect_answers'];
    setState(() {
      questions = data['results'];
      currentTitle = data['results'][0]['question'];
      currentCorrectAnswer = data['results'][0]['correct_answer'];
      currentAnswers = answers..shuffle();
    });
  }

  void verifyAndNext(BuildContext context) {
    var _selectedAnswer = selectedAnswer?.toInt() ?? 5; //occhio qui
    String textSelectAnswer = currentAnswers![_selectedAnswer];
    if (textSelectAnswer == currentCorrectAnswer) {
      setState(() {
        corrects++;
      });
    }
    nextQuestion(context);
  }

  void nextQuestion(BuildContext context) {
    int actualQuestion = currentQuestion;
    if (actualQuestion + 1 < questions!.length) {
      List answers = [questions![actualQuestion + 1]['correct_answer']] +
          questions![actualQuestion + 1]['incorrect_answers'];
      setState(() {
        currentQuestion++;
        currentTitle = questions![actualQuestion + 1]['question'];
        currentCorrectAnswer = questions![actualQuestion + 1]['correct_answer'];
        currentAnswers = answers..shuffle();
        selectedAnswer = null;
      });
    } else {
      Navigator.pushReplacementNamed(context, 'result', arguments: {
        'corrects': corrects,
        'start_at': now,
        'list_length': questions!.length,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var _selectedAnswer = selectedAnswer?.toInt() ?? 5; //occhio pure qui
    ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: (questions != null)
            ? Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  bottom: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(context, 'start');
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 32.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'Question ${currentQuestion + 1}',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '/${questions!.length}',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(25.0),
                      margin: const EdgeInsets.symmetric(vertical: 30.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        HtmlUnescape().convert(currentTitle!),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: currentAnswers!.length + 1,
                        itemBuilder: (context, index) {
                          if (index == currentAnswers!.length) {
                            return GestureDetector(
                              onTap: () {
                                if (selectedAnswer != null)
                                  verifyAndNext(context);
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 15.0,
                                  horizontal: 30.0,
                                ),
                                padding: const EdgeInsets.all(15.0),
                                decoration: BoxDecoration(
                                  color: (selectedAnswer == null)
                                      ? Colors.grey
                                      : theme.primaryColor,
                                  borderRadius: BorderRadius.circular(180.0),
                                ),
                                child: Text(
                                  'Next',
                                  textAlign: TextAlign.center,
                                  maxLines: 5,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            );
                          }
                          String answer = currentAnswers![index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedAnswer = index;
                              });
                            },
                            child: QuizOption(
                              index: index,
                              selectedAnswer: _selectedAnswer,
                              answer: answer,
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                    theme.primaryColor,
                  ),
                ),
              ),
      ),
    );
  }
}
