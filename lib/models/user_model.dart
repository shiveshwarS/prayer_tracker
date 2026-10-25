class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final DateTime createdAt;

  String get firstName {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? name : parts.first;
  }

  String get initial {
    final String trimmed = name.trim();
    return trimmed.isEmpty ? 'N' : trimmed.substring(0, 1).toUpperCase();
  }

  UserModel copyWith({String? name, String? phone}) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'phone': phone,
    'createdAt': createdAt.toIso8601String(),
  };

  static UserModel? fromJson(Object? value) {
    if (value is! Map) {
      return null;
    }
    final Object? id = value['id'];
    final Object? name = value['name'];
    final Object? phone = value['phone'];
    final Object? createdAt = value['createdAt'];
    if (id is! String ||
        name is! String ||
        phone is! String ||
        createdAt is! String) {
      return null;
    }
    final DateTime? parsedDate = DateTime.tryParse(createdAt);
    if (id.trim().isEmpty ||
        name.trim().isEmpty ||
        phone.trim().isEmpty ||
        parsedDate == null) {
      return null;
    }
    return UserModel(
      id: id,
      name: name.trim(),
      phone: phone.trim(),
      createdAt: parsedDate,
    );
  }
}
