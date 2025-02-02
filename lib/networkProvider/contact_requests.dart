import 'package:dio/dio.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:oratio_app/models/contact_model.dart';

Future<List<ContactModel>> getContactsOnApp(
    PocketBase pb, List<String> contacts) async {
  final dio =
      Dio(BaseOptions(baseUrl: pb.baseUrl, contentType: "application/json"));
  try {
    final req = await dio.post('/get-contacts', data: contacts);
    final List<ContactModel> contactModels = (req.data as List)
        .map((contact) => ContactModel.fromJson(contact))
        .toList();
    return contactModels;
  } catch (e) {
    print("error occurred fetching contacts $e");
    return [];
  }
}
