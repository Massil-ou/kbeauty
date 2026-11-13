import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/App/Manager.dart';

class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.reply);
  final ResponseBody Function(RequestOptions) reply;
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
          Future<void>? cancelFuture) async =>
      reply(options);
  @override
  void close({bool force = false}) {}
}

ResponseBody response(int status, Map<String, dynamic> body) =>
    ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: ['application/json']
    });
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
      'bootstrap and expired session use the KBeauty project and rotate tokens',
      () async {
    SharedPreferences.setMockInitialValues({
      'kbeauty_access': 'old',
      'kbeauty_refresh': 'refresh',
      'kbeauty_device_id': 'fixture-device'
    });
    final manager = Manager();
    var refreshes = 0;
    var protected = 0;
    manager.dio.httpClientAdapter = FakeAdapter((r) {
      if (r.path == '/auth/refresh') {
        refreshes++;
        expect((r.data as Map)['project_code'], 'kbeauty');
        return response(200, {
          'success': true,
          'data': {
            'access_token': 'new-$refreshes',
            'refresh_token': 'rotated-$refreshes',
            'user': {'role': 'client'}
          }
        });
      }
      if (r.path == '/kbeauty/auth/session')
        return response(200, {
          'success': true,
          'data': {
            'user': {'role': 'client'}
          }
        });
      protected++;
      if (protected == 1)
        return response(401, {'success': false, 'code': 903, 'message': ''});
      expect(r.headers['Authorization'], 'Bearer new-2');
      return response(200, {'success': true, 'data': {}});
    });
    await manager.bootstrap();
    expect((await manager.dio.post('/kbeauty/orders/list')).statusCode, 200);
    expect(refreshes, 2);
    expect(protected, 2);
    expect(manager.refreshToken, 'rotated-2');
  });
}
