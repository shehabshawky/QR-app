import 'package:dio/dio.dart';
import 'package:login_page/consts/consts.dart';
import 'package:login_page/models/adminslistmodel.dart';

// class GetAdminsService {
//   final Dio _dio = Dio();

//   Future<List<Adminslistmodel>> getAdmins(String? token) async {
//     try {
//       Response response = await _dio.get(
//           'http://10.0.2.2:5000/api/users/admins',
//           options: Options(headers: {
//             "Content-Type": "application/json",
//             "Authorization": "Bearer $token"
//           }));

//       if (response.statusCode == 200) {
//         List data = response.data;
//         return data.map((json) => Adminslistmodel.fromJson(json)).toList();
//       } else {
//         throw Exception('Failed to load admins');
//       }
//     } catch (error) {
//       throw Exception('Error: $error');
//     }
//   }
// }
class GetAdminsService {
  final Dio dio = Dio();

  final List<Adminslistmodel> adminslist = [];
  Future<List<Adminslistmodel>> getAdmins(String? token) async {
    try {
  Response response = await dio.get('$baseUrl/users/admins',
      options: Options(headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      }));
  List<dynamic> adminsListjason = response.data;
  for (var items in adminsListjason) {
    adminslist.add(Adminslistmodel.fromJson(items));
  }
  return adminslist;
}  catch (e) {
  throw Exception('Error: $e');
}
  }
}
