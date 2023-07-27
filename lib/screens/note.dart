import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Note extends StatefulWidget {
  final String query;
  final Locale lang;

  Note({required this.query, required this.lang});

  @override
  _NoteState createState() => _NoteState();
}

class _NoteState extends State<Note> {
  String _content = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Make the API call using the query and lang from the previous page
      final response = await http.get(Uri.parse(
          'https://teachizapi.ew.r.appspot.com/api/note?query=${widget.query}&lang=${widget.lang.languageCode}'));

      if (response.statusCode == 200) {
        // Parse the JSON response
        final data = json.decode(response.body);

        print('API Response: $data');

        if (data is Map<String, dynamic> && data.containsKey('content')) {
          setState(() {
            _content = data['content'];
          });
        } else {
          print('Invalid API response format - missing content.');
        }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Result Page'),
      ),
      body: Center(
        child:
            _content.isNotEmpty ? Text(_content) : CircularProgressIndicator(),
      ),
    );
  }
}
