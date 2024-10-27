class UserFields {
  static final String date = 'Date';
  static final String id = 'id';
  static final String name = 'Name';
  static final String method = 'Method';
  static final String type = 'Type';
  static final String total = 'Total';
  static final String category = 'Category';

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
