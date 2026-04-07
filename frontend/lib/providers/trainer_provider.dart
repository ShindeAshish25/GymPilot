import 'package:flutter/foundation.dart';
import '../data/models/trainer_model.dart';
import '../data/repositories/trainer_repository.dart';

class TrainerProvider with ChangeNotifier {
  final TrainerRepository _repository = TrainerRepository();
  List<TrainerModel> _trainers = [];
  bool _isLoading = false;

  List<TrainerModel> get trainers => _trainers;
  bool get isLoading => _isLoading;

  Future<void> fetchTrainers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _trainers = await _repository.getTrainers();
    } catch (e) {
      debugPrint('Error fetching trainers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTrainer(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final trainer = await _repository.addTrainer(data);
      _trainers.add(trainer);
      return true;
    } catch (e) {
      debugPrint('Error adding trainer: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTrainer(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updated = await _repository.updateTrainer(id, data);
      final index = _trainers.indexWhere((t) => t.id == id);
      if (index != -1) {
        _trainers[index] = updated;
      }
      return true;
    } catch (e) {
      debugPrint('Error updating trainer: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTrainer(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.deleteTrainer(id);
      _trainers.removeWhere((t) => t.id == id);
      return true;
    } catch (e) {
      debugPrint('Error deleting trainer: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
