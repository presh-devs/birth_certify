
// lib/features/storacha/data/datasources/storacha_datasource.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/storacha_models.dart';

class StorachaDatasource {
  static const String baseUrl = 'http://localhost:3000'; // Update with your server URL
  
  Future<StorachaUploadResponse> submitBirthRegistration({
    required Map<String, dynamic> birthData,
    File? supportingDocument,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/birth-registration');
      final request = http.MultipartRequest('POST', uri);
      
      // Add birth data as JSON
      request.fields['birthData'] = jsonEncode(birthData);
      
      // Add supporting document if provided
      if (supportingDocument != null) {
        final file = await http.MultipartFile.fromPath(
          'supportingDocument',
          supportingDocument.path,
        );
        request.files.add(file);
      }
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return StorachaUploadResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to submit registration: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<WalletData> generateWallet() async {
    try {
      final uri = Uri.parse('$baseUrl/generate-wallet');
      final response = await http.post(uri);
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return WalletData.fromJson(jsonData);
      } else {
        throw Exception('Failed to generate wallet: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<Map<String, dynamic>> verifyNFT(int tokenId) async {
    try {
      final uri = Uri.parse('$baseUrl/verify-nft/$tokenId');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to verify NFT: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  Future<Map<String, dynamic>> getHealthStatus() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Health check failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
