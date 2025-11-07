import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rabbit/core/network/dio_client.dart';
import 'package:rabbit/core/network/api_constants.dart';

/// Provider for DioClient instance
final dioClientProvider = Provider<DioClient>((ref) {
  // TODO: Change to prodBaseUrl in production
  return DioClient(
    baseUrl: ApiConstants.devBaseUrl,
    connectTimeout: ApiConstants.connectTimeout,
    receiveTimeout: ApiConstants.receiveTimeout,
  );
});
