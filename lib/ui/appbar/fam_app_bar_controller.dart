import 'package:flutter/foundation.dart';

class FamAppBarController extends ChangeNotifier {
  bool _showSearch = false;
  bool get showSearch => _showSearch;

  void toggleSearch([bool? value]) {
    _showSearch = value ?? !_showSearch;
    notifyListeners();
  }
}
