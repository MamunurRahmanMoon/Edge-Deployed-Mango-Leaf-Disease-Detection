import 'package:flutter/material.dart';
import '../models/scan_history.dart';
import '../services/database_helper.dart';

class AppProvider with ChangeNotifier {
  String _currentLanguage = 'EN';
  List<ScanHistory> _historyList = [];

  String get currentLanguage => _currentLanguage;
  List<ScanHistory> get historyList => _historyList;

  AppProvider() {
    loadHistory();
  }

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == 'EN' ? 'BN' : 'EN';
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _historyList = await DatabaseHelper.instance.readAllHistory();
    notifyListeners();
  }

  Future<void> addHistory(ScanHistory history) async {
    await DatabaseHelper.instance.insert(history);
    await loadHistory();
  }
}
