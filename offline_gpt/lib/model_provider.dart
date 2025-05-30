import 'package:flutter/foundation.dart';

class ModelProvider extends ChangeNotifier {
  String? _selectedModel;

  String? get selectedModel => _selectedModel;

  void setModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }
}
