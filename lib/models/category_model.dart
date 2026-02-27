import 'package:flutter/material.dart';

class CategoryModel {
  final String name;
  final String imageUrl;
  final IconData? icon;

  CategoryModel({
    required this.name,
    this.imageUrl = '',
    this.icon,
  });

  static List<CategoryModel> getCategories() {
    return [
      CategoryModel(
        name: 'Birds',
        imageUrl: 'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?w=200&q=80',
      ),
      CategoryModel(
        name: 'Eggs',
        imageUrl: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=200&q=80',
      ),
      CategoryModel(
        name: 'Chicks',
        imageUrl: 'https://images.unsplash.com/photo-1589923188651-268a9765e432?w=200&q=80',
      ),
      CategoryModel(
        name: 'Ducks',
        imageUrl: 'https://images.unsplash.com/photo-1459682191995-97e65bb4d67d?w=200&q=80',
      ),
    ];
  }
}
