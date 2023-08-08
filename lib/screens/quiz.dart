import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import 'package:teachiz/components/quiz_option.dart';
import 'package:teachiz/screens/explain.dart';
import 'package:easy_localization/easy_localization.dart';

class Quiz extends StatefulWidget {
  final String quiz;

  const Quiz({Key? key, required this.quiz}) : super(key: key);

  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  final PageController _pageController = PageController();
  List<Map<String, dynamic>> wrongAnsweredQuestions = [];
  List<dynamic>? questions;
  String? currentTitle;
  String? currentCorrectAnswer;
  List<dynamic>? currentAnswers;
  int corrects = 0;
  int currentQuestion = 0;
  DateTime? now;
  String quizText = '';
  String lang = '';
  String? cost;
  String? totalIterations;
  int? selectedAnswer;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    quizText = widget.quiz;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    lang = context.locale.languageCode;
    getQuestions();
  }

  void getQuestions() async {
    final response = await http.get(Uri.parse(
        'https://teachizapi.ew.r.appspot.com/api/qwtfromquery?query=${Uri.encodeComponent(quizText)}&lang=$lang'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> wrongAnswers =
          json.decode(data['results'][0]['wrong_answ']);
      String correctAnswer = data['results'][0]['corct_answ'];
      List<dynamic> answers = [correctAnswer, ...wrongAnswers];

      setState(() {
        questions = data['results'];
        currentTitle = data['results'][0]['question'];
        currentCorrectAnswer = data['results'][0]['corct_answ'];
        currentAnswers = answers..shuffle();
      });
    }
  }

  void verifyAndNext(BuildContext context) {
    var selectedAnswerIndex = selectedAnswer ?? 5;
    String textSelectAnswer = currentAnswers![selectedAnswerIndex];

    if (textSelectAnswer == currentCorrectAnswer) {
      setState(() {
        corrects++;
      });
      nextQuestion(context);
    } else {
      wrongAnsweredQuestions.add({
        'question': currentTitle,
        'correctAnswer': currentCorrectAnswer,
        'userAnswer': textSelectAnswer,
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Explain(
            question: currentTitle!,
            correctAnswer: currentCorrectAnswer!,
            userAnswer: textSelectAnswer,
            onNextQuestion: () {
              nextQuestion(context);
            },
          ),
        ),
      );
    }
  }

  void nextQuestion(BuildContext context) {
    int actualQuestion = currentQuestion;
    if (actualQuestion + 1 < questions!.length) {
      List<dynamic> wrongAnswers =
          json.decode(questions![actualQuestion + 1]['wrong_answ']);
      String correctAnswer = questions![actualQuestion + 1]['corct_answ'];
      List<dynamic> answers = [correctAnswer, ...wrongAnswers];

      setState(() {
        currentQuestion++;
        currentTitle = questions![actualQuestion + 1]['question'];
        currentCorrectAnswer = questions![actualQuestion + 1]['corct_answ'];
        currentAnswers = answers..shuffle();
        selectedAnswer = null;
      });

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, 'result', arguments: {
        'corrects': corrects,
        'start_at': now,
        'list_length': questions!.length,
        'wrongAnsweredQuestions': wrongAnsweredQuestions,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var selectedAnswerIndex = selectedAnswer ?? 5;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'cost: ${cost ?? "N/A"}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Text(
                    'iterazioni: ${totalIterations ?? "N/A"}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  (questions != null)
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacementNamed(
                                            context, 'start');
                                      },
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 32.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                lang, //debug
                                style: const TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    'Question ${currentQuestion + 1}',
                                    style: const TextStyle(
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
                                margin:
                                    const EdgeInsets.symmetric(vertical: 30.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text(
                                  HtmlUnescape().convert(currentTitle!),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
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
                                          if (selectedAnswer != null) {
                                            verifyAndNext(context);
                                          }
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
                                            borderRadius:
                                                BorderRadius.circular(180.0),
                                          ),
                                          child: const Text(
                                            'Next',
                                            textAlign: TextAlign.center,
                                            maxLines: 5,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                            ),
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
                                        selectedAnswer: selectedAnswerIndex,
                                        answer: answer,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.primaryColor,
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
}
