import 'package:flutter/material.dart';
import 'package:teachiz/screens/start.dart';
import 'package:teachiz/screens/quiz.dart';
import 'package:teachiz/screens/result.dart';
import 'package:easy_localization/easy_localization.dart';

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
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        brightness: Brightness.light,
        backgroundColor: const Color.fromRGBO(37, 44, 74, 1.0),
        primaryColor: const Color.fromRGBO(190, 56, 55, 1.0),
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routes: {
        'start': (context) => Start(),
        'quiz': (context) {
          final String quiz =
              ModalRoute.of(context)!.settings.arguments as String;
          return Quiz(quiz: quiz);
        },
        'result': (context) => Result(),
      },
      home: Start(),
    );
  }
}
