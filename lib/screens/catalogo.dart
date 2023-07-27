import 'dart:convert';
import 'package:teachiz/components/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'note.dart'; // Import the Note page

class Catalogo extends StatefulWidget {
  @override
  _CatalogoState createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {
  List<String> _results = <String>[];
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the current locale when the dependencies change
    _currentLocale = Localizations.localeOf(context);
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Get the current locale
      Locale _currentLocale = Localizations.localeOf(context);
      String languageCode = _currentLocale.languageCode;

      // Make the API call with the selected language
      final response = await http.get(Uri.parse(
          'https://teachizapi.ew.r.appspot.com/api/allqueries?lang=$languageCode'));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final data = json.decode(response.body);

        print('API Response: $data');

        if (data is String) {
          final jsonData = json.decode(data);
          _parseResults(jsonData);
        } else if (data is Map<String, dynamic>) {
          _parseResults(data);
        } else {
          print('Invalid API response format.');
          return;
        }
      } else {
        // Handle API call failure
        print('API call failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('API call failed with error: $e');
    }
  }

  void _parseResults(Map<String, dynamic> data) {
    if (data.containsKey('results') && data['results'] is List<dynamic>) {
      List<dynamic> results = data['results'];
      setState(() {
        _results = results.map((result) => result['query'].toString()).toList();
      });
    } else {
      setState(() {
        _results =
            <String>[]; // Reset the results list if the API response is invalid
      });
      print('Invalid API response format - missing results or invalid type.');
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: Text('Topic più popolari:'),
      ),
      body: _results.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                String _query = _results[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Note(
                            query: _query,
                            lang: _currentLocale!,
                          ),
                        ),
                      );
                    },
                    child: CustomButton(
                      text: _query,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
