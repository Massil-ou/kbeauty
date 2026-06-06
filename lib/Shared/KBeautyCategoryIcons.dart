import 'package:flutter/material.dart';

IconData kBeautyCategoryIcon(String value) {
  return switch (value.trim().toLowerCase()) {
    'content_cut' || 'hair' || 'coiffure' => Icons.content_cut_rounded,
    'back_hand' || 'nails' || 'ongles' => Icons.back_hand_outlined,
    'brush' || 'makeup' || 'maquillage' => Icons.brush_outlined,
    'spa' || 'massage' => Icons.spa_outlined,
    'auto_awesome' || 'epilation' || 'épilation' => Icons.auto_awesome_outlined,
    'storefront' => Icons.storefront_outlined,
    'favorite' => Icons.favorite_border_rounded,
    _ => Icons.category_outlined,
  };
}
