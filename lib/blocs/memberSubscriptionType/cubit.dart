import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr_app/blocs/memberSubscriptionType/state.dart';
import 'package:readr_app/helpers/routeGenerator.dart';
import 'package:readr_app/models/memberSubscriptionType.dart';
import 'package:readr_app/services/memberService.dart';

class MemberSubscriptionTypeCubit extends Cubit<MemberSubscriptionTypeState> {
  MemberSubscriptionTypeCubit() : super(MemberSubscriptionTypeInitState());

  void fetchMemberSubscriptionType({
    bool isNavigateToMagazine = false,
  }) async {
    print('Fetch member subscription type');
    emit(MemberSubscriptionTypeLoadingState());
    SubscriptionType? subscriptionType;
    FirebaseAuth auth = FirebaseAuth.instance;
    if(auth.currentUser == null) {
      emit(MemberSubscriptionTypeLoadedState(subscriptionType: subscriptionType));
      if(isNavigateToMagazine) {
        RouteGenerator.navigateToLogin(
          routeName: RouteGenerator.magazine,
          routeArguments: {
            'subscriptionType': subscriptionType,
          },
        );
      }
    } else {
      try {
        MemberService memberService = MemberService();
        MemberIdAndSubscriptionType memberIdAndSubscriptionType = await memberService.checkSubscriptionType(auth.currentUser!);
        subscriptionType = memberIdAndSubscriptionType.subscriptionType;
        emit(MemberSubscriptionTypeLoadedState(subscriptionType: subscriptionType));
        if(isNavigateToMagazine) {
          if(subscriptionType != null) {
            RouteGenerator.navigateToMagazine(subscriptionType);
          } else {
            RouteGenerator.navigateToLogin(
              routeName: RouteGenerator.magazine,
              routeArguments: {
                'subscriptionType': subscriptionType,
              },
            );
          }
        }
      } catch(e) {
        // fetch member subscription type fail
        print(e.toString());
        emit(MemberSubscriptionTypeLoadedState(subscriptionType: subscriptionType));
      }
    }
  }
}