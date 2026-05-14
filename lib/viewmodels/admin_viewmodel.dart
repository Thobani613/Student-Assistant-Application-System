/*
 * Student Numbers: 224081110, 222001607, 222000452, 224065010, 221024286, 224067603, 224054263, 221046289, 222088478, 224013987
 * Student Names: M Lesenyeho, M Machedi, Z Sidamba, B Nakupi, H Sekethwayo, J O Molaba, K Semela, N Gumede, T Mjiyakho, K D Selebalo
 * Question: Admin ViewModel (MVVM - ViewModel Layer)
 */

import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../repositories/application_repository.dart';

enum AdminViewState { idle, loading, success, error }

class AdminViewModel extends ChangeNotifier {
  final ApplicationRepository _repo = ApplicationRepository();

  AdminViewState _state = AdminViewState.idle;
  List<ApplicationModel> _allApplications = [];
  String? _errorMessage;
  String _currentFilter = 'all';

  AdminViewState get state => _state;
  String? get errorMessage => _errorMessage;
  String get currentFilter => _currentFilter;

  List<ApplicationModel> get filteredApplications {
    if (_currentFilter == 'all') return _allApplications;
    return _allApplications.where((a) => a.status == _currentFilter).toList();
  }

  int get pendingCount =>
      _allApplications.where((a) => a.status == 'pending').length;
  int get approvedCount =>
      _allApplications.where((a) => a.status == 'approved').length;
  int get rejectedCount =>
      _allApplications.where((a) => a.status == 'rejected').length;

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> loadAllApplications() async {
    _state = AdminViewState.loading;
    notifyListeners();
    try {
      _allApplications = await _repo.getAllApplications();
      _state = AdminViewState.success;
    } catch (e) {
      _state = AdminViewState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<bool> approveApplication(String id) async {
    return await _updateStatus(id, 'approved');
  }

  Future<bool> rejectApplication(String id) async {
    return await _updateStatus(id, 'rejected');
  }

  Future<bool> _updateStatus(String id, String status) async {
    try {
      await _repo.updateApplicationStatus(id, status);
      final idx = _allApplications.indexWhere((a) => a.id == id);
      if (idx != -1) {
        _allApplications[idx] = _allApplications[idx].copyWith(status: status);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteApplication(String id) async {
    try {
      await _repo.deleteApplication(id);
      _allApplications.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
