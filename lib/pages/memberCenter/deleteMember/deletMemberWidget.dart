import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr_app/blocs/memberCenter/deleteMember/cubit.dart';
import 'package:readr_app/blocs/memberCenter/deleteMember/state.dart';
import 'package:readr_app/helpers/dataConstants.dart';
import 'package:url_launcher/url_launcher.dart';

class DeleteMemberWidget extends StatefulWidget {
  final String israfelId;
  DeleteMemberWidget({
    @required this.israfelId,
  });

  @override
  _DeleteMemberWidgetState createState() => _DeleteMemberWidgetState();
}

class _DeleteMemberWidgetState extends State<DeleteMemberWidget> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  _deleteMember() {
    context.read<DeleteMemberCubit>().deleteMember(widget.israfelId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeleteMemberCubit, DeleteMemberState>(
      builder: (context, state) {
        if(state is DeleteMemberInitState) {
          return Scaffold(
            appBar: _buildBar(context),
            body: _askingDeleteMemberWidget(context),
          );
        }

        if(state is DeleteMemberSuccess) {
          return Scaffold(
            appBar: _buildBar(context, isDeletedSuccessfully: true),
            body: _deletingMemberSuccessWidget(context),
          );
        }

        if(state is DeleteMemberError) {
          return Scaffold(
            appBar: _buildBar(context),
            body: _deletingMemberErrorWidget(context),
          );
        }

        // state is DeleteMemberLoading
        return Scaffold(
          appBar: _buildBar(context),
          body: _loadingWidget(),
        );
      }
    );
  }

  Widget _buildBar(BuildContext context, {bool isDeletedSuccessfully = false}) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          if(isDeletedSuccessfully) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            Navigator.of(context).pop();
          }
        } 
      ),
      centerTitle: true,
      title: Text('會員中心'),
      backgroundColor: appColor,
    );
  }

  Widget _askingDeleteMemberWidget(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 72),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              '確定要刪除帳號？',
              style: TextStyle(
                fontSize: 28,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              '您的會員帳號為：${_auth.currentUser.email}',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              '刪除後即無法復原',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              '將無法享有鏡週刊會員獨享服務',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0),
          child: _backToHomeButton('不刪除，回首頁', context),
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0),
          child: _deleteMemberButton(context),
        ),
      ],
    );
  }

  Widget _loadingWidget() {
    return Center(child: CircularProgressIndicator(),);
  }

  Widget _deletingMemberSuccessWidget(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 72),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              '已刪除帳號',
              style: TextStyle(
                fontSize: 28,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              '我們已經刪除你的會員帳號',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 4.0, 24.0, 4.0),
            child: Text(
              '謝謝你使用鏡週刊的會員服務，很遺憾要刪除你的帳號，如果希望再次使用的話，歡迎再次註冊！',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0),
          child: _backToHomeButton('回首頁', context),
        ),
      ],
    );
  }

  Widget _deletingMemberErrorWidget(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 72),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              '刪除失敗',
              style: TextStyle(
                fontSize: 28,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              '請重新登入，或是聯繫客服',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          ),
        ),
        InkWell(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
              child: Text(
                'E-MAIL: mm-onlineservice@mirrormedia.mg',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            ),
          ),
          onTap: () async{
            final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: 'mm-onlineservice@mirrormedia.mg',
            );

            if (await canLaunch(emailLaunchUri.toString())) {
              await launch(emailLaunchUri.toString());
            } else {
              throw 'Could not launch mm-onlineservice@mirrormedia.mg';
            }
          }
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              '(02)6633-3966',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Text(
              '我們將有專人為您服務',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0),
          child: _backToHomeButton('回首頁', context),
        ),
      ],
    );
  }

  Widget _backToHomeButton(String text, BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(5.0),
      child: Container(
        height: 50.0,
        decoration: BoxDecoration(
          color: appColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
              color: Colors.white,
            ),
          ),
        ),
      ),
      onTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );
  }

  Widget _deleteMemberButton(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(5.0),
      child: Container(
        height: 50.0,
        decoration: BoxDecoration(
          //color: appColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Center(
          child: Text(
            '確認刪除',
            style: TextStyle(
              fontSize: 17,
              color: Colors.red,
            ),
          ),
        ),
      ),
      onTap: () => _deleteMember(),
    );
  }
}