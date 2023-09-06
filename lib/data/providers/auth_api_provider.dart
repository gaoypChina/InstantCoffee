import 'package:get/get.dart';

import '../../helpers/api_base_helper.dart';

class AuthApiProvider extends GetConnect {
  AuthApiProvider._();

  static final AuthApiProvider _instance = AuthApiProvider._();

  static AuthApiProvider get instance => _instance;

  final ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  Future<String?> getAccessTokenByIdToken(String idToken) async {
    final result = await apiBaseHelper.postByUrl(
        'https://adam-weekly-api-server-dev-ufaummkd5q-de.a.run.app/access-token',
        null,
        headers: {'authorization': 'Bearer $idToken'});

    if (result['status'] == 'success') {
      return result['data']['access_token'];
    }
    return null;
  }
}
