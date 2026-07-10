class Holiday {
  final DateTime date;
  final String name;

  const Holiday({required this.date, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Holiday &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          name == other.name;

  @override
  int get hashCode => date.hashCode ^ name.hashCode;
}
