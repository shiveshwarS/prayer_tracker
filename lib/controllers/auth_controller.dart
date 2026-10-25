import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/local_storage_service.dart';
import '../utils/validators.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required LocalStorageService storage,
    DateTime Function()? clock,
  }) : _storage = storage,
       _clock = clock ?? DateTime.now;

  final LocalStorageService _storage;
  final DateTime Function() _clock;

  UserModel? _user;
  bool _isInitialized = false;
  bool _isSaving = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isInitialized => _isInitialized;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get isSignedIn => _user != null;

  Future<void> initialize() async {
    try {
      _user = await _storage.loadUser();
    } on Object {
      _user = null;
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> signUp({required String name, required String phone}) async {
    final String cleanName = name.trim();
    final String? nameError = Validators.name(cleanName);
    final String? phoneError = Validators.phone(phone);
    if (nameError != null || phoneError != null) {
      _errorMessage = nameError ?? phoneError;
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final UserModel newUser = UserModel(
      id: 'demo-${_clock().microsecondsSinceEpoch}',
      name: cleanName,
      phone: phone.trim(),
      createdAt: _clock(),
    );

    try {
      await _storage.saveUser(newUser);
      _user = newUser;
      _isSaving = false;
      notifyListeners();
      return true;
    } on Object {
      _isSaving = false;
      _errorMessage = 'Your profile could not be saved. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
  }) async {
    final UserModel? current = _user;
    if (current == null) {
      return false;
    }
    final String cleanName = name.trim();
    final String cleanPhone = phone.trim();
    final String? nameError = Validators.name(cleanName);
    final String? phoneError = Validators.phone(cleanPhone);
    if (nameError != null || phoneError != null) {
      _errorMessage = nameError ?? phoneError;
      notifyListeners();
      return false;
    }

    final UserModel updated = current.copyWith(
      name: cleanName,
      phone: cleanPhone,
    );
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _storage.saveUser(updated);
      _user = updated;
      _isSaving = false;
      notifyListeners();
      return true;
    } on Object {
      _isSaving = false;
      _errorMessage = 'Your changes could not be saved. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void clearLocalUser() {
    _user = null;
    _isSaving = false;
    _errorMessage = null;
    notifyListeners();
  }
}
