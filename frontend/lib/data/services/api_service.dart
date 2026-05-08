import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Using localhost for Android emulator. Change to your backend IP/URL.
  static const String baseUrl = 'http://localhost:5000/api'; 
  
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'x-auth-token': token,
    };
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    
    try {
      return await http.post(url, headers: headers, body: json.encode(body));
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    
    try {
      return await http.get(url, headers: headers);
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    
    try {
      return await http.put(url, headers: headers, body: json.encode(body));
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }

  Future<http.Response> postMultipart(
    String endpoint, 
    Map<String, String> fields, 
    Uint8List fileBytes, 
    String fileName, 
    String fileKey,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      var request = http.MultipartRequest('POST', url);
      
      if (token != null) {
        request.headers['x-auth-token'] = token;
      }

      request.fields.addAll(fields);
      
      // Determine mime type
      String extension = fileName.split('.').last.toLowerCase();
      MediaType contentType;
      if (extension == 'png') {
        contentType = MediaType('image', 'png');
      } else if (extension == 'webp') {
        contentType = MediaType('image', 'webp');
      } else if (extension == 'gif') {
        contentType = MediaType('image', 'gif');
      } else {
        contentType = MediaType('image', 'jpeg');
      }

      var file = http.MultipartFile.fromBytes(
        fileKey, 
        fileBytes,
        filename: fileName,
        contentType: contentType,
      );
      request.files.add(file);

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }

  Future<http.Response> putMultipart(
    String endpoint, 
    Map<String, String> fields, 
    Uint8List fileBytes, 
    String fileName, 
    String fileKey,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      var request = http.MultipartRequest('PUT', url);
      
      if (token != null) {
        request.headers['x-auth-token'] = token;
      }

      request.fields.addAll(fields);
      
      String extension = fileName.split('.').last.toLowerCase();
      MediaType contentType;
      if (extension == 'png') {
        contentType = MediaType('image', 'png');
      } else if (extension == 'webp') {
        contentType = MediaType('image', 'webp');
      } else if (extension == 'gif') {
        contentType = MediaType('image', 'gif');
      } else {
        contentType = MediaType('image', 'jpeg');
      }

      var file = http.MultipartFile.fromBytes(
        fileKey, 
        fileBytes,
        filename: fileName,
        contentType: contentType,
      );
      request.files.add(file);

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$baseUrl$endpoint');
    
    try {
      return await http.delete(url, headers: headers);
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }
}
