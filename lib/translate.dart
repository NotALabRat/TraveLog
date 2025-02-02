import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  _TranslatorPageState createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  final TextEditingController _textController = TextEditingController();
  String translatedText = "Your translation will appear here.";
  String? selectedLanguage;

  final List<String> languages = [
    "French",
    "Spanish",
    "German",
    "Chinese",
    "Japanese",
    "Hindi"
  ];

  Future<void> translateText() async {
    if (_textController.text.isEmpty || selectedLanguage == null) {
      setState(() {
        translatedText = "Please enter text and select a language.";
      });
      return;
    }

    String prompt =
        "Translate the following text into $selectedLanguage: \"${_textController.text}\"";

    const String apiKey =
        "AIzaSyBZmER7mtVUYnP0aouNGAsgdZLTocfsMpA"; // Replace with your actual API key
    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          translatedText = data["candidates"][0]["content"]["parts"][0]
                  ["text"] ??
              "No translation available.";
        });
      } else {
        setState(() {
          translatedText = "Error: ${response.statusCode} - ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        translatedText = "Failed to connect to server: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("In-App Translator")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter text to translate:",
                style: TextStyle(fontSize: 18)),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Type your text here",
              ),
            ),
            const SizedBox(height: 20),
            const Text("Select Target Language:",
                style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: selectedLanguage,
              hint: const Text("Choose a language"),
              isExpanded: true,
              items: languages.map((String lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedLanguage = newValue;
                });
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: translateText,
                child: const Text("Translate"),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  translatedText,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
