import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final List<Map<String, dynamic>> students = [
    {"id": 1, "name": "Ali Ahmad", "present": false},
    {"id": 2, "name": "Sara Khalil", "present": false},
    {"id": 3, "name": "Omar Hassan", "present": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Attendance"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          return SwitchListTile(
            title: Text(students[index]["name"]),
            value: students[index]["present"],
            onChanged: (value) {
              setState(() {
                students[index]["present"] = value;
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSummary(context);
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  void _showSummary(BuildContext context) {
    final present = students.where((s) => s["present"]).length;
    final absent = students.length - present;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Attendance Saved"),
        content: Text("Present: $present\nAbsent: $absent"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }
}
