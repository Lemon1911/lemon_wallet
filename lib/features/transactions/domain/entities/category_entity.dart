import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String type;
  final String? icon;       // nullable — Supabase allows null
  final bool isDefault;     // mirrors is_default column in Supabase

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [id, name, type, icon, isDefault];
}
