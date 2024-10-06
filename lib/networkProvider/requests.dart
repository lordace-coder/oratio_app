import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:oratio_app/bloc/blocs.dart';
import 'package:oratio_app/networkProvider/constants.dart';

final dio = Dio(
  BaseOptions(baseUrl: BASEURL),
);

Options createHeaders(String token) {
  return Options(headers: {'Authorization': 'Bearer $token'});
}


Future<bool> submitWithdrawalRequest({
  required String token,
  required Map data,
}) async {
  try {
    final res = await dio.post('/withdraw-requests/',
        data: data, options: createHeaders(token));
    if (res.statusCode == 200 || res.statusCode == 201) {
      return true;
    }
  } on DioException catch (e) {
    print('error durring withdraw submition ${e.response!.data}');
  }
  return false;
}

void main(List<String> args) async {}
