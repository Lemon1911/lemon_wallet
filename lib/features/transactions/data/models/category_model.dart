import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.type,
    super.icon,
    super.isDefault,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Unnamed').toString(),
      type: (json['type'] ?? 'expense').toString(),
      icon: json['icon']?.toString(),             // nullable safe
      isDefault: json['is_default'] == true ||
          json['is_default'] == 1,               // works for both bool (Supabase) and int (SQLite)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'is_default': isDefault ? 1 : 0,           // SQLite stores as int
    };
  }
}
