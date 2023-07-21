import 'package:flutter/material.dart';
import 'package:teachiz/components/custom_button.dart';
import 'package:easy_localization/easy_localization.dart';

class Start extends StatefulWidget {
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
      _currentLocale = _isEnglish ? Locale('it') : Locale('en');
      _isEnglish = !_isEnglish;
    });
    context.setLocale(_currentLocale);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(bottom: 30.0),
              height: screen.width / 3,
              width: screen.width / 3,
              child: Image(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.contain,
              ),
            ),
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
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, 'quiz',
                      arguments: _query);
                },
                child: CustomButton(
                  text: tr('startquiz'),
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
}
