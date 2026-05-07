import 'package:flutter/material.dart';

class IconHelper {
  static IconData getIconData(String? iconName) {
    if (iconName == null) return Icons.category_rounded;
    
    switch (iconName.toLowerCase()) {
      case 'fastfood':
      case 'food':
      case 'restaurant':
        return Icons.fastfood_rounded;
      case 'shopping_bag':
      case 'shopping':
      case 'cart':
        return Icons.shopping_bag_rounded;
      case 'directions_car':
      case 'transport':
      case 'car':
        return Icons.directions_car_rounded;
      case 'home':
      case 'housing':
      case 'rent':
        return Icons.home_rounded;
      case 'movie':
      case 'entertainment':
      case 'game':
        return Icons.movie_rounded;
      case 'payments':
      case 'bill':
      case 'cash':
        return Icons.payments_rounded;
      case 'trending_up':
      case 'income':
      case 'salary':
        return Icons.trending_up_rounded;
      case 'medical_services':
      case 'health':
      case 'doctor':
        return Icons.medical_services_rounded;
      case 'school':
      case 'education':
        return Icons.school_rounded;
      case 'fitness_center':
      case 'gym':
      case 'sport':
        return Icons.fitness_center_rounded;
      case 'flight':
      case 'travel':
        return Icons.flight_takeoff_rounded;
      case 'electric_bolt':
      case 'utilities':
        return Icons.electric_bolt_rounded;
      case 'wifi':
      case 'internet':
        return Icons.wifi_rounded;
      case 'pets':
        return Icons.pets_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
