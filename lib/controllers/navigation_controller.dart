import 'package:flutter/foundation.dart';

class NavigationController extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  void select(int index) {
    if (index < 0 || index > 2 || index == _index) {
      return;
    }
    _index = index;
    notifyListeners();
  }

  void goHome() => select(0);

  void goCompass() => select(1);

  void goProfile() => select(2);
}
