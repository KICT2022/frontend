import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? gender,
    DateTime? birthDate,
    List<String>? medicalHistory,
    List<String>? currentMedications,
    Guardian? guardian,
    String? address,
  }) async {
    if (_user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 실제 구현에서는 API 호출
      await Future.delayed(const Duration(seconds: 1));

      _user = _user!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        gender: gender,
        birthDate: birthDate,
        medicalHistory: medicalHistory,
        currentMedications: currentMedications,
        guardian: guardian,
        address: address,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '프로필 업데이트에 실패했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMedicalHistory(String condition) async {
    if (_user == null) return;

    final updatedHistory = List<String>.from(_user!.medicalHistory);
    if (!updatedHistory.contains(condition)) {
      updatedHistory.add(condition);
      await updateUserProfile(medicalHistory: updatedHistory);
    }
  }

  Future<void> removeMedicalHistory(String condition) async {
    if (_user == null) return;

    final updatedHistory = List<String>.from(_user!.medicalHistory);
    updatedHistory.remove(condition);
    await updateUserProfile(medicalHistory: updatedHistory);
  }

  Future<void> addCurrentMedication(String medication) async {
    if (_user == null) return;

    final updatedMedications = List<String>.from(_user!.currentMedications);
    if (!updatedMedications.contains(medication)) {
      updatedMedications.add(medication);
      await updateUserProfile(currentMedications: updatedMedications);
    }
  }

  Future<void> removeCurrentMedication(String medication) async {
    if (_user == null) return;

    final updatedMedications = List<String>.from(_user!.currentMedications);
    updatedMedications.remove(medication);
    await updateUserProfile(currentMedications: updatedMedications);
  }

  Future<void> updateGuardian(Guardian guardian) async {
    await updateUserProfile(guardian: guardian);
  }

  Future<void> removeGuardian() async {
    await updateUserProfile(guardian: null);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 