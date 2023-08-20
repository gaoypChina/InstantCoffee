import 'package:get/get.dart';
import 'package:readr_app/data/providers/articles_api_provider.dart';
import 'package:readr_app/helpers/environment.dart';
import 'package:readr_app/helpers/api_base_helper.dart';
import 'package:readr_app/helpers/cache_duration_cache.dart';
import 'package:readr_app/models/listening.dart';

class ListeningWidgetService {
  final ApiBaseHelper _helper = ApiBaseHelper();
  final ArticlesApiProvider articlesApiProvider =Get.find();

  Future<Listening> fetchListening(String youtubeId) async {
    String endpoint =
        '${Environment().config.graphqlRoot}youtube/videos?part=snippet&maxResults=1&id=$youtubeId';

    final jsonResponse = await _helper.getByCacheAndAutoCache(endpoint,
        maxAge: listeningWidgetCacheDuration);
    Listening listening = Listening.fromJson(jsonResponse["items"][0]);
    return listening;
  }
}
