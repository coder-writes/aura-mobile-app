import 'package:dio/dio.dart';

import '../../../../core/constants/app_env.dart';

class ScanRemoteDataSource {
  ScanRemoteDataSource()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppEnv.scanApiBaseUrl,
          connectTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
          headers: {'Accept': 'application/json'},
        ),
      );

  final Dio _dio;

  Future<Map<String, dynamic>> runTbScan({required String imagePath}) async {
    return _callEndpoint(path: '/predict/tb', imagePath: imagePath);
  }

  Future<Map<String, dynamic>> runEyeScan({required String imagePath}) async {
    return _callEndpoint(path: '/predict/eye-disease', imagePath: imagePath);
  }

  Future<Map<String, dynamic>> runAnemiaScan({required String imagePath}) {
    return runEyeScan(imagePath: imagePath);
  }

  Future<Map<String, dynamic>> _callEndpoint({
    required String path,
    required String imagePath,
  }) async {
    try {
      final payload = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(path, data: payload);
      return _normalizeResponse(response.data);
    } on DioException catch (error) {
      final message = _extractErrorMessage(error);
      throw Exception(message);
    } catch (error) {
      throw Exception(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Map<String, dynamic> _normalizeResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is List) {
      return {'result': data};
    }

    return {'result': data?.toString() ?? ''};
  }

  String _extractErrorMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    return error.message ?? 'Network request failed';
  }
}
