import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'login_screen.dart';
import 'records_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime selectedDate = DateTime.now();
  bool isSavedForSelectedDate = false;

  final String baseUrl = "http://localhost/attendance_backend";
  final EncryptedSharedPreferences _prefs =
  EncryptedSharedPreferences();

  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    _checkAuth();
    fetchStudents();
  }

  Future<void> _checkAuth() async {
    try {
      final key = await _prefs.getString('auth_key');
      if (key.isEmpty) {
        _forceLogout();
      }
    } catch (_) {
      _forceLogout();
    }
  }

  Future<void> _forceLogout() async {
    await _prefs.remove('auth_key');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  Future<void> fetchStudents() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/get_students.php"));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          students = data.map<Map<String, dynamic>>((s) {
            final attendanceRaw = s['attendanceByDate'];
            final attendanceMap =
            attendanceRaw is Map ? Map<String, dynamic>.from(attendanceRaw) : {};

            return {
              "id": s["id"],
              "name": s["name"],
              "absences": s["absences"],
              "attendanceByDate": attendanceMap,
            };
          }).toList();
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load students")),
      );
    }
  }

  bool isClassDay(DateTime date) {
    return date.weekday == DateTime.tuesday ||
        date.weekday == DateTime.thursday;
  }

  String get dateKey => selectedDate.toIso8601String().split("T")[0];


  bool getAttendance(Map<String, dynamic> student) {
    return student["attendanceByDate"][dateKey] ?? false;
  }

  void setAttendance(Map<String, dynamic> student, bool value) {
    student["attendanceByDate"][dateKey] = value;
  }

  bool alreadySaved(Map<String, dynamic> student) {
    return student["attendanceByDate"].containsKey(dateKey);
  }

  Future<void> saveAttendance() async {
    if (!isClassDay(selectedDate)) return;

    try {
      for (var s in students) {
        final wasAlreadySaved = alreadySaved(s);
        final present = getAttendance(s);

        if (!wasAlreadySaved && !present) {
          s["absences"] = (s["absences"] > 0) ? s["absences"] - 1 : 0;
        }

        final response = await http.post(
          Uri.parse("$baseUrl/post_attendance.php"),
          body: {
            "api_key": "ATTENDANCE123",
            "student_id": s["id"].toString(),
            "present": present ? "1" : "0",
            "date": dateKey,
          },
        );

        final res = jsonDecode(response.body);
        if (res["status"] != "success") {
          throw Exception();
        }
      }

      setState(() => isSavedForSelectedDate = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Attendance saved successfully")),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error saving attendance")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text("Attendance", style: GoogleFonts.poppins()),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _forceLogout,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: TableCalendar(
              focusedDay: selectedDate,
              firstDay: DateTime(2024),
              lastDay: DateTime(2030),
              headerStyle: const HeaderStyle(formatButtonVisible: false),
              selectedDayPredicate: (day) =>
              day.year == selectedDate.year &&
                  day.month == selectedDate.month &&
                  day.day == selectedDate.day,
              onDaySelected: (selected, _) {
                setState(() {
                  selectedDate = selected;
                  isSavedForSelectedDate = false;
                });
              },
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, i) {
                final s = students[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      s["name"],
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Remaining absences: ${s["absences"]}",
                      style: TextStyle(
                        color: s["absences"] == 0 ? Colors.red : Colors.black,
                      ),
                    ),
                    trailing: Switch(
                      value: getAttendance(s),
                      onChanged: isClassDay(selectedDate)
                          ? (v) => setState(() => setAttendance(s, v))
                          : null,
                    ),
                  ),
                );
              },
              childCount: students.length,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: isClassDay(selectedDate) ? saveAttendance : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("SAVE ATTENDANCE"),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecordsScreen(students: students),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("VIEW RECORDS"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
