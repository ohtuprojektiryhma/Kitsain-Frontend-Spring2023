import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:kitsain_frontend_spring2023/LoginController.dart';

class AuthService {
  var accessToken = Rx<String?>(null);
  final loginController = Get.put(LoginController());
  Future verifyToken(String token) async {
    try {
      http.Response response = await http.post(
        Uri.parse("http://nocng.id.vn:9090/api/v1/auth/verifyToken"),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode({'accessToken': token}),
      );

      // Decode the response JSON
      Map<String, dynamic> responseData = jsonDecode(response.body);

      accessToken.value = responseData['accessToken'].toString();
    } catch (error) {
      print("error");
      // Handle any errors that occur during the request
    }
  }
}
