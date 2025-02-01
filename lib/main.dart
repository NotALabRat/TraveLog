import 'package:flutter/material.dart';
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
      title: 'Create Itinerary',
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
  String? _selectedDestination;
  DateTime? _selectedDate;
  String? _selectedBudget;

  final List<String> destinations = [
    "New York",
    "Paris",
    "Tokyo",
    "London",
    "Dubai"
  ];
  final List<String> budgetOptions = ["Low", "Medium", "High"];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitItinerary() {
    if (_selectedDestination == null ||
        _selectedDate == null ||
        _selectedBudget == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select all fields!")),
      );
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Itinerary Summary"),
        content: Text(
          "Destination: $_selectedDestination\nDate: $formattedDate\nBudget: $_selectedBudget",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
            const Text("Select Destination",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedDestination,
              hint: const Text("Choose a destination"),
              items: destinations.map((String destination) {
                return DropdownMenuItem<String>(
                  value: destination,
                  child: Text(destination),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                _selectedDestination = value;
              }),
            ),
            const SizedBox(height: 20),
            const Text("Select Date",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => _selectDate(context),
              child: Text(
                _selectedDate == null
                    ? "Pick a date"
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Select Budget",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              value: _selectedBudget,
              hint: const Text("Choose a budget"),
              items: budgetOptions.map((String budget) {
                return DropdownMenuItem<String>(
                  value: budget,
                  child: Text(budget),
                );
              }).toList(),
              onChanged: (value) => setState(() {
                _selectedBudget = value;
              }),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _submitItinerary,
                child: const Text("Submit Itinerary"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
