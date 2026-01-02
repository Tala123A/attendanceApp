class Student {
  final int id;
  final String name;
  bool present;

  Student({
    required this.id,
    required this.name,
    this.present = false,
  });
}
