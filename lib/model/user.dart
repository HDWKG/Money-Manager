class UserFields {
  static const String date = 'Date';
  static const String id = 'id';
  static const String name = 'Name';
  static const String method = 'Method';
  static const String type = 'Type';
  static const String total = 'Total';
  static const String category = 'Category';

  static List<String> getFields() =>
      [id, name, method, type, total, category, date];
}

class User {
  final DateTime date;
  final int? id;
  final String name;
  final String method;
  final String type;
  final int total;
  final String? category;

  const User(
      {required this.date,
      this.id,
      required this.name,
      required this.method,
      required this.type,
      required this.total,
      this.category});
  User copy({
    final DateTime? date,
    final int? id,
    final String? name,
    final String? method,
    final String? type,
    final int? total,
    final String? category,
  }) =>
      User(
          date: date ?? this.date,
          id: id ?? this.id,
          name: name ?? this.name,
          method: method ?? this.method,
          type: type ?? this.type,
          total: total ?? this.total,
          category: category ?? this.category);

  static User fromjson(Map<String, dynamic> json) => User(
        id: json[UserFields.id] != null
            ? int.tryParse(json[UserFields.id].toString())
            : null,
        name: json[UserFields.name],
        method: json[UserFields.method],
        type: json[UserFields.type],
        total: int.tryParse(json[UserFields.total]?.toString() ?? '0') ?? 0,
        category: json[UserFields.category],
        date: fromExcelSerial(stringToDouble(json[UserFields.date])),
      );
  static DateTime fromExcelSerial(double serial) {
    return DateTime(1899, 12, 30).add(Duration(days: serial.toInt()));
  }

  static double stringToDouble(String dateString) {
  try {
    return double.parse(dateString);
  } catch (e) {
    return 0;
  }
}

  Map<String, dynamic> toJson() => {
        UserFields.date: date.toIso8601String(),
        UserFields.id: id,
        UserFields.name: name,
        UserFields.method: method,
        UserFields.type: type,
        UserFields.total: total,
        UserFields.category: category,
      };
}
