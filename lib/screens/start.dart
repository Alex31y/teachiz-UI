import 'package:flutter/material.dart';
import 'package:teachiz/components/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:teachiz/screens/catalogo.dart';
import 'note.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {
  final TextEditingController _queryController = TextEditingController();
  String _query = '';
  late Locale _currentLocale;
  bool _isEnglish = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentLocale = EasyLocalization.of(context)!.locale;
    _isEnglish = _currentLocale.languageCode == 'en';
  }

  void _toggleLanguage() {
    setState(() {
      _currentLocale = _isEnglish ? const Locale('it') : const Locale('en');
      _isEnglish = !_isEnglish;
    });
    context.setLocale(_currentLocale);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // About "?" button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Image.asset('assets/images/question.png'),
                iconSize: 50,
                onPressed: () {
                  openAbout();
                },
              ),
            ),

            //immagine del logo
            Container(
              margin: const EdgeInsets.only(bottom: 30.0),
              height: screen.width / 3,
              width: screen.width / 3,
              child: const Image(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.contain,
              ),
            ),

            //Label "voglio imparare"
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                tr('home'),
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            //text field input query dell'utente
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _queryController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: tr('hint'),
                  hintStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),

            //submit user query
            const SizedBox(height: 16.0),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Note(
                        query: _query,
                        lang: _currentLocale,
                      ),
                    ),
                  );
                },
                child: CustomButton(
                  text: tr('startquiz'),
                ),
              ),
            ),

            //catalogo query Trending Topics
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return const Catalogo();
                      },
                    ),
                  );
                },
                child: const CustomButton(
                  text: "Trending topics",
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleLanguage,
        child: Image.asset(
          _isEnglish
              ? 'assets/images/eng_icon.png'
              : 'assets/images/it_icon.png',
          width: 40.0,
          height: 40.0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future openAbout() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('About'),
          content: Text(
              "Ciao qui è Alex lo sviluppatore che parla, quest'applicazione ha la capacità di spiegare qualsiasi cosa gli venga data in input nel caso ottimo, un generatore infinito di domande stile quiz nel caso pessimo. updatecheck"),
          actions: [TextButton(onPressed: close, child: Text('Close'))],
        ),
      );
  void close() {
    Navigator.of(context).pop();
  }
}
