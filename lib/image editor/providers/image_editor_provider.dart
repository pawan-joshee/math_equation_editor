import 'package:flutter/material.dart';

class ImageEditorProvider extends ChangeNotifier {
  String _selectedFilter = 'Normal';
  String get selectedFilter => _selectedFilter;

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // Add more state management as needed
}
