import 'package:flutter/material.dart';
import 'package:teachiz/screens/start.dart';
import 'package:teachiz/screens/catalogo.dart';
import 'package:teachiz/screens/quiz.dart';
import 'package:teachiz/screens/result.dart';
import 'package:teachiz/screens/explain.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cupertino_back_gesture/cupertino_back_gesture.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('it')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BackGestureWidthTheme(
      backGestureWidth: BackGestureWidth.fraction(1 / 4),
      child: MaterialApp(
        title: 'Quiz App',
        theme: ThemeData(
          brightness: Brightness.light,
          backgroundColor: const Color.fromRGBO(37, 44, 74, 1.0),
          primaryColor: const Color.fromRGBO(190, 56, 55, 1.0),
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            // for Android - default page transition
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            // for iOS - one which considers ancestor BackGestureWidthTheme
            TargetPlatform.iOS:
                CupertinoPageTransitionsBuilderCustomBackGestureWidth(),
          }),
        ),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routes: {
          'start': (context) => Start(),
          'catalogo': (context) => Catalogo(),
          'quiz': (context) {
            final String quiz =
                ModalRoute.of(context)!.settings.arguments as String;
            return Quiz(quiz: quiz);
          },
          'explain': (context) {
            final Map<String, dynamic> args = ModalRoute.of(context)!
                .settings
                .arguments as Map<String, dynamic>;
            final String question = args['question'];
            final String correctAnswer = args['correctAnswer'];
            final String userAnswer = args['userAnswer'];
            return Explain(
              question: question,
              correctAnswer: correctAnswer,
              userAnswer: userAnswer,
              onNextQuestion: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'quiz');
              },
            );
          },
          'result': (context) {
            final Map<String, dynamic> args = ModalRoute.of(context)!
                .settings
                .arguments as Map<String, dynamic>;
            final List<Map<String, dynamic>> wrongAnsweredQuestions =
                args['wrongAnsweredQuestions'];
            return Result(wrongAnsweredQuestions: wrongAnsweredQuestions);
          },
        },
        home: Start(),
      ),
    );
  }
}
