import 'package:dio/dio.dart';
import '../../utils/app_logger.dart';

class DioLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final message =
        '''
╔═══════════════════════════════════════════════════════════════
║ 🛫 REQUEST: ${options.method}
║ 🌐 URL: ${options.baseUrl}${options.path}
║ 🎫 HEADERS: ${options.headers}
║ 📦 DATA: ${options.data ?? 'None'}
╚═══════════════════════════════════════════════════════════════
''';
    AppLogger.log(message);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final message =
        '''
╔═══════════════════════════════════════════════════════════════
║ ✅ RESPONSE [${response.statusCode}]
║ 🌐 URL: ${response.requestOptions.path}
║ 📦 DATA: ${response.data}
╚═══════════════════════════════════════════════════════════════
''';
    AppLogger.log(message);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message =
        '''
╔═══════════════════════════════════════════════════════════════
║ ❌ ERROR [${err.response?.statusCode ?? 'Unknown'}]
║ 🌐 URL: ${err.requestOptions.path}
║ 💬 MESSAGE: ${err.message}
║ 📦 DATA: ${err.response?.data}
╚═══════════════════════════════════════════════════════════════
''';
    AppLogger.log(message);
    super.onError(err, handler);
  }
}
