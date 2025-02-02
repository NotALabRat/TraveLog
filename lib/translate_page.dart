import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslatePage extends StatefulWidget {
  @override
  _TranslatePageState createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage> {
  TextEditingController _controller = TextEditingController();
  String _translatedText = "";
  bool _isLoading = false;

  // Define your Gemini API key here
  final String apiKey = "AIzaSyBZmER7mtVUYnP0aouNGAsgdZLTocfsMpA";

  // Function to handle translation using Gemini API
  Future<void> translateText(String text) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'https://api.gemini.com/translate'); // Example endpoint (change as per Gemini docs)
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final body = json.encode({
      'source_language': 'en', // Change based on your source language
      'target_language': 'es', // Change to your desired target language
      'text': text,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _translatedText =
              data['translated_text']; // Change based on Gemini API response
          _isLoading = false;
        });
      } else {
        setState(() {
          _translatedText = "Error: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _translatedText = "Error: $error";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Translate Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'Enter text to translate'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      translateText(_controller.text);
                    },
              child:
                  _isLoading ? CircularProgressIndicator() : Text('Translate'),
            ),
            SizedBox(height: 20),
            Text(_translatedText),
          ],
        ),
      ),
    );
  }
}
