import 'package:dio/dio.dart';
import 'package:pocketbase/pocketbase.dart';

Future<Map<String, dynamic>?>? handleDonation(
    PocketBase pb, Map<String, dynamic> data) async {
  final dio = Dio();
  final response = await dio.post("${pb.baseUrl}/donate", data: data);
  return response.data;
}

Future<bool> handleMassBooking(PocketBase pb, Map<String, dynamic> data) async {
  try {
    await pb.collection('mass_booking').create(body: data);
    return true;
  } catch (e) {
    return false;
  }
}

Future<void> handleRetreatBooking({required PocketBase pb ,required Map<String,dynamic> data})async{
await pb.collection("retreat").create(body:data);
}
