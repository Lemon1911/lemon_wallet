import 'package:flutter/material.dart';

class IconHelper {
  static IconData getIconData(String? iconName, [String? categoryName]) {
    String searchKey = (iconName ?? categoryName ?? '').toLowerCase();
    
    if (searchKey.contains('food') || searchKey.contains('drink') || searchKey.contains('restaurant')) {
      return Icons.fastfood_rounded;
    }
    if (searchKey.contains('shop') || searchKey.contains('cart') || searchKey.contains('store')) {
      return Icons.shopping_bag_rounded;
    }
    if (searchKey.contains('transport') || searchKey.contains('car') || searchKey.contains('taxi') || searchKey.contains('bus')) {
      return Icons.directions_car_rounded;
    }
    if (searchKey.contains('home') || searchKey.contains('house') || searchKey.contains('rent') || searchKey.contains('mortgage')) {
      return Icons.home_rounded;
    }
    if (searchKey.contains('movie') || searchKey.contains('entertainment') || searchKey.contains('game') || searchKey.contains('fun')) {
      return Icons.movie_rounded;
    }
    if (searchKey.contains('payment') || searchKey.contains('bill') || searchKey.contains('cash') || searchKey.contains('salary')) {
      return Icons.payments_rounded;
    }
    if (searchKey.contains('trend') || searchKey.contains('invest') || searchKey.contains('stock')) {
      return Icons.trending_up_rounded;
    }
    if (searchKey.contains('medic') || searchKey.contains('health') || searchKey.contains('doctor') || searchKey.contains('pharmacy')) {
      return Icons.medical_services_rounded;
    }
    if (searchKey.contains('school') || searchKey.contains('educat') || searchKey.contains('book')) {
      return Icons.school_rounded;
    }
    if (searchKey.contains('fitness') || searchKey.contains('gym') || searchKey.contains('sport')) {
      return Icons.fitness_center_rounded;
    }
    if (searchKey.contains('flight') || searchKey.contains('travel') || searchKey.contains('hotel') || searchKey.contains('trip')) {
      return Icons.flight_takeoff_rounded;
    }
    if (searchKey.contains('electr') || searchKey.contains('utility') || searchKey.contains('power') || searchKey.contains('water')) {
      return Icons.electric_bolt_rounded;
    }
    if (searchKey.contains('wifi') || searchKey.contains('internet') || searchKey.contains('telecom')) {
      return Icons.wifi_rounded;
    }
    if (searchKey.contains('pet') || searchKey.contains('dog') || searchKey.contains('cat')) {
      return Icons.pets_rounded;
    }
    if (searchKey.contains('gift') || searchKey.contains('present') || searchKey.contains('donat')) {
      return Icons.card_giftcard_rounded;
    }
    if (searchKey.contains('work') || searchKey.contains('office') || searchKey.contains('job')) {
      return Icons.work_rounded;
    }
    if (searchKey.contains('insurance') || searchKey.contains('protect')) {
      return Icons.verified_user_rounded;
    }
    if (searchKey.contains('subscription') || searchKey.contains('recur')) {
      return Icons.subscriptions_rounded;
    }

    return Icons.category_rounded;
  }
}
