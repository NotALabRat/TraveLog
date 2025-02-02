import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CreateItineraryPage(),
    );
  }
}

class CreateItineraryPage extends StatefulWidget {
  const CreateItineraryPage({super.key});

  @override
  _CreateItineraryPageState createState() => _CreateItineraryPageState();
}

class _CreateItineraryPageState extends State<CreateItineraryPage> {
  String? selectedDestination;
  DateTime? selectedDate;
  String? selectedBudget;
  String mustVisitPlaces = "";
  String itinerary = "Your itinerary will appear here.";
  List<String> selectedPreferences = []; // To store selected preferences
  String numberOfDays = ""; // To store the maximum number of stay

  final List<String> destinations = [
    "Paris",
    "Tokyo",
    "New York",
    "London",
    "Dubai"
  ];
  final List<String> budgetOptions = ["Low", "Medium", "High"];

  // List of cuisine and dietary preferences
  final List<String> preferences = [
    "Vegetarian",
    "Non-Vegetarian",
    "Vegan",
    "Italian",
    "Chinese",
    "Indian",
    "Desserts",
    "Meals",
    "Cafes"
  ];

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> fetchItinerary() async {
    if (selectedDestination == null ||
        selectedDate == null ||
        selectedBudget == null ||
        numberOfDays.isEmpty) {
      setState(() {
        itinerary = "Please select all fields.";
      });
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    String prompt =
        "Create a $numberOfDays-day travel itinerary for a trip to $selectedDestination on $formattedDate with a $selectedBudget budget. Include places to visit, restaurants, and accommodations.";
    if (mustVisitPlaces.isNotEmpty) {
      prompt += " Must-visit places: $mustVisitPlaces.";
    }
    if (selectedPreferences.isNotEmpty) {
      prompt +=
          " Dietary and cuisine preferences: ${selectedPreferences.join(", ")}.";
    }

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
          itinerary = data["candidates"][0]["content"]["parts"][0]["text"] ??
              "No response from AI.";
        });
      } else {
        setState(() {
          itinerary = "Error: ${response.statusCode} - ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        itinerary = "Failed to connect to server: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Itinerary")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Destination:", style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: selectedDestination,
              hint: const Text("Choose a destination"),
              isExpanded: true,
              items: destinations.map((String destination) {
                return DropdownMenuItem<String>(
                  value: destination,
                  child: Text(destination),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDestination = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text("Select Date:", style: TextStyle(fontSize: 18)),
            Row(
              children: [
                Text(
                  selectedDate == null
                      ? "No date selected"
                      : DateFormat('yyyy-MM-dd').format(selectedDate!),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => selectDate(context),
                  child: const Text("Pick Date"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Select Budget:", style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: selectedBudget,
              hint: const Text("Choose budget"),
              isExpanded: true,
              items: budgetOptions.map((String budget) {
                return DropdownMenuItem<String>(
                  value: budget,
                  child: Text(budget),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedBudget = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text("Maximum Number of Stay (Days):",
                style: TextStyle(fontSize: 18)),
            TextField(
              decoration: const InputDecoration(
                hintText: "Enter the number of days",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  numberOfDays = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text("Cuisine and Dietary Preferences:",
                style: TextStyle(fontSize: 18)),
            Wrap(
              spacing: 8.0,
              children: preferences.map((preference) {
                return FilterChip(
                  label: Text(preference),
                  selected: selectedPreferences.contains(preference),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedPreferences.add(preference);
                      } else {
                        selectedPreferences.remove(preference);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text("Must-Visit Places (Optional):",
                style: TextStyle(fontSize: 18)),
            TextField(
              decoration: const InputDecoration(
                hintText: "Enter must-visit places, separated by commas",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  mustVisitPlaces = value;
                });
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: fetchItinerary,
                child: const Text("Generate Itinerary"),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  itinerary,
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
