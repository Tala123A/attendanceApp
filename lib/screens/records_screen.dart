import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> students;
  const RecordsScreen({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Attendance Records", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(student["name"], style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Remaining absences: ${student["absences"]}"),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: (student["attendanceByDate"] as Map<String, dynamic>)
                        .entries
                        .map((e) => Chip(
                      label: Text(
                          "${e.key}: ${e.value ? 'Present' : 'Absent'}"),
                      backgroundColor:
                      e.value ? Colors.green[200] : Colors.red[200],
                    ))
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
