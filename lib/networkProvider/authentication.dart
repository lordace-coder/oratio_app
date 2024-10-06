import 'package:dio/dio.dart';
import 'package:oratio_app/networkProvider/constants.dart';
import 'package:oratio_app/networkProvider/notifications.dart';

enum ResponseType { success, error, connectionFailed }

final dio = Dio(
  BaseOptions(baseUrl: BASEURL),
);

///also handles checking of errors
///
///to check if there is an error check if the map contains key ['error']
///
///information on the error is contained in the ['error_message'] key of the returned data
Future<Map<String, dynamic>> login(String email, String password) async {
  Map<String, dynamic> data = {};
  try {
    final response = await dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    data = response.data as Map<String, dynamic>;
  } on DioException catch (e) {
    print(e);
    data['error'] = true;

    data['error_message'] = "password or email is incorrect";
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      data['error_message'] = "poor internet connection";
    }
  }
  return data;
}

Future<Map<String, dynamic>> signup(Map<String, String> postedData) async {
  Map<String, dynamic> data = {};
  try {
    final response = await dio.post('/auth/signup', data: postedData);
    data = response.data as Map<String, dynamic>;
  } on DioException catch (e) {
    data['error'] = true;
    data['status_code'] = e.response!.statusCode;
    data['error_message'] = e.response!.data;
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      data['error_message'] = "poor internet connection";
    }
  }
  return data;
}

///view for verifying tokens
///errors should be handled for cases like no internet connection and server side errors
Future<ResponseType> isTokenValid(String token) async {
  try {
    final response = await dio.post('/auth/verify', data: {'token': token});
    print(response.data);
    if (response.statusCode == 200) {
      return ResponseType.success;
    } else {
      return ResponseType.error;
    }
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return ResponseType.connectionFailed;
    }
    return ResponseType.error;
  }
}

Future<String> refreshTokens(String refreshToken) async {
  final response =
      await dio.post('/auth/verify', data: {'token': refreshToken});
  return response.data['token'].toString();
}

///to be called to delete account
Future<void> deleteUser(String access) async {
  dio.get(
    '/delete',
    options: createHeaders(access),
  );
}

Future<Map<String, dynamic>> getUser(String token) async {
  Map<String, dynamic> data = {};
  try {
    final response = await dio.get('/me', options: createHeaders(token));
    data = response.data as Map<String, dynamic>;
  } on DioException catch (e) {
    data['error'] = true;
    data['status_code'] = e.response!.statusCode;
    data['error_message'] = e.response!.data;
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      data['error_message'] = "poor internet connection";
    }
  }
  return data;
}

void main(List<String> args) {
  // *login works
  login('lordyacey@gmail.com', 'lordace12').then((data) => print(data));

  // todo check signup
  // refreshTokens('ss').then((val) => print(val)).catchError((e) {
  //   e = e as DioException;
  //   print(e.response!.statusCode);
  // });
  // Map<String, String> data = {
  //   "email": "fuckiwt@gmail.com",
  //   "password": "dangdangdang",
  //   "username": "deraboiwasazw",
  //   "referal_code": "1010101"
  // };
  // signup(data).then((val) {
  //   print(val);
  // });
}
