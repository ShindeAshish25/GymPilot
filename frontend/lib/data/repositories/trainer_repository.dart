import 'dart:convert';
import '../models/trainer_model.dart';
import '../services/api_service.dart';

class TrainerRepository {
  final ApiService _apiService = ApiService();

  Future<List<TrainerModel>> getTrainers() async {
    final response = await _apiService.get('/gym/trainers'); // Adjusted to match backend routes if needed or gymRoutes
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => TrainerModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load trainers');
    }
  }

  Future<TrainerModel> addTrainer(Map<String, dynamic> trainerData) async {
    final response = await _apiService.post('/gym/trainers', trainerData);
    if (response.statusCode == 200) {
      return TrainerModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add trainer');
    }
  }

  Future<void> deleteTrainer(String id) async {
    final response = await _apiService.delete('/gym/trainers/$id');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete trainer');
    }
  }

  Future<TrainerModel> updateTrainer(String id, Map<String, dynamic> trainerData) async {
    final response = await _apiService.put('/gym/trainers/$id', trainerData);
    if (response.statusCode == 200) {
      return TrainerModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update trainer');
    }
  }
}
