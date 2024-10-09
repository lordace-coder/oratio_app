import 'package:dio/dio.dart';
import 'package:oratio_app/networkProvider/constants.dart';

final dio = Dio(
  BaseOptions(baseUrl: BASEURL),
);

Options createHeaders(String token) {
  return Options(headers: {'Authorization': 'Bearer $token'});
}

Future<List<Map>> getNotifications(String token) async {
  final List<Map> result = [];
  try {
    final Response response = await dio.get(
      '/notifications/',
      options: createHeaders(token),
    );
    var data = response.data;
    for (var element in data) {
      result.add(element as Map);
    }
  } finally {
    return result;
  }
}

Future readAllNotifications(String token) async {
  try {
    await dio.get(
      '/notifications/read',
      options: createHeaders(token),
    );
  } catch (e) {}
}

Future deleteAllNotifications(String token) async {
  try {
    await dio.get(
      '/notifications/delete',
      options: createHeaders(token),
    );
  } catch (e) {}
}

void main(List<String> args) async {
  var t = await getNotifications(
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzI3MDUwNTcyLCJpYXQiOjE3MjcwMzI1NzIsImp0aSI6ImIzZTJjNWYxYTg2YTQ4Y2NhMWM4YTk0OWJlMTJiYmU3IiwidXNlcl9pZCI6ImxvcmRhY2UifQ.LiamdLj_QVXH0PcHRU2z-Od7N5QN00JRKA71VNKpD8s');
}
