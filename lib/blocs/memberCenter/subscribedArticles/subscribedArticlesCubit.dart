import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:readr_app/helpers/exceptions.dart';
import 'package:readr_app/models/subscribedArticle.dart';
import 'package:readr_app/services/subscribedArticlesService.dart';

part 'subscribedArticlesState.dart';

class SubscribedArticlesCubit extends Cubit<SubscribedArticlesState> {
  SubscribedArticlesCubit() : super(SubscribedArticlesInitial());

  void fetchSubscribedArticles() async {
    print('Get subscribed articles');
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      String token = await auth.currentUser!.getIdToken();
      SubscribedArticlesService subscribedArticlesService = SubscribedArticlesService();
      List<SubscribedArticle> subscribedArticles = await subscribedArticlesService.getSubscribedArticles(auth.currentUser!.uid, token);
      emit(SubscribedArticlesLoaded(subscribedArticles: subscribedArticles));
    } on SocketException {
      emit(SubscribedArticlesError(
        error: NoInternetException('No Internet'),
      ));
    } on HttpException {
      emit(SubscribedArticlesError(
        error: NoServiceFoundException('No Service Found'),
      ));
    } on FormatException {
      emit(SubscribedArticlesError(
        error: InvalidFormatException('Invalid Response format'),
      ));
    } catch (e) {
      emit(SubscribedArticlesError(
        error: UnknownException(e.toString()),
      ));
    }
  }
}
