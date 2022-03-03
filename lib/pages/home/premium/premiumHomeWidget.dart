import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr_app/blocs/section/cubit.dart';
import 'package:readr_app/blocs/section/states.dart';
import 'package:readr_app/helpers/dataConstants.dart';
import 'package:readr_app/helpers/environment.dart';
import 'package:readr_app/helpers/firebaseAnalyticsHelper.dart';
import 'package:readr_app/helpers/remoteConfigHelper.dart';
import 'package:readr_app/models/section.dart';
import 'package:readr_app/pages/tabContent/listening/premiumListeningTabContent.dart';
import 'package:readr_app/pages/tabContent/news/premiumTabContent.dart';
import 'package:readr_app/pages/tabContent/personal/premium/premiumPersionalTabContent.dart';
import 'package:readr_app/widgets/newsMarquee/newsMarquee.dart';
import 'package:readr_app/widgets/popupRoute/easyPopup.dart';
import 'package:readr_app/widgets/popupRoute/sectionDropDownMenu.dart';

class PremiumHomeWidget extends StatefulWidget {
  @override
  _PremiumHomeWidgetState createState() => _PremiumHomeWidgetState();
}

class _PremiumHomeWidgetState extends State<PremiumHomeWidget> with TickerProviderStateMixin{
  RemoteConfigHelper _remoteConfigHelper = RemoteConfigHelper();
  double _deviceTopPadding = 0.0;

  /// tab controller
  int _initialTabIndex = 0;
  TabController? _tabController;
  StreamController<Color>? _tabColorController;

  List<GlobalKey> _tabKeys = [];
  List<Tab> _tabs = [];
  List<Widget> _tabWidgets = [];
  List<ScrollController> _scrollControllerList = [];
  
  _fetchSectionList() {
    context.read<SectionCubit>().fetchSectionList();
  }

  @override
  void initState() {
    _fetchSectionList();
    super.initState();
  }
  
  _initializeTabController(List<Section> sectionItems) {
    _tabKeys.clear();
    _tabs.clear();
    _tabWidgets.clear();
    _scrollControllerList.clear();

    for (int i = 0; i < sectionItems.length; i++) {
      _tabKeys.add(GlobalKey());
      Section section = sectionItems[i];
      _tabs.add(
        Tab(
          key: _tabKeys[i],
          child: Text(
            section.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: section.name == 'member'
              ? Color(0xffDB1730)
              : null,
            ),
          ),
        ),
      );

      _scrollControllerList.add(ScrollController());
      if (section.key == Environment().config.listeningSectionKey) {
        _tabWidgets.add(PremiumListeningTabContent(
          section: section,
          scrollController: _scrollControllerList[i],
        ));
      } else if (section.key == Environment().config.personalSectionKey){
        _tabWidgets.add(PremiumPersonalTabContent(
          //onBoardingBloc: widget.onBoardingBloc,
          scrollController: _scrollControllerList[i],
        ));
      } else {
        _tabWidgets.add(PremiumTabContent(
          section: section,
          scrollController: _scrollControllerList[i],
          needCarousel: i == 0,
        ));
      }
    }

    _tabColorController = StreamController<Color>();

    // set controller
    _tabController = TabController(
      vsync: this,
      length: sectionItems.length,
      initialIndex:
          _tabController == null ? _initialTabIndex : _tabController!.index,
    )..addListener(() { 
      // when index is member
      if (_tabController!.index == 3) {
        _tabColorController!.sink.add(Color(0xffDB1730));
      } else {
        _tabColorController!.sink.add(appColor);
      }
    });
  }

  _scrollToTop(int index) {
    if (_scrollControllerList[index].hasClients) {
      _scrollControllerList[index].animateTo(
          _scrollControllerList[index].position.minScrollExtent,
          duration: Duration(milliseconds: 1000),
          curve: Curves.easeIn);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _tabColorController?.close();

    _scrollControllerList.forEach((scrollController) {
      scrollController.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _deviceTopPadding = MediaQuery.of(context).padding.top;
    return ColoredBox(
      color: Colors.white,
      child: BlocBuilder<SectionCubit, SectionState>(
        builder: (BuildContext context, SectionState state) {
          SectionStatus status = state.status;
          if(status == SectionStatus.error) {
            print('PremiumHomePageSectionError: ${state.errorMessages}');
            return Container();
          } else if(status == SectionStatus.loaded) {
            _initializeTabController(state.sectionList!);
            return _buildTabs(
              state.sectionList!,
              _tabs, 
              _tabWidgets, 
              _tabController!
            );
          }

          // init or loading
          return Center(child: CircularProgressIndicator());
        }
      ),
    );
  }

  Widget _buildTabs(
    List<Section> sections,
    List<Tab> tabs, 
    List<Widget> tabWidgets, 
    TabController tabController
  ) {
    return Column(
      children: [
        Container(
          constraints: BoxConstraints(maxHeight: 150.0),
          child: Material(
            color: Color.fromARGB(255, 229, 229, 229),
            child: StreamBuilder<Color>(
              initialData: appColor,
              stream: _tabColorController!.stream,
              builder: (context, snapshot) {
                Color tabBarColor = snapshot.data!;
                TabBar tabBar = TabBar(
                  isScrollable: true,
                  indicatorColor: tabBarColor,
                  unselectedLabelColor: Colors.grey,
                  labelColor: appColor,
                  tabs: tabs.toList(),
                  controller: tabController,
                  onTap: (int index) {
                    if(index >= 5) {
                      FirebaseAnalyticsHelper.logTabBarAfterTheSixthClick(
                        sectiontitle: sections[index].title
                      );
                    }

                    if (_initialTabIndex == index) {
                      _scrollToTop(index);
                    }
                    _initialTabIndex = index;
                  },
                );

                return Row(
                  children: [
                    Expanded(
                      child: tabBar,
                    ),
                    
                    if(_remoteConfigHelper.hasTabSectionButton)...[
                      Container(
                        height: tabBar.preferredSize.height,
                        child: VerticalDivider(
                          color: Colors.black12,
                          thickness: 1,
                          indent: 12,
                          endIndent: 12,
                          width: 8,
                        ),
                      ),
                      InkWell(
                        child: Container(
                          height: tabBar.preferredSize.height,
                          width: tabBar.preferredSize.height-8,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 24,
                            color: Colors.black54,
                          ),
                        ),
                        onTap: () {
                          EasyPopup.show(
                            context, 
                            SectionDropDownMenu(
                              tabBarHeight: tabBar.preferredSize.height,
                              tabController: _tabController!,
                              sectionList: sections,
                            ),
                            offsetLT: Offset(
                              0, 
                              _deviceTopPadding + kToolbarHeight,
                            ),
                            cancelable: true,
                            outsideTouchCancelable: false,
                          );
                        }
                      )
                    ]
                  ],
                );
              }
            ),
          ),
        ),
        if(_remoteConfigHelper.isNewsMarqueePin)
          NewsMarquee(),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: tabWidgets.toList(),
          ),
        ),
      ],
    );
  }
}